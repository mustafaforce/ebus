import 'package:ebus/features/tracking/data/models/passenger_tracking_model.dart';
import 'package:ebus/features/tracking/domain/repositories/passenger_tracking_repository.dart';

class GetTrackingByRouteUseCase {
  GetTrackingByRouteUseCase(this._repository);

  final PassengerTrackingRepository _repository;

  Future<PassengerTrackingModel?> call(String routeId) {
    return _repository.getTrackingByRoute(routeId);
  }
}

class GetActiveRoutesUseCase {
  GetActiveRoutesUseCase(this._repository);

  final PassengerTrackingRepository _repository;

  Future<List<Map<String, dynamic>>> call() {
    return _repository.getActiveRoutes();
  }
}