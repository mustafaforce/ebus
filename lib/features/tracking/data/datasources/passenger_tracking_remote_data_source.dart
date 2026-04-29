import 'package:ebus/features/tracking/data/models/passenger_tracking_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PassengerTrackingRemoteDataSource {
  PassengerTrackingRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<PassengerTrackingModel?> getTrackingByRoute(String routeId) async {
    final locationResult = await _client
        .from('bus_locations')
        .select('id, route_id, driver_id, current_stop_id, updated_at')
        .eq('route_id', routeId)
        .maybeSingle();

    if (locationResult == null) return null;

    final routeResult = await _client
        .from('routes')
        .select('id, name, description')
        .eq('id', routeId)
        .maybeSingle();

    if (routeResult == null) return null;

    final stopsResult = await _client
        .from('stops')
        .select('id, name, sequence_order')
        .eq('route_id', routeId)
        .order('sequence_order', ascending: true);

    final currentStopId = locationResult['current_stop_id'] as String;
    final currentStopResult = stopsResult.firstWhere(
      (s) => s['id'] == currentStopId,
      orElse: () => stopsResult.first,
    );

    final currentSeq = currentStopResult['sequence_order'] as int;
    String? nextStopName;
    if (currentSeq < stopsResult.length - 1) {
      nextStopName = stopsResult[currentSeq + 1]['name'] as String?;
    }

    Map<String, dynamic>? driverResult;
    try {
      driverResult = await _client
          .from('users')
          .select('full_name')
          .eq('id', locationResult['driver_id'] as String)
          .maybeSingle();
    } catch (_) {}

    return PassengerTrackingModel(
      routeId: routeResult['id'] as String,
      routeName: routeResult['name'] as String,
      routeDescription: routeResult['description'] as String?,
      currentStopId: currentStopResult['id'] as String,
      currentStopName: currentStopResult['name'] as String,
      currentStopSequence: currentSeq,
      totalStops: stopsResult.length,
      nextStopName: nextStopName,
      lastUpdated: DateTime.parse(locationResult['updated_at'] as String),
      driverName: driverResult?['full_name'] as String?,
    );
  }

  Future<List<Map<String, dynamic>>> getActiveRoutes() async {
    return await _client
        .from('routes')
        .select('id, name, description')
        .eq('is_active', true)
        .order('name', ascending: true);
  }
}