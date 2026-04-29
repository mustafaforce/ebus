class BusLocationModel {
  const BusLocationModel({
    required this.id,
    required this.routeId,
    required this.driverId,
    required this.currentStopId,
    required this.updatedAt,
  });

  final String id;
  final String routeId;
  final String driverId;
  final String currentStopId;
  final DateTime updatedAt;

  factory BusLocationModel.fromDatabase(Map<String, dynamic> map) {
    return BusLocationModel(
      id: map['id'] as String,
      routeId: map['route_id'] as String,
      driverId: map['driver_id'] as String,
      currentStopId: map['current_stop_id'] as String,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'route_id': routeId,
      'driver_id': driverId,
      'current_stop_id': currentStopId,
    };
  }
}