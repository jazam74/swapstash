import 'package:cloud_firestore/cloud_firestore.dart';

class CatalogCollection {
  final String id;
  final String name;
  final String publisher;
  final String category;
  final int year;
  final int totalItems;
  final String coverImageUrl;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CatalogCollection({
    required this.id,
    required this.name,
    required this.publisher,
    required this.category,
    required this.year,
    required this.totalItems,
    required this.coverImageUrl,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory CatalogCollection.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return CatalogCollection(
      id: id,
      name: map['name'] as String? ?? '',
      publisher: map['publisher'] as String? ?? '',
      category: map['category'] as String? ?? '',
      year: (map['year'] as num?)?.toInt() ?? 0,
      totalItems: (map['totalItems'] as num?)?.toInt() ?? 0,
      coverImageUrl: map['coverImageUrl'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
      createdAt: _dateTimeFromValue(map['createdAt']),
      updatedAt: _dateTimeFromValue(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'publisher': publisher,
      'category': category,
      'year': year,
      'totalItems': totalItems,
      'coverImageUrl': coverImageUrl,
      'isActive': isActive,
      'createdAt': createdAt == null
          ? null
          : Timestamp.fromDate(createdAt!),
      'updatedAt': updatedAt == null
          ? null
          : Timestamp.fromDate(updatedAt!),
    };
  }

  CatalogCollection copyWith({
    String? id,
    String? name,
    String? publisher,
    String? category,
    int? year,
    int? totalItems,
    String? coverImageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CatalogCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      publisher: publisher ?? this.publisher,
      category: category ?? this.category,
      year: year ?? this.year,
      totalItems: totalItems ?? this.totalItems,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _dateTimeFromValue(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}