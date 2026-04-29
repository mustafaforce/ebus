import 'package:ebus/features/route_list/data/models/route_with_stops_model.dart';

abstract class RouteListRepository {
  Future<List<RouteWithStopsModel>> getRoutesWithStops();
}