import 'package:flutter/material.dart';

class DashboardAction {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? tradeId;
  final int? tradeTabIndex;
  final VoidCallback? onTap;

  const DashboardAction({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.tradeId,
    this.tradeTabIndex,
    this.onTap,
  });

  DashboardAction copyWith({VoidCallback? onTap}) {
    return DashboardAction(
      icon: icon,
      color: color,
      title: title,
      subtitle: subtitle,
      tradeId: tradeId,
      tradeTabIndex: tradeTabIndex,
      onTap: onTap ?? this.onTap,
    );
  }
}
