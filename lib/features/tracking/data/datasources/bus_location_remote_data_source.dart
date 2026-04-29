import 'package:ebus/features/tracking/data/models/bus_location_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusLocationRemoteDataSource {
  BusLocationRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<void> upsertBusLocation({
    required String routeId,
    required String driverId,
    required String currentStopId,
  }) async {
    await _client.from('bus_locations').upsert(
      {
        'route_id': routeId,
        'driver_id': driverId,
        'current_stop_id': currentStopId,
      },
      onConflict: 'route_id,driver_id',
    );
  }

  Future<BusLocationModel?> getBusLocationByRouteAndDriver({
    required String routeId,
    required String driverId,
  }) async {
    final Map<String, dynamic>? map = await _client
        .from('bus_locations')
        .select('id, route_id, driver_id, current_stop_id, updated_at')
        .eq('route_id', routeId)
        .eq('driver_id', driverId)
        .maybeSingle();

    if (map == null) return null;
    return BusLocationModel.fromDatabase(map);
  }

  Future<List<BusLocationModel>> getBusLocationsByRoute(String routeId) async {
    final List<Map<String, dynamic>> maps = await _client
        .from('bus_locations')
        .select('id, route_id, driver_id, current_stop_id, updated_at')
        .eq('route_id', routeId);

    return maps.map((map) => BusLocationModel.fromDatabase(map)).toList();
  }
}