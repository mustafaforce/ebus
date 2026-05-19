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
    this.estimatedDistance,
    this.estimatedTimeMinutes,
  });

  final String routeName;
  final String? routeDescription;
  final String currentStopName;
  final int currentStopSequence;
  final int totalStops;
  final String? nextStopName;
  final DateTime lastUpdated;
  final String? driverName;
  final double? estimatedDistance;
  final int? estimatedTimeMinutes;

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
  bool get hasExtraInfo => estimatedDistance != null || estimatedTimeMinutes != null;
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
    this.estimatedDistance,
    this.estimatedTimeMinutes,
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
  final double? estimatedDistance;
  final int? estimatedTimeMinutes;

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
      estimatedDistance: estimatedDistance,
      estimatedTimeMinutes: estimatedTimeMinutes,
    );
  }
}