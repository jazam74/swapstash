import 'package:flutter/material.dart';

class TradeDisplayStatus {
  final String title;
  final String subtitle;
  final String badgeLabel;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final int completedSteps;

  const TradeDisplayStatus({
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.completedSteps,
  });

  double get progress => completedSteps.clamp(0, 4) / 4;
}
