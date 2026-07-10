import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:swapstash/app.dart';
import 'package:swapstash/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SwapStashApp());
}