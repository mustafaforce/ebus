import 'package:ebus/features/routes/data/models/route_model.dart';

abstract class RouteRepository {
  Future<List<RouteModel>> getActiveRoutes();
}