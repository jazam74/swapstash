import 'package:flutter/material.dart';

enum TradeActionType {
  respondToOffer,
  confirmHandover,
  confirmReceipt,
  waiting,
  completed,
  unavailable,
}

class TradeAction {
  final TradeActionType type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final bool isVisible;
  final int currentStep;
  final int totalSteps;

  const TradeAction({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.isVisible,
    required this.currentStep,
    this.totalSteps = 4,
  });

  bool get requiresUserAction {
    return type == TradeActionType.respondToOffer ||
        type == TradeActionType.confirmHandover ||
        type == TradeActionType.confirmReceipt;
  }
}
