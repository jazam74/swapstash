class CatalogItem {
  final String id;
  final String collectionId;
  final String number;
  final String name;
  final String imageUrl;

  /// Ohranjen zaradi združljivosti z obstoječimi podatki in prikazom kartic.
  final String rarity;

  /// Poljubne lastnosti predmeta, na primer:
  /// {'country': 'Slovenija', 'year': '2007', 'type': 'Kovanec'}
  final Map<String, String> attributes;

  const CatalogItem({
    required this.id,
    required this.collectionId,
    required this.number,
    required this.name,
    required this.imageUrl,
    this.rarity = '',
    this.attributes = const {},
  });

  factory CatalogItem.fromMap(String id, Map<String, dynamic> map) {
    final attributes = _parseAttributes(map['attributes']);
    final storedRarity = map['rarity']?.toString().trim() ?? '';
    final rarityFromAttributes = _findAttribute(attributes, 'rarity');

    final effectiveRarity = storedRarity.isNotEmpty
        ? storedRarity
        : rarityFromAttributes;

    if (effectiveRarity.isNotEmpty &&
        !_containsAttributeKey(attributes, 'rarity')) {
      attributes['rarity'] = effectiveRarity;
    }

    return CatalogItem(
      id: id,
      collectionId: map['collectionId']?.toString() ?? '',
      number: map['number']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      rarity: effectiveRarity,
      attributes: Map.unmodifiable(attributes),
    );
  }

  String attributeValue(String key) {
    return _findAttribute(attributes, key);
  }

  bool hasAttribute(String key) {
    return attributeValue(key).isNotEmpty;
  }

  Map<String, dynamic> toMap() {
    final storedAttributes = Map<String, String>.from(attributes);

    if (rarity.trim().isNotEmpty &&
        !_containsAttributeKey(storedAttributes, 'rarity')) {
      storedAttributes['rarity'] = rarity.trim();
    }

    return {
      'collectionId': collectionId,
      'number': number,
      'name': name,
      'imageUrl': imageUrl,
      'rarity': rarity,
      'attributes': storedAttributes,
    };
  }

  static Map<String, String> _parseAttributes(dynamic rawAttributes) {
    if (rawAttributes is! Map) {
      return <String, String>{};
    }

    final result = <String, String>{};

    for (final entry in rawAttributes.entries) {
      final key = entry.key.toString().trim();
      final value = entry.value?.toString().trim() ?? '';

      if (key.isEmpty || value.isEmpty) {
        continue;
      }

      result[key] = value;
    }

    return result;
  }

  static bool _containsAttributeKey(
    Map<String, String> attributes,
    String requestedKey,
  ) {
    final normalizedRequestedKey = requestedKey.trim().toLowerCase();

    return attributes.keys.any(
      (key) => key.trim().toLowerCase() == normalizedRequestedKey,
    );
  }

  static String _findAttribute(
    Map<String, String> attributes,
    String requestedKey,
  ) {
    final normalizedRequestedKey = requestedKey.trim().toLowerCase();

    for (final entry in attributes.entries) {
      if (entry.key.trim().toLowerCase() == normalizedRequestedKey) {
        return entry.value.trim();
      }
    }

    return '';
  }
}
