import 'dart:async';

import 'package:swapstash/core/models/catalog_collection.dart';
import 'package:swapstash/core/models/collection_statistics.dart';
import 'package:swapstash/core/models/user_collection.dart';
import 'package:swapstash/core/services/catalog_service.dart';
import 'package:swapstash/core/services/collection_statistics_service.dart';
import 'package:swapstash/core/services/user_collection_service.dart';
import 'package:swapstash/features/dashboard/models/dashboard_data.dart';

class DashboardService {
  final UserCollectionService _userCollectionService;
  final CatalogService _catalogService;
  final CollectionStatisticsService _collectionStatisticsService;

  DashboardService({
    UserCollectionService? userCollectionService,
    CatalogService? catalogService,
    CollectionStatisticsService? collectionStatisticsService,
  }) : _userCollectionService =
           userCollectionService ?? UserCollectionService(),
       _catalogService = catalogService ?? CatalogService(),
       _collectionStatisticsService =
           collectionStatisticsService ?? CollectionStatisticsService();

  Stream<DashboardData> watchDashboard() {
    late final StreamController<DashboardData> controller;

    StreamSubscription<List<UserCollection>>? collectionsSubscription;
    final statisticsSubscriptions =
        <StreamSubscription<CollectionStatistics>>[];

    var generation = 0;

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

      await cancelStatisticsSubscriptions();

      if (controller.isClosed || currentGeneration != generation) {
        return;
      }

      if (userCollections.isEmpty) {
        controller.add(DashboardData.empty());
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
          controller.add(DashboardData.empty());
          return;
        }

        final statisticsById = <String, CollectionStatistics>{};

        void emitWhenReady() {
          if (controller.isClosed ||
              currentGeneration != generation ||
              statisticsById.length != catalogCollections.length) {
            return;
          }

          final orderedStatistics = [
            for (final collection in catalogCollections)
              statisticsById[collection.id]!,
          ];

          controller.add(DashboardData.fromStatistics(orderedStatistics));
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
                  emitWhenReady();
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

    controller = StreamController<DashboardData>(
      onListen: () {
        collectionsSubscription = _userCollectionService
            .watchCollections()
            .listen(
              (collections) {
                unawaited(handleCollections(collections));
              },
              onError: (Object error, StackTrace stackTrace) {
                if (!controller.isClosed) {
                  controller.addError(error, stackTrace);
                }
              },
            );
      },
      onCancel: () async {
        generation++;
        await collectionsSubscription?.cancel();
        await cancelStatisticsSubscriptions();
      },
    );

    return controller.stream;
  }
}
