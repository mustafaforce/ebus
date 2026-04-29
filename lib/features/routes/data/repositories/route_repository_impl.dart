import 'package:ebus/core/network/supabase_client_provider.dart';
import 'package:ebus/features/routes/data/models/route_model.dart';
import 'package:ebus/features/routes/domain/repositories/route_repository.dart';

class RouteRepositoryImpl implements RouteRepository {
  RouteRepositoryImpl();

  final _dataSource = RouteRemoteDataSource(SupabaseClientProvider.client);

  @override
  Future<List<RouteModel>> getActiveRoutes() {
    return _dataSource.getActiveRoutes();
  }
}