import 'package:ebus/features/route_management/domain/repositories/route_management_repository.dart';

class DeleteRouteUseCase {
  DeleteRouteUseCase(this._repository);

  final RouteManagementRepository _repository;

  Future<void> call(String routeId) {
    if (routeId.isEmpty) {
      throw ArgumentError('Route id is required');
    }
    return _repository.deleteRoute(routeId);
  }
}
