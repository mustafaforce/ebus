class PassengerRouteInfo {
  const PassengerRouteInfo({
    required this.routeName,
    required this.routeDescription,
    required this.currentStopName,
    required this.currentStopSequence,
    required this.totalStops,
    required this.nextStopName,
    required this.lastUpdated,
    required this.driverName,
  });

  final String routeName;
  final String? routeDescription;
  final String currentStopName;
  final int currentStopSequence;
  final int totalStops;
  final String? nextStopName;
  final DateTime lastUpdated;
  final String? driverName;

  String get lastUpdatedAgo {
    final difference = DateTime.now().difference(lastUpdated);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  int get progressPercent {
    if (totalStops == 0) return 0;
    return ((currentStopSequence + 1) / totalStops * 100).round();
  }

  bool get hasNextStop => nextStopName != null;
}

class PassengerTrackingModel {
  const PassengerTrackingModel({
    required this.routeId,
    required this.routeName,
    this.routeDescription,
    required this.currentStopId,
    required this.currentStopName,
    required this.currentStopSequence,
    required this.totalStops,
    this.nextStopName,
    required this.lastUpdated,
    this.driverName,
  });

  final String routeId;
  final String routeName;
  final String? routeDescription;
  final String currentStopId;
  final String currentStopName;
  final int currentStopSequence;
  final int totalStops;
  final String? nextStopName;
  final DateTime lastUpdated;
  final String? driverName;

  PassengerRouteInfo toRouteInfo() {
    return PassengerRouteInfo(
      routeName: routeName,
      routeDescription: routeDescription,
      currentStopName: currentStopName,
      currentStopSequence: currentStopSequence,
      totalStops: totalStops,
      nextStopName: nextStopName,
      lastUpdated: lastUpdated,
      driverName: driverName,
    );
  }

  factory PassengerTrackingModel.fromDatabase({
    required Map<String, dynamic> location,
    required Map<String, dynamic> route,
    required Map<String, dynamic> currentStop,
    Map<String, dynamic>? nextStop,
    Map<String, dynamic>? driver,
  }) {
    final currentSeq = currentStop['sequence_order'] as int;
    final totalStops = route['stops'] as List<dynamic>? ?? [];
    final nextStopData = nextStop;

    return PassengerTrackingModel(
      routeId: route['id'] as String,
      routeName: route['name'] as String,
      routeDescription: route['description'] as String?,
      currentStopId: currentStop['id'] as String,
      currentStopName: currentStop['name'] as String,
      currentStopSequence: currentSeq,
      totalStops: totalStops.length,
      nextStopName: nextStopData?['name'] as String?,
      lastUpdated: DateTime.parse(location['updated_at'] as String),
      driverName: driver?['full_name'] as String?,
    );
  }
}