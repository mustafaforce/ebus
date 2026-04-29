import 'package:ebus/features/routes/data/models/route_model.dart';

class RouteService {
  RouteService._();

  static final RouteService _instance = RouteService._();
  static RouteService get instance => _instance;

  RouteModel? _selectedRoute;
  RouteModel? get selectedRoute => _selectedRoute;

  bool get hasRoute => _selectedRoute != null;

  void setRoute(RouteModel route) {
    _selectedRoute = route;
  }

  void clearRoute() {
    _selectedRoute = null;
  }
}