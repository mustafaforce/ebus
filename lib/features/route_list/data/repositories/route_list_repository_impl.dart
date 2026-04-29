import 'package:ebus/core/network/supabase_client_provider.dart';
import 'package:ebus/features/route_list/data/datasources/route_list_remote_data_source.dart';
import 'package:ebus/features/route_list/data/models/route_with_stops_model.dart';
import 'package:ebus/features/route_list/domain/repositories/route_list_repository.dart';

class RouteListRepositoryImpl implements RouteListRepository {
  RouteListRepositoryImpl();

  final _dataSource = RouteListRemoteDataSource(SupabaseClientProvider.client);

  @override
  Future<List<RouteWithStopsModel>> getRoutesWithStops() {
    return _dataSource.getRoutesWithStops();
  }
}