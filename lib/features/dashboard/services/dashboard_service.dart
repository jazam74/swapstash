import 'dart:async';

import 'package:swapstash/core/models/catalog_collection.dart';
import 'package:swapstash/core/models/collection_statistics.dart';
import 'package:swapstash/core/models/conversation.dart';
import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/core/models/user_collection.dart';
import 'package:swapstash/core/services/catalog_service.dart';
import 'package:swapstash/core/services/chat_service.dart';
import 'package:swapstash/core/services/collection_statistics_service.dart';
import 'package:swapstash/core/services/trade_service.dart';
import 'package:swapstash/core/services/user_collection_service.dart';
import 'package:swapstash/features/dashboard/models/dashboard_action.dart';
import 'package:swapstash/features/dashboard/models/dashboard_data.dart';
import 'package:swapstash/features/dashboard/services/dashboard_message_action_mapper.dart';
import 'package:swapstash/features/dashboard/services/dashboard_trade_action_mapper.dart';

class DashboardService {
  final UserCollectionService _userCollectionService;
  final CatalogService _catalogService;
  final CollectionStatisticsService _collectionStatisticsService;
  final TradeService _tradeService;
  final ChatService _chatService;

  DashboardService({
    UserCollectionService? userCollectionService,
    CatalogService? catalogService,
    CollectionStatisticsService? collectionStatisticsService,
    TradeService? tradeService,
    ChatService? chatService,
  }) : _userCollectionService =
           userCollectionService ?? UserCollectionService(),
       _catalogService = catalogService ?? CatalogService(),
       _collectionStatisticsService =
           collectionStatisticsService ?? CollectionStatisticsService(),
       _tradeService = tradeService ?? TradeService(),
       _chatService = chatService ?? ChatService();

  Stream<DashboardData> watchDashboard() {
    late final StreamController<DashboardData> controller;

    StreamSubscription<List<UserCollection>>? collectionsSubscription;
    StreamSubscription<List<Trade>>? incomingTradesSubscription;
    StreamSubscription<List<Trade>>? outgoingTradesSubscription;
    StreamSubscription<List<Conversation>>? conversationsSubscription;

    final statisticsSubscriptions =
        <StreamSubscription<CollectionStatistics>>[];

    List<CollectionStatistics> latestStatistics = const [];
    List<Trade> latestIncomingTrades = const [];
    List<Trade> latestOutgoingTrades = const [];
    List<Conversation> latestConversations = const [];

    var collectionsReady = false;
    var incomingTradesReady = false;
    var outgoingTradesReady = false;
    var conversationsReady = false;
    var generation = 0;

    void emitDashboardWhenReady() {
      if (controller.isClosed ||
          !collectionsReady ||
          !incomingTradesReady ||
          !outgoingTradesReady ||
          !conversationsReady) {
        return;
      }

      final tradeActions = DashboardTradeActionMapper.build(
        incomingTrades: latestIncomingTrades,
        outgoingTrades: latestOutgoingTrades,
        currentUserId: _tradeService.currentUserId,
        limit: 50,
      );

      final messageActions = DashboardMessageActionMapper.build(
        conversations: latestConversations,
        currentUserId: _chatService.currentUserId,
        limit: 50,
      );

      final actions = <DashboardAction>[...tradeActions, ...messageActions]
        ..sort((first, second) {
          final priorityComparison = first.priority.compareTo(second.priority);

          if (priorityComparison != 0) {
            return priorityComparison;
          }

          final firstDate =
              first.sortAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final secondDate =
              second.sortAt ?? DateTime.fromMillisecondsSinceEpoch(0);

          return secondDate.compareTo(firstDate);
        });

      controller.add(
        DashboardData.fromStatistics(
          latestStatistics,
          actions: actions.take(5).toList(growable: false),
        ),
      );
    }

    Future<void> cancelStatisticsSubscriptions() async {
      final subscriptions = List<StreamSubscription<CollectionStatistics>>.from(
        statisticsSubscriptions,
      );

      statisticsSubscriptions.clear();

      await Future.wait(
        subscriptions.map((subscription) => subscription.cancel()),
      );
    }

    Future<void> handleCollections(List<UserCollection> userCollections) async {
      final currentGeneration = ++generation;

      collectionsReady = false;
      latestStatistics = const [];

      await cancelStatisticsSubscriptions();

      if (controller.isClosed || currentGeneration != generation) {
        return;
      }

      if (userCollections.isEmpty) {
        collectionsReady = true;
        emitDashboardWhenReady();
        return;
      }

      try {
        final loadedCollections = await Future.wait(
          userCollections.map(
            (userCollection) => _catalogService.getCollection(
              userCollection.catalogCollectionId,
            ),
          ),
        );

        if (controller.isClosed || currentGeneration != generation) {
          return;
        }

        final catalogCollections = loadedCollections
            .whereType<CatalogCollection>()
            .toList();

        if (catalogCollections.isEmpty) {
          collectionsReady = true;
          emitDashboardWhenReady();
          return;
        }

        final statisticsById = <String, CollectionStatistics>{};

        void emitStatisticsWhenReady() {
          if (controller.isClosed ||
              currentGeneration != generation ||
              statisticsById.length != catalogCollections.length) {
            return;
          }

          latestStatistics = [
            for (final collection in catalogCollections)
              statisticsById[collection.id]!,
          ];

          collectionsReady = true;
          emitDashboardWhenReady();
        }

        for (final collection in catalogCollections) {
          final subscription = _collectionStatisticsService
              .watchStatistics(collection: collection)
              .listen(
                (statistics) {
                  if (currentGeneration != generation) {
                    return;
                  }

                  statisticsById[collection.id] = statistics;
                  emitStatisticsWhenReady();
                },
                onError: (Object error, StackTrace stackTrace) {
                  if (!controller.isClosed && currentGeneration == generation) {
                    controller.addError(error, stackTrace);
                  }
                },
              );

          statisticsSubscriptions.add(subscription);
        }
      } catch (error, stackTrace) {
        if (!controller.isClosed && currentGeneration == generation) {
          controller.addError(error, stackTrace);
        }
      }
    }

    void addStreamError(Object error, StackTrace stackTrace) {
      if (!controller.isClosed) {
        controller.addError(error, stackTrace);
      }
    }

    controller = StreamController<DashboardData>(
      onListen: () {
        try {
          collectionsSubscription = _userCollectionService
              .watchCollections()
              .listen((collections) {
                unawaited(handleCollections(collections));
              }, onError: addStreamError);

          incomingTradesSubscription = _tradeService
              .watchIncomingTrades()
              .listen((trades) {
                latestIncomingTrades = trades;
                incomingTradesReady = true;
                emitDashboardWhenReady();
              }, onError: addStreamError);

          outgoingTradesSubscription = _tradeService
              .watchOutgoingTrades()
              .listen((trades) {
                latestOutgoingTrades = trades;
                outgoingTradesReady = true;
                emitDashboardWhenReady();
              }, onError: addStreamError);

          conversationsSubscription = _chatService.watchConversations().listen((
            conversations,
          ) {
            latestConversations = conversations;
            conversationsReady = true;
            emitDashboardWhenReady();
          }, onError: addStreamError);
        } catch (error, stackTrace) {
          controller.addError(error, stackTrace);
        }
      },
      onCancel: () async {
        generation++;

        await collectionsSubscription?.cancel();
        await incomingTradesSubscription?.cancel();
        await outgoingTradesSubscription?.cancel();
        await conversationsSubscription?.cancel();
        await cancelStatisticsSubscriptions();
      },
    );

    return controller.stream;
  }
}
