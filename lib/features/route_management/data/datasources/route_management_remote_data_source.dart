import 'package:ebus/features/route_management/domain/entities/new_route.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RouteManagementRemoteDataSource {
  RouteManagementRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<String> createRouteWithStops(NewRoute route) async {
    final Map<String, dynamic> routeInsert = await _client
        .from('routes')
        .insert({
          'name': route.name.trim(),
          if (route.description != null && route.description!.trim().isNotEmpty)
            'description': route.description!.trim(),
          'is_active': true,
        })
        .select('id')
        .single();

    final String routeId = routeInsert['id'] as String;

    final List<Map<String, dynamic>> stopRows = route.stops
        .map((s) => {
              'route_id': routeId,
              'name': s.name.trim(),
              'sequence_order': s.sequenceOrder,
            })
        .toList();

    try {
      await _client.from('stops').insert(stopRows);
    } catch (e) {
      await _client.from('routes').delete().eq('id', routeId);
      rethrow;
    }

    return routeId;
  }

  Future<void> updateRouteWithStops(String routeId, NewRoute route) async {
    await _client.from('routes').update({
      'name': route.name.trim(),
      'description':
          (route.description != null && route.description!.trim().isNotEmpty)
              ? route.description!.trim()
              : null,
    }).eq('id', routeId);

    await _client.from('stops').delete().eq('route_id', routeId);

    final List<Map<String, dynamic>> stopRows = route.stops
        .map((s) => {
              'route_id': routeId,
              'name': s.name.trim(),
              'sequence_order': s.sequenceOrder,
            })
        .toList();

    await _client.from('stops').insert(stopRows);
  }

  Future<void> deleteRoute(String routeId) async {
    await _client.from('routes').delete().eq('id', routeId);
  }
}
