import 'package:cloud_firestore/cloud_firestore.dart';

enum TradeDeliveryMethod { mail, inPerson }

class TradeDeliveryDetails {
  final String userId;
  final TradeDeliveryMethod method;
  final String fullName;
  final String addressLine1;
  final String addressLine2;
  final String postalCode;
  final String city;
  final String country;
  final String phone;
  final String meetingDetails;
  final String carrier;
  final String trackingNumber;
  final String notes;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const TradeDeliveryDetails({
    required this.userId,
    required this.method,
    required this.fullName,
    required this.addressLine1,
    required this.addressLine2,
    required this.postalCode,
    required this.city,
    required this.country,
    required this.phone,
    required this.meetingDetails,
    required this.carrier,
    required this.trackingNumber,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TradeDeliveryDetails.fromMap(
    String documentId,
    Map<String, dynamic> map,
  ) {
    final methodName = map['method']?.toString() ?? '';

    return TradeDeliveryDetails(
      userId: map['userId']?.toString().trim().isNotEmpty == true
          ? map['userId'].toString().trim()
          : documentId,
      method: TradeDeliveryMethod.values.firstWhere(
        (value) => value.name == methodName,
        orElse: () => TradeDeliveryMethod.mail,
      ),
      fullName: map['fullName']?.toString() ?? '',
      addressLine1: map['addressLine1']?.toString() ?? '',
      addressLine2: map['addressLine2']?.toString() ?? '',
      postalCode: map['postalCode']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      country: map['country']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      meetingDetails: map['meetingDetails']?.toString() ?? '',
      carrier: map['carrier']?.toString() ?? '',
      trackingNumber: map['trackingNumber']?.toString() ?? '',
      notes: map['notes']?.toString() ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? map['createdAt'] as Timestamp
          : Timestamp.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? map['updatedAt'] as Timestamp
          : Timestamp.now(),
    );
  }

  bool get hasTrackingNumber => trackingNumber.trim().isNotEmpty;

  String get formattedAddress {
    final lines = <String>[
      if (fullName.trim().isNotEmpty) fullName.trim(),
      if (addressLine1.trim().isNotEmpty) addressLine1.trim(),
      if (addressLine2.trim().isNotEmpty) addressLine2.trim(),
      [
        if (postalCode.trim().isNotEmpty) postalCode.trim(),
        if (city.trim().isNotEmpty) city.trim(),
      ].join(' ').trim(),
      if (country.trim().isNotEmpty) country.trim(),
    ].where((line) => line.isNotEmpty).toList(growable: false);

    return lines.join('\n');
  }
}
