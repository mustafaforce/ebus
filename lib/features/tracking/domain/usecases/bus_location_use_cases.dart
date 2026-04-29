import 'package:ebus/features/tracking/domain/repositories/bus_location_repository.dart';

class UpdateBusLocationUseCase {
  UpdateBusLocationUseCase(this._repository);

  final BusLocationRepository _repository;

  Future<void> call({
    required String routeId,
    required String driverId,
    required String currentStopId,
  }) {
    return _repository.updateBusLocation(
      routeId: routeId,
      driverId: driverId,
      currentStopId: currentStopId,
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