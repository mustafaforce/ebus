import 'package:ebus/core/services/route_service.dart';
import 'package:ebus/core/services/stop_service.dart';
import 'package:ebus/features/auth/auth_locator.dart';
import 'package:ebus/features/tracking/tracking_locator.dart';
import 'package:flutter/material.dart';

class LocationUpdateController extends ChangeNotifier {
  LocationUpdateController();

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  String? _successMessage;
  String? get successMessage => _successMessage;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> updateLocation() async {
    final route = RouteService.instance.selectedRoute;
    final stop = StopService.instance.selectedStop;

    if (route == null || stop == null) {
      _errorMessage = 'Please select route and stop first';
      notifyListeners();
      return;
    }

    final user = await AuthLocator.getCurrentUserProfileUseCase();
    if (user == null) {
      _errorMessage = 'User not found';
      notifyListeners();
      return;
    }

    _isUpdating = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await TrackingLocator.updateBusLocationUseCase(
        routeId: route.id,
        driverId: user.id,
        currentStopId: stop.id,
      );
      _successMessage = 'Location updated successfully!';
    } catch (e) {
      _errorMessage = 'Failed to update location';
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _successMessage = null;
    _errorMessage = null;
    notifyListeners();
  }
}