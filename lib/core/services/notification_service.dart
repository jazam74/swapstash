import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:swapstash/core/navigation/app_navigator.dart';
import 'package:swapstash/core/services/chat_service.dart';
import 'package:swapstash/core/services/firestore_service.dart';
import 'package:swapstash/features/messages/chat_page.dart';
import 'package:swapstash/features/trades/trades_page.dart';
import 'package:swapstash/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('Background notification received: ${message.messageId}');
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _messageChannelId = 'swapstash_messages';
  static const String _messageChannelName = 'SwapStash messages';
  static const String _messageChannelDescription =
      'Notifications for new SwapStash chat messages.';

  static const String _tradeChannelId = 'swapstash_trades';
  static const String _tradeChannelName = 'SwapStash trades';
  static const String _tradeChannelDescription =
      'Notifications about SwapStash trade activity.';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final ChatService _chatService = ChatService();

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;

  bool _initialized = false;
  bool _appReady = false;
  bool _openingDestination = false;

  String _languageCode = 'en';
  Map<String, dynamic>? _pendingInteractionData;

  String? _lastOpenedInteractionKey;
  DateTime? _lastInteractionOpenTime;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    await _initializeLocalNotifications();
    await _requestNotificationPermission();
    await _configureForegroundPresentation();
    await _createAndroidNotificationChannels();

    _listenForAuthenticationChanges();
    _listenForTokenRefresh();
    _listenForForegroundMessages();
    _listenForNotificationClicks();

    await _saveCurrentToken();
    await _saveCurrentLanguage();
    await _readInitialNotificationInteraction();
  }

  /// Pokliče se, ko je MaterialApp ustvarjen in je korenski Navigator na voljo.
  void onAppReady() {
    _appReady = true;
    unawaited(_processPendingInteraction());
  }

  Future<void> updateLanguageCode(String languageCode) async {
    final normalizedLanguageCode = _normalizeLanguageCode(languageCode);
    _languageCode = normalizedLanguageCode;

    await _saveCurrentLanguage();
  }

  String _normalizeLanguageCode(String languageCode) {
    final normalized = languageCode.trim().toLowerCase();

    switch (normalized) {
      case 'sl':
      case 'de':
      case 'hr':
      case 'en':
        return normalized;
      default:
        return 'en';
    }
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

  Future<void> _createAndroidNotificationChannels() async {
    const messageChannel = AndroidNotificationChannel(
      _messageChannelId,
      _messageChannelName,
      description: _messageChannelDescription,
      importance: Importance.high,
    );

    const tradeChannel = AndroidNotificationChannel(
      _tradeChannelId,
      _tradeChannelName,
      description: _tradeChannelDescription,
      importance: Importance.high,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(messageChannel);
    await androidPlugin?.createNotificationChannel(tradeChannel);
  }

  void _listenForAuthenticationChanges() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (user) async {
        if (user == null) {
          return;
        }

        await _saveCurrentToken();
        await _saveCurrentLanguage();
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
        await _saveCurrentLanguage();
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

  Future<void> _saveCurrentLanguage() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'notificationLanguage': _languageCode,
        'notificationLanguageUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (error, stackTrace) {
      debugPrint('Could not save notification language: $error');
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

    final isTrade = message.data['type']?.toString() == 'trade';

    final androidDetails = AndroidNotificationDetails(
      isTrade ? _tradeChannelId : _messageChannelId,
      isTrade ? _tradeChannelName : _messageChannelName,
      channelDescription: isTrade
          ? _tradeChannelDescription
          : _messageChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      category: isTrade
          ? AndroidNotificationCategory.status
          : AndroidNotificationCategory.message,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
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
    if (!_appReady || _openingDestination) {
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

    final type = data['type']?.toString().trim().toLowerCase() ?? '';

    if (type == 'trade' || data.containsKey('tradeId')) {
      await _openTradeNotification(navigator: navigator, data: data);
      return;
    }

    await _openMessageNotification(
      navigator: navigator,
      currentUser: currentUser,
      data: data,
    );
  }

  Future<void> _openMessageNotification({
    required NavigatorState navigator,
    required User currentUser,
    required Map<String, dynamic> data,
  }) async {
    final conversationId = data['conversationId']?.toString().trim() ?? '';

    if (conversationId.isEmpty) {
      debugPrint('Notification does not contain a valid conversationId: $data');
      _pendingInteractionData = null;
      return;
    }

    final interactionKey = 'message:$conversationId';

    if (_isDuplicateInteraction(interactionKey)) {
      _pendingInteractionData = null;
      return;
    }

    _openingDestination = true;

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
      _rememberInteraction(interactionKey);

      await navigator.push(
        MaterialPageRoute<void>(
          builder: (context) => ChatPage(conversation: conversation),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Could not open conversation from notification: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _openingDestination = false;
      _processNextPendingInteraction();
    }
  }

  Future<void> _openTradeNotification({
    required NavigatorState navigator,
    required Map<String, dynamic> data,
  }) async {
    final tradeId = data['tradeId']?.toString().trim() ?? '';

    if (tradeId.isEmpty) {
      debugPrint('Notification does not contain a valid tradeId: $data');
      _pendingInteractionData = null;
      return;
    }

    final interactionKey = 'trade:$tradeId';

    if (_isDuplicateInteraction(interactionKey)) {
      _pendingInteractionData = null;
      return;
    }

    final rawTabIndex = int.tryParse(data['tabIndex']?.toString() ?? '');

    final tabIndex = rawTabIndex == null
        ? 0
        : rawTabIndex < 0
        ? 0
        : rawTabIndex > 3
        ? 3
        : rawTabIndex;

    _openingDestination = true;

    try {
      _pendingInteractionData = null;
      _rememberInteraction(interactionKey);

      await navigator.push(
        MaterialPageRoute<void>(
          builder: (context) => TradesPage(
            initialTabIndex: tabIndex,
            highlightedTradeId: tradeId,
          ),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Could not open trade from notification: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _openingDestination = false;
      _processNextPendingInteraction();
    }
  }

  void _processNextPendingInteraction() {
    if (_pendingInteractionData != null) {
      unawaited(_processPendingInteraction());
    }
  }

  void _rememberInteraction(String interactionKey) {
    _lastOpenedInteractionKey = interactionKey;
    _lastInteractionOpenTime = DateTime.now();
  }

  bool _isDuplicateInteraction(String interactionKey) {
    if (_lastOpenedInteractionKey != interactionKey) {
      return false;
    }

    final previousOpenTime = _lastInteractionOpenTime;

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
    _openingDestination = false;
  }
}
