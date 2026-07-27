import 'package:cloud_firestore/cloud_firestore.dart';

enum SafetyReportType { user, message, trade }

enum SafetyReportStatus { open, reviewing, resolved, dismissed }

class SafetyReport {
  final String id;
  final String reporterId;
  final String reportedUserId;
  final SafetyReportType targetType;
  final String targetId;
  final String conversationId;
  final String reason;
  final String details;
  final SafetyReportStatus status;
  final Timestamp createdAt;
  final Timestamp? reviewedAt;
  final String reviewedBy;

  const SafetyReport({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.targetType,
    required this.targetId,
    required this.conversationId,
    required this.reason,
    required this.details,
    required this.status,
    required this.createdAt,
    required this.reviewedAt,
    required this.reviewedBy,
  });

  factory SafetyReport.fromMap(String id, Map<String, dynamic> map) {
    final targetTypeName = map['targetType']?.toString() ?? '';
    final statusName = map['status']?.toString() ?? '';

    return SafetyReport(
      id: id,
      reporterId: map['reporterId']?.toString() ?? '',
      reportedUserId: map['reportedUserId']?.toString() ?? '',
      targetType: SafetyReportType.values.firstWhere(
        (value) => value.name == targetTypeName,
        orElse: () => SafetyReportType.user,
      ),
      targetId: map['targetId']?.toString() ?? '',
      conversationId: map['conversationId']?.toString() ?? '',
      reason: map['reason']?.toString() ?? 'other',
      details: map['details']?.toString() ?? '',
      status: SafetyReportStatus.values.firstWhere(
        (value) => value.name == statusName,
        orElse: () => SafetyReportStatus.open,
      ),
      createdAt: map['createdAt'] is Timestamp
          ? map['createdAt'] as Timestamp
          : Timestamp.now(),
      reviewedAt: map['reviewedAt'] is Timestamp
          ? map['reviewedAt'] as Timestamp
          : null,
      reviewedBy: map['reviewedBy']?.toString() ?? '',
    );
  }
}
