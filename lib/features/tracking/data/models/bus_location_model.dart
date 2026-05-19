class BusLocationModel {
  const BusLocationModel({
    required this.id,
    required this.routeId,
    required this.driverId,
    required this.currentStopId,
    required this.updatedAt,
    this.estimatedDistance,
    this.estimatedTimeMinutes,
  });

  final String id;
  final String routeId;
  final String driverId;
  final String currentStopId;
  final DateTime updatedAt;
  final double? estimatedDistance;
  final int? estimatedTimeMinutes;

  factory BusLocationModel.fromDatabase(Map<String, dynamic> map) {
    return BusLocationModel(
      id: map['id'] as String,
      routeId: map['route_id'] as String,
      driverId: map['driver_id'] as String,
      currentStopId: map['current_stop_id'] as String,
      updatedAt: DateTime.parse(map['updated_at'] as String),
      estimatedDistance: (map['estimated_distance'] as num?)?.toDouble(),
      estimatedTimeMinutes: map['estimated_time_minutes'] as int?,
    );
  }
}