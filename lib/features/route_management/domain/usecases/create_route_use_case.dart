import 'package:ebus/features/route_management/domain/entities/new_route.dart';
import 'package:ebus/features/route_management/domain/repositories/route_management_repository.dart';

class CreateRouteUseCase {
  CreateRouteUseCase(this._repository);

  final RouteManagementRepository _repository;

  Future<String> call(NewRoute route) {
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
    return _repository.createRouteWithStops(route);
  }
}
