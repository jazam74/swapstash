import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:swapstash/app.dart';
import 'package:swapstash/core/observability/crash_reporter.dart';
import 'package:swapstash/firebase_options.dart';

import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await CrashReporter.instance.install();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await NotificationService.instance.initialize();

  // Reachable only when built with --dart-define=CRASHLYTICS_SMOKE=true.
  CrashReporter.instance.triggerSmokeCrashIfEnabled();

  runApp(const SwapStashApp());
}
