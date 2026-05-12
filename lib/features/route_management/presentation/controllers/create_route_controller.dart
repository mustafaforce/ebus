import 'package:ebus/features/route_list/data/models/route_with_stops_model.dart';
import 'package:ebus/features/route_management/domain/entities/new_route.dart';
import 'package:ebus/features/route_management/route_management_locator.dart';
import 'package:flutter/material.dart';

class StopDraft {
  StopDraft({String? initialText})
      : controller = TextEditingController(text: initialText);

  final TextEditingController controller;

  void dispose() => controller.dispose();
}

class CreateRouteController extends ChangeNotifier {
  CreateRouteController({RouteWithStopsModel? initial}) : _initial = initial {
    if (initial != null) {
      nameController.text = initial.routeName;
      descriptionController.text = initial.routeDescription ?? '';
      for (final s in initial.stops) {
        _stops.add(StopDraft(initialText: s.stopName));
      }
      if (_stops.isEmpty) {
        addStop();
      }
    } else {
      addStop();
    }
  }

  final RouteWithStopsModel? _initial;
  bool get isEditMode => _initial != null;
  String? get routeId => _initial?.routeId;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final List<StopDraft> _stops = [];
  List<StopDraft> get stops => List.unmodifiable(_stops);

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  void addStop() {
    _stops.add(StopDraft());
    notifyListeners();
  }

  void removeStop(int index) {
    if (_stops.length <= 1) return;
    final StopDraft removed = _stops.removeAt(index);
    removed.dispose();
    notifyListeners();
  }

  void moveStopUp(int index) {
    if (index <= 0) return;
    final StopDraft item = _stops.removeAt(index);
    _stops.insert(index - 1, item);
    notifyListeners();
  }

  void moveStopDown(int index) {
    if (index >= _stops.length - 1) return;
    final StopDraft item = _stops.removeAt(index);
    _stops.insert(index + 1, item);
    notifyListeners();
  }

  Future<bool> submit() async {
    _errorMessage = null;
    _successMessage = null;

    final String name = nameController.text.trim();
    if (name.isEmpty) {
      _errorMessage = 'Route name is required';
      notifyListeners();
      return false;
    }

    final List<NewStop> stopEntities = [];
    for (int i = 0; i < _stops.length; i++) {
      final String stopName = _stops[i].controller.text.trim();
      if (stopName.isEmpty) {
        _errorMessage = 'Stop ${i + 1} name is empty';
        notifyListeners();
        return false;
      }
      stopEntities.add(NewStop(name: stopName, sequenceOrder: i + 1));
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final NewRoute payload = NewRoute(
        name: name,
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        stops: stopEntities,
      );
      if (isEditMode) {
        await RouteManagementLocator.updateRouteUseCase(routeId!, payload);
        _successMessage = 'Route updated';
      } else {
        await RouteManagementLocator.createRouteUseCase(payload);
        _successMessage = 'Route created';
      }
      return true;
    } catch (e) {
      _errorMessage =
          'Failed to ${isEditMode ? 'update' : 'create'} route: $e';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    for (final s in _stops) {
      s.dispose();
    }
    super.dispose();
  }
}
