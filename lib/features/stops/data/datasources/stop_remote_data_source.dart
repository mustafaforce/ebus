import 'package:ebus/features/stops/data/models/stop_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StopRemoteDataSource {
  StopRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<List<StopModel>> getStopsByRoute(String routeId) async {
    final List<Map<String, dynamic>> maps = await _client
        .from('stops')
        .select('id, route_id, name, sequence_order, created_at, updated_at')
        .eq('route_id', routeId)
        .order('sequence_order', ascending: true);

    return maps.map((map) => StopModel.fromDatabase(map)).toList();
  }
}