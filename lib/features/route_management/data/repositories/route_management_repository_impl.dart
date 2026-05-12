import 'package:ebus/core/network/supabase_client_provider.dart';
import 'package:ebus/features/route_management/data/datasources/route_management_remote_data_source.dart';
import 'package:ebus/features/route_management/domain/entities/new_route.dart';
import 'package:ebus/features/route_management/domain/repositories/route_management_repository.dart';

class RouteManagementRepositoryImpl implements RouteManagementRepository {
  RouteManagementRepositoryImpl();

  final _dataSource =
      RouteManagementRemoteDataSource(SupabaseClientProvider.client);

  @override
  Future<String> createRouteWithStops(NewRoute route) {
    return _dataSource.createRouteWithStops(route);
  }

  @override
  Future<void> updateRouteWithStops(String routeId, NewRoute route) {
    return _dataSource.updateRouteWithStops(routeId, route);
  }

  @override
  Future<void> deleteRoute(String routeId) {
    return _dataSource.deleteRoute(routeId);
  }
}
