import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapstash/core/models/safety_report.dart';

class ReportService {
  static const String adminUid = 'GTCWV8yUJjdCxFpNRfHllKs2ctD3';
  static const int maximumDetailsLength = 1000;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  ReportService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('user_not_signed_in');
    }

    return user.uid;
  }

  bool get isCurrentUserAdmin => currentUserId == adminUid;

  Future<void> submitReport({
    required String reportedUserId,
    required SafetyReportType targetType,
    required String targetId,
    required String reason,
    String details = '',
    String conversationId = '',
  }) async {
    final reporterId = currentUserId;
    final reportedId = reportedUserId.trim();
    final normalizedTargetId = targetId.trim();
    final normalizedReason = reason.trim();
    final normalizedDetails = details.trim();
    final normalizedConversationId = conversationId.trim();

    if (reportedId.isEmpty || reportedId == reporterId) {
      throw ArgumentError('invalid_reported_user');
    }

    if (normalizedTargetId.isEmpty) {
      throw ArgumentError('invalid_report_target');
    }

    const allowedReasons = {
      'spam',
      'harassment',
      'fraud',
      'inappropriate',
      'other',
    };

    if (!allowedReasons.contains(normalizedReason)) {
      throw ArgumentError('invalid_report_reason');
    }

    if (normalizedDetails.length > maximumDetailsLength) {
      throw ArgumentError('report_details_too_long');
    }

    await _db.collection('reports').add({
      'reporterId': reporterId,
      'reportedUserId': reportedId,
      'targetType': targetType.name,
      'targetId': normalizedTargetId,
      'conversationId': normalizedConversationId,
      'reason': normalizedReason,
      'details': normalizedDetails,
      'status': SafetyReportStatus.open.name,
      'createdAt': FieldValue.serverTimestamp(),
      'reviewedAt': null,
      'reviewedBy': '',
    });
  }

  Stream<List<SafetyReport>> watchReports({SafetyReportStatus? status}) {
    if (!isCurrentUserAdmin) {
      return Stream<List<SafetyReport>>.error(
        StateError('admin_access_required'),
      );
    }

    return _db
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final reports = snapshot.docs
              .map(
                (document) =>
                    SafetyReport.fromMap(document.id, document.data()),
              )
              .toList(growable: false);

          if (status == null) {
            return reports;
          }

          return reports
              .where((report) => report.status == status)
              .toList(growable: false);
        });
  }

  Future<void> updateReportStatus({
    required String reportId,
    required SafetyReportStatus status,
  }) async {
    if (!isCurrentUserAdmin) {
      throw StateError('admin_access_required');
    }

    final id = reportId.trim();

    if (id.isEmpty) {
      throw ArgumentError('report_id_missing');
    }

    await _db.collection('reports').doc(id).update({
      'status': status.name,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': currentUserId,
    });
  }
}
