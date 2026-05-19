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

  final TextEditingController distanceController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  bool _showExtraFields = false;
  bool get showExtraFields => _showExtraFields;

  void toggleExtraFields() {
    _showExtraFields = !_showExtraFields;
    if (!_showExtraFields) {
      distanceController.clear();
      timeController.clear();
    }
    notifyListeners();
  }

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
      final double? dist = double.tryParse(distanceController.text.trim());
      final int? time = int.tryParse(timeController.text.trim());

      await TrackingLocator.updateBusLocationUseCase(
        routeId: route.id,
        driverId: user.id,
        currentStopId: stop.id,
        estimatedDistance: dist,
        estimatedTimeMinutes: time,
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

  @override
  void dispose() {
    distanceController.dispose();
    timeController.dispose();
    super.dispose();
  }
}