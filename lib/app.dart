import 'package:flutter/material.dart';
import 'package:swapstash/core/theme/app_theme.dart';
import 'package:swapstash/features/navigation/main_screen.dart';

class SwapStashApp extends StatelessWidget {
  const SwapStashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwapStash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainScreen(),
    );
  }
}