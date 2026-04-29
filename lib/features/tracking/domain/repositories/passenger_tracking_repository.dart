import 'package:ebus/features/tracking/data/models/passenger_tracking_model.dart';

abstract class PassengerTrackingRepository {
  Future<PassengerTrackingModel?> getTrackingByRoute(String routeId);
  Future<List<Map<String, dynamic>>> getActiveRoutes();
}