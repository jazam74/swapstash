import 'package:flutter/material.dart';

class DashboardAction {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? tradeId;
  final int? tradeTabIndex;
  final String? conversationId;
  final int priority;
  final DateTime? sortAt;
  final VoidCallback? onTap;

  const DashboardAction({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.tradeId,
    this.tradeTabIndex,
    this.conversationId,
    this.priority = 100,
    this.sortAt,
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
      conversationId: conversationId,
      priority: priority,
      sortAt: sortAt,
      onTap: onTap ?? this.onTap,
    );
  }
}
