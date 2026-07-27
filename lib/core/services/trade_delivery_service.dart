import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/core/models/trade_delivery_details.dart';

class TradeDeliveryService {
  static const int shortFieldMaximumLength = 120;
  static const int notesMaximumLength = 500;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  TradeDeliveryService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('user_not_signed_in');
    }

    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> _detailsReference({
    required String tradeId,
    required String userId,
  }) {
    return _db
        .collection('trades')
        .doc(tradeId)
        .collection('deliveryDetails')
        .doc(userId);
  }

  Stream<TradeDeliveryDetails?> watchDetails({
    required String tradeId,
    required String userId,
  }) {
    final normalizedTradeId = tradeId.trim();
    final normalizedUserId = userId.trim();

    if (normalizedTradeId.isEmpty || normalizedUserId.isEmpty) {
      return Stream<TradeDeliveryDetails?>.value(null);
    }

    return _detailsReference(
      tradeId: normalizedTradeId,
      userId: normalizedUserId,
    ).snapshots().map((document) {
      final data = document.data();

      if (!document.exists || data == null) {
        return null;
      }

      return TradeDeliveryDetails.fromMap(document.id, data);
    });
  }

  Future<void> saveMyDetails({
    required Trade trade,
    required TradeDeliveryMethod method,
    required String fullName,
    required String addressLine1,
    required String addressLine2,
    required String postalCode,
    required String city,
    required String country,
    required String phone,
    required String meetingDetails,
    required String carrier,
    required String trackingNumber,
    required String notes,
  }) async {
    final userId = currentUserId;
    final tradeReference = _db.collection('trades').doc(trade.id);
    final detailsReference = _detailsReference(
      tradeId: trade.id,
      userId: userId,
    );

    final normalized = <String, String>{
      'fullName': fullName.trim(),
      'addressLine1': addressLine1.trim(),
      'addressLine2': addressLine2.trim(),
      'postalCode': postalCode.trim(),
      'city': city.trim(),
      'country': country.trim(),
      'phone': phone.trim(),
      'meetingDetails': meetingDetails.trim(),
      'carrier': carrier.trim(),
      'trackingNumber': trackingNumber.trim(),
      'notes': notes.trim(),
    };

    _validateDetails(method: method, values: normalized);

    await _db.runTransaction((transaction) async {
      final tradeDocument = await transaction.get(tradeReference);
      final tradeData = tradeDocument.data();

      if (!tradeDocument.exists || tradeData == null) {
        throw StateError('trade_not_found');
      }

      final currentTrade = Trade.fromMap(tradeDocument.id, tradeData);

      if (currentTrade.status != TradeStatus.accepted) {
        throw StateError('trade_delivery_requires_accepted_trade');
      }

      if (currentTrade.senderId != userId &&
          currentTrade.receiverId != userId) {
        throw StateError('trade_participant_required');
      }

      final existingDocument = await transaction.get(detailsReference);
      final existingCreatedAt = existingDocument.data()?['createdAt'];
      final now = Timestamp.now();

      final values = <String, dynamic>{
        'userId': userId,
        'method': method.name,
        'fullName': method == TradeDeliveryMethod.mail
            ? normalized['fullName']
            : '',
        'addressLine1': method == TradeDeliveryMethod.mail
            ? normalized['addressLine1']
            : '',
        'addressLine2': method == TradeDeliveryMethod.mail
            ? normalized['addressLine2']
            : '',
        'postalCode': method == TradeDeliveryMethod.mail
            ? normalized['postalCode']
            : '',
        'city': method == TradeDeliveryMethod.mail ? normalized['city'] : '',
        'country': method == TradeDeliveryMethod.mail
            ? normalized['country']
            : '',
        'phone': normalized['phone'],
        'meetingDetails': method == TradeDeliveryMethod.inPerson
            ? normalized['meetingDetails']
            : '',
        'carrier': method == TradeDeliveryMethod.mail
            ? normalized['carrier']
            : '',
        'trackingNumber': method == TradeDeliveryMethod.mail
            ? normalized['trackingNumber']
            : '',
        'notes': normalized['notes'],
        'createdAt': existingCreatedAt is Timestamp ? existingCreatedAt : now,
        'updatedAt': now,
      };

      transaction.set(detailsReference, values);
    });
  }

  void _validateDetails({
    required TradeDeliveryMethod method,
    required Map<String, String> values,
  }) {
    for (final entry in values.entries) {
      final maximumLength =
          entry.key == 'notes' || entry.key == 'meetingDetails'
          ? notesMaximumLength
          : shortFieldMaximumLength;

      if (entry.value.length > maximumLength) {
        throw ArgumentError('delivery_field_too_long:${entry.key}');
      }
    }

    if (method == TradeDeliveryMethod.mail) {
      const requiredFields = [
        'fullName',
        'addressLine1',
        'postalCode',
        'city',
        'country',
      ];

      for (final field in requiredFields) {
        if (values[field]?.isEmpty ?? true) {
          throw ArgumentError('delivery_required_field:$field');
        }
      }
    }

    if (method == TradeDeliveryMethod.inPerson &&
        (values['meetingDetails']?.isEmpty ?? true)) {
      throw ArgumentError('delivery_required_field:meetingDetails');
    }
  }
}
