import 'package:supabase_flutter/supabase_flutter.dart';

class RouteModel {
  RouteModel({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory RouteModel.fromDatabase(Map<String, dynamic> map) {
    return RouteModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class RouteRemoteDataSource {
  RouteRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<List<RouteModel>> getActiveRoutes() async {
    final List<Map<String, dynamic>> maps = await _client
        .from('routes')
        .select('id, name, description, is_active, created_at, updated_at')
        .eq('is_active', true)
        .order('name', ascending: true);

    return maps.map((map) => RouteModel.fromDatabase(map)).toList();
  }
}