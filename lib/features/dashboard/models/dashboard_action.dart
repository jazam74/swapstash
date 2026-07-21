import 'package:flutter/material.dart';

class DashboardAction {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const DashboardAction({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}
