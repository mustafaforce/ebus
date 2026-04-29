class StopModel {
  const StopModel({
    required this.id,
    required this.routeId,
    required this.name,
    required this.sequenceOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String routeId;
  final String name;
  final int sequenceOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory StopModel.fromDatabase(Map<String, dynamic> map) {
    return StopModel(
      id: map['id'] as String,
      routeId: map['route_id'] as String,
      name: map['name'] as String,
      sequenceOrder: map['sequence_order'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}