import 'package:ebus/features/route_management/domain/entities/new_route.dart';

abstract class RouteManagementRepository {
  Future<String> createRouteWithStops(NewRoute route);
  Future<void> updateRouteWithStops(String routeId, NewRoute route);
  Future<void> deleteRoute(String routeId);
}
