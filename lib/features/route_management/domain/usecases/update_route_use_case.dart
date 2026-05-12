import 'package:ebus/features/route_management/domain/entities/new_route.dart';
import 'package:ebus/features/route_management/domain/repositories/route_management_repository.dart';

class UpdateRouteUseCase {
  UpdateRouteUseCase(this._repository);

  final RouteManagementRepository _repository;

  Future<void> call(String routeId, NewRoute route) {
    if (routeId.isEmpty) {
      throw ArgumentError('Route id is required');
    }
    if (route.name.trim().isEmpty) {
      throw ArgumentError('Route name is required');
    }
    if (route.stops.isEmpty) {
      throw ArgumentError('At least one stop is required');
    }
    for (final stop in route.stops) {
      if (stop.name.trim().isEmpty) {
        throw ArgumentError('Stop name cannot be empty');
      }
    }
    return _repository.updateRouteWithStops(routeId, route);
  }
}
