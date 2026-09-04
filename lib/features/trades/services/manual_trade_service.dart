import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapstash/core/models/catalog_collection.dart';
import 'package:swapstash/core/models/catalog_item.dart';
import 'package:swapstash/core/models/user_item.dart';
import 'package:swapstash/core/services/catalog_item_service.dart';
import 'package:swapstash/core/services/catalog_service.dart';
import 'package:swapstash/core/services/trade_service.dart';
import 'package:swapstash/core/services/user_item_service.dart';
import 'package:swapstash/features/trades/models/manual_trade_data.dart';

class ManualTradeService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final CatalogService _catalogService;
  final CatalogItemService _catalogItemService;
  final UserItemService _userItemService;
  final TradeService _tradeService;

  ManualTradeService({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
    CatalogService? catalogService,
    CatalogItemService? catalogItemService,
    UserItemService? userItemService,
    TradeService? tradeService,
  }) : _db = db ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _catalogService = catalogService ?? CatalogService(),
       _catalogItemService = catalogItemService ?? CatalogItemService(),
       _userItemService = userItemService ?? UserItemService(),
       _tradeService = tradeService ?? TradeService();

  String get _currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('user_not_logged_in');
    }

    return user.uid;
  }

  Future<ManualTradeData> loadOptions({required String otherUserId}) async {
    final currentUserId = _currentUserId;
    final receiverId = otherUserId.trim();

    if (receiverId.isEmpty) {
      throw ArgumentError('receiver_missing');
    }

    if (receiverId == currentUserId) {
      throw ArgumentError('receiver_is_current_user');
    }

    final currentCollectionsSnapshot = await _db
        .collection('users')
        .doc(currentUserId)
        .collection('collections')
        .get();

    final currentCollectionIds = currentCollectionsSnapshot.docs
        .map((document) => document.id.trim())
        .where((id) => id.isNotEmpty)
        .toList(growable: false);

    if (currentCollectionIds.isEmpty) {
      return const ManualTradeData(collections: [], commonCollectionCount: 0);
    }

    final receiverCollectionDocuments = await Future.wait(
      currentCollectionIds.map(
        (collectionId) => _db
            .collection('users')
            .doc(receiverId)
            .collection('collections')
            .doc(collectionId)
            .get(),
      ),
    );

    final commonCollectionIds = <String>[];

    for (var index = 0; index < currentCollectionIds.length; index++) {
      if (receiverCollectionDocuments[index].exists) {
        commonCollectionIds.add(currentCollectionIds[index]);
      }
    }

    if (commonCollectionIds.isEmpty) {
      return const ManualTradeData(collections: [], commonCollectionCount: 0);
    }

    final reservationResults = await Future.wait([
      _tradeService.getActiveReservations(
        userId: currentUserId,
        collectionIds: commonCollectionIds,
      ),
      _tradeService.getActiveReservations(
        userId: receiverId,
        collectionIds: commonCollectionIds,
      ),
    ]);

    final currentReservations = reservationResults[0];
    final receiverReservations = reservationResults[1];

    final collectionOptions = await Future.wait(
      commonCollectionIds.map(
        (collectionId) => _loadCollectionOptions(
          collectionId: collectionId,
          currentUserId: currentUserId,
          receiverId: receiverId,
          currentReservations: currentReservations,
          receiverReservations: receiverReservations,
        ),
      ),
    );

    final availableCollections =
        collectionOptions
            .whereType<ManualTradeCollectionOptions>()
            .where((entry) => entry.hasAnyItems)
            .toList(growable: false)
          ..sort(
            (first, second) => first.collection.name.toLowerCase().compareTo(
              second.collection.name.toLowerCase(),
            ),
          );

    return ManualTradeData(
      collections: availableCollections,
      commonCollectionCount: commonCollectionIds.length,
    );
  }

  Future<ManualTradeCollectionOptions?> _loadCollectionOptions({
    required String collectionId,
    required String currentUserId,
    required String receiverId,
    required TradeReservations currentReservations,
    required TradeReservations receiverReservations,
  }) async {
    final results = await Future.wait([
      _catalogService.getCollection(collectionId),
      _catalogItemService.getItems(collectionId),
      _userItemService.getItemsMap(
        userId: currentUserId,
        collectionId: collectionId,
      ),
      _userItemService.getItemsMap(
        userId: receiverId,
        collectionId: collectionId,
      ),
    ]);

    final collection = results[0] as CatalogCollection?;
    final catalogItems = results[1] as List<CatalogItem>;
    final currentInventory = results[2] as Map<String, UserItem>;
    final receiverInventory = results[3] as Map<String, UserItem>;

    if (collection == null) {
      return null;
    }

    final currentUserCanOffer = <ManualTradeItemOption>[];
    final otherUserCanOffer = <ManualTradeItemOption>[];
    final allCurrentUserCanOffer = <ManualTradeItemOption>[];
    final allOtherUserCanOffer = <ManualTradeItemOption>[];

    for (final item in catalogItems) {
      final currentAvailable = _availableSurplus(
        inventory: currentInventory,
        item: item,
        reservations: currentReservations,
        collectionId: collectionId,
      );

      if (currentAvailable > 0) {
        final option = ManualTradeItemOption(
          collection: collection,
          item: item,
          availableQuantity: currentAvailable,
        );

        allCurrentUserCanOffer.add(option);

        if (_stillNeedsItem(
          inventory: receiverInventory,
          item: item,
          reservations: receiverReservations,
          collectionId: collectionId,
        )) {
          currentUserCanOffer.add(option);
        }
      }

      final receiverAvailable = _availableSurplus(
        inventory: receiverInventory,
        item: item,
        reservations: receiverReservations,
        collectionId: collectionId,
      );

      if (receiverAvailable > 0) {
        final option = ManualTradeItemOption(
          collection: collection,
          item: item,
          availableQuantity: receiverAvailable,
        );

        allOtherUserCanOffer.add(option);

        if (_stillNeedsItem(
          inventory: currentInventory,
          item: item,
          reservations: currentReservations,
          collectionId: collectionId,
        )) {
          otherUserCanOffer.add(option);
        }
      }
    }

    currentUserCanOffer.sort(_compareItems);
    otherUserCanOffer.sort(_compareItems);
    allCurrentUserCanOffer.sort(_compareItems);
    allOtherUserCanOffer.sort(_compareItems);

    return ManualTradeCollectionOptions(
      collection: collection,
      currentUserCanOffer: currentUserCanOffer,
      otherUserCanOffer: otherUserCanOffer,
      allCurrentUserCanOffer: allCurrentUserCanOffer,
      allOtherUserCanOffer: allOtherUserCanOffer,
    );
  }

  bool _stillNeedsItem({
    required Map<String, UserItem> inventory,
    required CatalogItem item,
    required TradeReservations reservations,
    required String collectionId,
  }) {
    final quantity = _storedQuantity(inventory: inventory, item: item);

    if (quantity > 0) {
      return false;
    }

    return reservations.incomingQuantity(
          collectionId: collectionId,
          itemNumber: item.number,
        ) ==
        0;
  }

  int _availableSurplus({
    required Map<String, UserItem> inventory,
    required CatalogItem item,
    required TradeReservations reservations,
    required String collectionId,
  }) {
    final quantity = _storedQuantity(inventory: inventory, item: item);

    final reserved = reservations.outgoingQuantity(
      collectionId: collectionId,
      itemNumber: item.number,
    );

    final available = quantity - 1 - reserved;

    return available > 0 ? available : 0;
  }

  int _storedQuantity({
    required Map<String, UserItem> inventory,
    required CatalogItem item,
  }) {
    final directMatch =
        inventory[item.id] ??
        inventory[item.number] ??
        inventory[item.id.trim()] ??
        inventory[item.number.trim()];

    if (directMatch != null) {
      return directMatch.quantity;
    }

    String normalize(String value) {
      final normalized = value.trim().toLowerCase();
      final numericValue = int.tryParse(normalized);

      return numericValue?.toString() ?? normalized;
    }

    final itemIdentities = {normalize(item.id), normalize(item.number)};

    for (final entry in inventory.entries) {
      if (itemIdentities.contains(normalize(entry.key)) ||
          itemIdentities.contains(normalize(entry.value.itemId))) {
        return entry.value.quantity;
      }
    }

    return 0;
  }

  int _compareItems(ManualTradeItemOption first, ManualTradeItemOption second) {
    final numberComparison = first.item.number.toLowerCase().compareTo(
      second.item.number.toLowerCase(),
    );

    if (numberComparison != 0) {
      return numberComparison;
    }

    return first.item.name.toLowerCase().compareTo(
      second.item.name.toLowerCase(),
    );
  }
}
