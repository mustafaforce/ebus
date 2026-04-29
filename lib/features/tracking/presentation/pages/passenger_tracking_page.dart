import 'package:ebus/features/tracking/data/models/passenger_tracking_model.dart';
import 'package:ebus/features/tracking/passenger_tracking_locator.dart';
import 'package:flutter/material.dart';

class PassengerTrackingController extends ChangeNotifier {
  PassengerTrackingController();

  List<Map<String, dynamic>> _routes = [];
  List<Map<String, dynamic>> get routes => _routes;

  Map<String, dynamic>? _selectedRoute;
  Map<String, dynamic>? get selectedRoute => _selectedRoute;

  PassengerTrackingModel? _trackingInfo;
  PassengerTrackingModel? get trackingInfo => _trackingInfo;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingTracking = false;
  bool get isLoadingTracking => _isLoadingTracking;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadRoutes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _routes = await PassengerTrackingLocator.getActiveRoutesUseCase();
      if (_routes.isEmpty) {
        _errorMessage = 'No active routes';
      }
    } catch (e) {
      _errorMessage = 'Failed to load routes';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectRoute(Map<String, dynamic> route) async {
    _selectedRoute = route;
    _trackingInfo = null;
    notifyListeners();

    await loadTracking();
  }

  Future<void> loadTracking() async {
    if (_selectedRoute == null) return;

    _isLoadingTracking = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _trackingInfo = await PassengerTrackingLocator.getTrackingByRouteUseCase(
        _selectedRoute!['id'] as String,
      );
      if (_trackingInfo == null) {
        _errorMessage = 'No bus location for this route yet';
      }
    } catch (e) {
      _errorMessage = 'Failed to load tracking info';
    } finally {
      _isLoadingTracking = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadTracking();
  }

  void clearSelection() {
    _selectedRoute = null;
    _trackingInfo = null;
    notifyListeners();
  }
}

class PassengerTrackingPage extends StatefulWidget {
  const PassengerTrackingPage({super.key});

  @override
  State<PassengerTrackingPage> createState() => _PassengerTrackingPageState();
}

class _PassengerTrackingPageState extends State<PassengerTrackingPage> {
  final PassengerTrackingController _controller =
      PassengerTrackingController();

  @override
  void initState() {
    super.initState();
    _controller.loadRoutes();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Tracking'),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.errorMessage != null && _controller.routes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_controller.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _controller.loadRoutes,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: colors.surfaceContainerHighest,
                child: DropdownButtonFormField<Map<String, dynamic>>(
                  value: _controller.selectedRoute,
                  decoration: const InputDecoration(
                    labelText: 'Select Route',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  hint: const Text('Choose a route'),
                  isExpanded: true,
                  items: _controller.routes.map((route) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: route,
                      child: Text(route['name'] as String),
                    );
                  }).toList(),
                  onChanged: (route) {
                    if (route != null) {
                      _controller.selectRoute(route);
                    }
                  },
                ),
              ),
              if (_controller.selectedRoute != null)
                Expanded(
                  child: _buildTrackingContent(colors),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTrackingContent(ColorScheme colors) {
    if (_controller.isLoadingTracking) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: colors.outline,
            ),
            const SizedBox(height: 16),
            Text(
              _controller.errorMessage!,
              style: TextStyle(color: colors.outline),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _controller.refresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final info = _controller.trackingInfo?.toRouteInfo();
    if (info == null) {
      return const Center(child: Text('No tracking data available'));
    }

    return RefreshIndicator(
      onRefresh: _controller.refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.directions_bus,
                    size: 48,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    info.routeName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (info.routeDescription != null)
                    Text(
                      info.routeDescription!,
                      style: TextStyle(color: colors.outline),
                    ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: info.progressPercent / 100,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${info.currentStopSequence + 1} of ${info.totalStops} stops',
                    style: TextStyle(color: colors.outline),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colors.primaryContainer,
                child: Icon(
                  Icons.location_on,
                  color: colors.onPrimaryContainer,
                ),
              ),
              title: const Text('Current Location'),
              subtitle: Text(
                info.currentStopName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          if (info.hasNextStop) ...[
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colors.secondaryContainer,
                  child: Icon(
                    Icons.arrow_forward,
                    color: colors.onSecondaryContainer,
                  ),
                ),
                title: const Text('Next Stop'),
                subtitle: Text(
                  info.nextStopName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: colors.tertiaryContainer,
                child: Icon(
                  Icons.access_time,
                  color: colors.onTertiaryContainer,
                ),
              ),
              title: const Text('Last Updated'),
              subtitle: Text(
                info.lastUpdatedAgo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}