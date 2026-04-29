class RouteWithStopsModel {
  const RouteWithStopsModel({
    required this.routeId,
    required this.routeName,
    this.routeDescription,
    required this.stops,
  });

  final String routeId;
  final String routeName;
  final String? routeDescription;
  final List<StopInfo> stops;

  int get totalStops => stops.length;
}

class StopInfo {
  const StopInfo({
    required this.stopId,
    required this.stopName,
    required this.sequenceOrder,
  });

  final String stopId;
  final String stopName;
  final int sequenceOrder;
}