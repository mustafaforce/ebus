import 'package:ebus/features/stops/data/models/stop_model.dart';

abstract class StopRepository {
  Future<List<StopModel>> getStopsByRoute(String routeId);
}