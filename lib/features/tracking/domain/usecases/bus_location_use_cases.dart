import 'package:ebus/features/tracking/domain/repositories/bus_location_repository.dart';

class UpdateBusLocationUseCase {
  UpdateBusLocationUseCase(this._repository);

  final BusLocationRepository _repository;

  Future<void> call({
    required String routeId,
    required String driverId,
    required String currentStopId,
    double? estimatedDistance,
    int? estimatedTimeMinutes,
  }) {
    return _repository.updateBusLocation(
      routeId: routeId,
      driverId: driverId,
      currentStopId: currentStopId,
      estimatedDistance: estimatedDistance,
      estimatedTimeMinutes: estimatedTimeMinutes,
    );
  }
}

class GetBusLocationUseCase {
  GetBusLocationUseCase(this._repository);

  final BusLocationRepository _repository;

  Future<dynamic> call({
    required String routeId,
    required String driverId,
  }) {
    return _repository.getBusLocation(
      routeId: routeId,
      driverId: driverId,
    );
  }
}