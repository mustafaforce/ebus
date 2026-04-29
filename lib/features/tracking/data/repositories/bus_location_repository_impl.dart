import 'package:ebus/core/network/supabase_client_provider.dart';
import 'package:ebus/features/tracking/data/datasources/bus_location_remote_data_source.dart';
import 'package:ebus/features/tracking/data/models/bus_location_model.dart';
import 'package:ebus/features/tracking/domain/repositories/bus_location_repository.dart';

class BusLocationRepositoryImpl implements BusLocationRepository {
  BusLocationRepositoryImpl();

  final _dataSource = BusLocationRemoteDataSource(SupabaseClientProvider.client);

  @override
  Future<void> updateBusLocation({
    required String routeId,
    required String driverId,
    required String currentStopId,
  }) {
    return _dataSource.upsertBusLocation(
      routeId: routeId,
      driverId: driverId,
      currentStopId: currentStopId,
    );
  }

  @override
  Future<BusLocationModel?> getBusLocation({
    required String routeId,
    required String driverId,
  }) {
    return _dataSource.getBusLocationByRouteAndDriver(
      routeId: routeId,
      driverId: driverId,
    );
  }

  @override
  Future<List<BusLocationModel>> getBusLocationsByRoute(String routeId) {
    return _dataSource.getBusLocationsByRoute(routeId);
  }
}