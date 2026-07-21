import 'package:swapstash/core/services/collection_service.dart';
import 'package:swapstash/features/dashboard/models/dashboard_data.dart';

class DashboardService {
  final CollectionService _collectionService;

  DashboardService({CollectionService? collectionService})
    : _collectionService = collectionService ?? CollectionService();

  Stream<DashboardData> watchDashboard() {
    return _collectionService.watchCollections().map(
      DashboardData.fromCollections,
    );
  }
}
