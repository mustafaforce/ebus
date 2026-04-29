import 'package:ebus/features/tracking/data/models/bus_location_model.dart';

abstract class BusLocationRepository {
  Future<void> updateBusLocation({
    required String routeId,
    required String driverId,
    required String currentStopId,
  });

  Future<BusLocationModel?> getBusLocation({
    required String routeId,
    required String driverId,
  });

  Future<List<BusLocationModel>> getBusLocationsByRoute(String routeId);
}