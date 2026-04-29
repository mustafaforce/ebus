import 'package:ebus/features/route_list/data/models/route_with_stops_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RouteListRemoteDataSource {
  RouteListRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<List<RouteWithStopsModel>> getRoutesWithStops() async {
    final routesResult = await _client
        .from('routes')
        .select('id, name, description')
        .eq('is_active', true)
        .order('name', ascending: true);

    final List<RouteWithStopsModel> result = [];

    for (final route in routesResult) {
      final stopsResult = await _client
          .from('stops')
          .select('id, name, sequence_order')
          .eq('route_id', route['id'] as String)
          .order('sequence_order', ascending: true);

      final stops = stopsResult.map((s) => StopInfo(
        stopId: s['id'] as String,
        stopName: s['name'] as String,
        sequenceOrder: s['sequence_order'] as int,
      )).toList();

      result.add(RouteWithStopsModel(
        routeId: route['id'] as String,
        routeName: route['name'] as String,
        routeDescription: route['description'] as String?,
        stops: stops,
      ));
    }

    return result;
  }
}