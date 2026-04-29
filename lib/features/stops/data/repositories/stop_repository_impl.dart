import 'package:ebus/core/network/supabase_client_provider.dart';
import 'package:ebus/features/stops/data/datasources/stop_remote_data_source.dart';
import 'package:ebus/features/stops/data/models/stop_model.dart';
import 'package:ebus/features/stops/domain/repositories/stop_repository.dart';

class StopRepositoryImpl implements StopRepository {
  StopRepositoryImpl();

  final _dataSource = StopRemoteDataSource(SupabaseClientProvider.client);

  @override
  Future<List<StopModel>> getStopsByRoute(String routeId) {
    return _dataSource.getStopsByRoute(routeId);
  }
}