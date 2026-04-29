import 'package:ebus/core/network/supabase_client_provider.dart';
import 'package:ebus/features/tracking/data/datasources/passenger_tracking_remote_data_source.dart';
import 'package:ebus/features/tracking/data/models/passenger_tracking_model.dart';
import 'package:ebus/features/tracking/domain/repositories/passenger_tracking_repository.dart';

class PassengerTrackingRepositoryImpl implements PassengerTrackingRepository {
  PassengerTrackingRepositoryImpl();

  final _dataSource =
      PassengerTrackingRemoteDataSource(SupabaseClientProvider.client);

  @override
  Future<PassengerTrackingModel?> getTrackingByRoute(String routeId) {
    return _dataSource.getTrackingByRoute(routeId);
  }

  @override
  Future<List<Map<String, dynamic>>> getActiveRoutes() {
    return _dataSource.getActiveRoutes();
  }
}