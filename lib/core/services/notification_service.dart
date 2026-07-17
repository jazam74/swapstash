import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:swapstash/core/navigation/app_navigator.dart';
import 'package:swapstash/core/services/chat_service.dart';
import 'package:swapstash/core/services/firestore_service.dart';
import 'package:swapstash/features/messages/chat_page.dart';
import 'package:swapstash/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('Background notification received: ${message.messageId}');
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _channelId = 'swapstash_messages';
  static const String _channelName = 'SwapStash messages';
  static const String _channelDescription =
      'Notifications for new SwapStash chat messages.';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final FirestoreService _firestoreService = FirestoreService();
  final ChatService _chatService = ChatService();

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;

  bool _initialized = false;
  bool _appReady = false;
  bool _openingConversation = false;

  Map<String, dynamic>? _pendingInteractionData;

  String? _lastOpenedConversationId;
  DateTime? _lastConversationOpenTime;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    await _initializeLocalNotifications();
    await _requestNotificationPermission();
    await _configureForegroundPresentation();
    await _createAndroidNotificationChannel();

    _listenForAuthenticationChanges();
    _listenForTokenRefresh();
    _listenForForegroundMessages();
    _listenForNotificationClicks();

    await _saveCurrentToken();
    await _readInitialNotificationInteraction();
  }

  /// Pokliče se, ko je MaterialApp ustvarjen in je korenski Navigator na voljo.
  void onAppReady() {
    _appReady = true;
    unawaited(_processPendingInteraction());
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationInteraction,
    );
  }

  Future<void> _readInitialNotificationInteraction() async {
    final remoteInitialMessage = await _messaging.getInitialMessage();

    if (remoteInitialMessage != null) {
      _queueInteraction(remoteInitialMessage.data);
      return;
    }

    final localLaunchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();

    final response = localLaunchDetails?.notificationResponse;
    final payload = response?.payload;

    if (localLaunchDetails?.didNotificationLaunchApp != true ||
        payload == null ||
        payload.trim().isEmpty) {
      return;
    }

    final data = _decodePayload(payload);

    if (data != null) {
      _queueInteraction(data);
    }
  }

  Future<void> _requestNotificationPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
      'Notification permission: '
      '${settings.authorizationStatus}',
    );
  }

  Future<void> _configureForegroundPresentation() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _createAndroidNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(channel);
  }

  void _listenForAuthenticationChanges() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (user) async {
        if (user == null) {
          return;
        }

        await _saveCurrentToken();
        await _processPendingInteraction();
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint(
          'Authentication notification listener failed: '
          '$error',
        );
      },
    );
  }

  void _listenForTokenRefresh() {
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
      (token) async {
        await _firestoreService.saveNotificationToken(token);
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('FCM token refresh failed: $error');
      },
    );
  }

  void _listenForForegroundMessages() {
    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(
      _showForegroundNotification,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint(
          'Foreground notification listener failed: '
          '$error',
        );
      },
    );
  }

  void _listenForNotificationClicks() {
    _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleRemoteMessageInteraction,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint(
          'Notification interaction listener failed: '
          '$error',
        );
      },
    );
  }

  Future<void> _saveCurrentToken() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      final token = await _messaging.getToken();

      if (token == null || token.trim().isEmpty) {
        debugPrint('FCM token is not currently available.');
        return;
      }

      await _firestoreService.saveNotificationToken(token);

      debugPrint('FCM token saved for user ${user.uid}.');
    } catch (error, stackTrace) {
      debugPrint('Could not obtain or save FCM token: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> removeCurrentDeviceToken() async {
    try {
      final token = await _messaging.getToken();

      if (token == null || token.trim().isEmpty) {
        return;
      }

      await _firestoreService.removeNotificationToken(token);
    } catch (error, stackTrace) {
      debugPrint('Could not remove FCM token: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;

    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();

    if (title == null && body == null) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.message,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id:
          message.messageId?.hashCode ??
          DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  void _handleRemoteMessageInteraction(RemoteMessage message) {
    debugPrint('Remote notification opened: ${message.data}');
    _queueInteraction(message.data);
  }

  void _handleLocalNotificationInteraction(NotificationResponse response) {
    final payload = response.payload;

    if (payload == null || payload.trim().isEmpty) {
      return;
    }

    final data = _decodePayload(payload);

    if (data == null) {
      return;
    }

    debugPrint('Local notification opened: $data');
    _queueInteraction(data);
  }

  Map<String, dynamic>? _decodePayload(String payload) {
    try {
      final decodedPayload = jsonDecode(payload);

      if (decodedPayload is! Map) {
        debugPrint('Notification payload is not a JSON object.');
        return null;
      }

      return Map<String, dynamic>.from(decodedPayload);
    } catch (error) {
      debugPrint('Invalid notification payload: $error');
      return null;
    }
  }

  void _queueInteraction(Map<String, dynamic> data) {
    _pendingInteractionData = Map<String, dynamic>.from(data);
    unawaited(_processPendingInteraction());
  }

  Future<void> _processPendingInteraction() async {
    if (!_appReady || _openingConversation) {
      return;
    }

    final data = _pendingInteractionData;

    if (data == null) {
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    final navigator = appNavigatorKey.currentState;

    if (navigator == null) {
      return;
    }

    final conversationId = data['conversationId']?.toString().trim() ?? '';

    if (conversationId.isEmpty) {
      debugPrint('Notification does not contain a valid conversationId: $data');

      _pendingInteractionData = null;
      return;
    }

    if (_isDuplicateInteraction(conversationId)) {
      _pendingInteractionData = null;
      return;
    }

    _openingConversation = true;

    try {
      final conversation = await _chatService.getConversation(
        conversationId: conversationId,
      );

      if (conversation == null) {
        debugPrint(
          'Conversation from notification was not found: $conversationId',
        );

        _pendingInteractionData = null;
        return;
      }

      if (!conversation.participantIds.contains(currentUser.uid)) {
        debugPrint(
          'Current user does not have access to conversation '
          '$conversationId.',
        );

        _pendingInteractionData = null;
        return;
      }

      _pendingInteractionData = null;
      _lastOpenedConversationId = conversationId;
      _lastConversationOpenTime = DateTime.now();

      await navigator.push(
        MaterialPageRoute<void>(
          builder: (context) => ChatPage(conversation: conversation),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Could not open conversation from notification: $error');

      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _openingConversation = false;

      if (_pendingInteractionData != null) {
        unawaited(_processPendingInteraction());
      }
    }
  }

  bool _isDuplicateInteraction(String conversationId) {
    if (_lastOpenedConversationId != conversationId) {
      return false;
    }

    final previousOpenTime = _lastConversationOpenTime;

    if (previousOpenTime == null) {
      return false;
    }

    return DateTime.now().difference(previousOpenTime) <
        const Duration(seconds: 2);
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();
    await _foregroundMessageSubscription?.cancel();
    await _messageOpenedSubscription?.cancel();

    _authSubscription = null;
    _tokenRefreshSubscription = null;
    _foregroundMessageSubscription = null;
    _messageOpenedSubscription = null;

    _pendingInteractionData = null;
    _initialized = false;
    _appReady = false;
    _openingConversation = false;
  }
}
