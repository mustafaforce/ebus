import 'package:ebus/core/services/route_service.dart';
import 'package:ebus/features/stops/data/models/stop_model.dart';
import 'package:ebus/features/stops/stop_locator.dart';
import 'package:flutter/material.dart';

class StopSelectionController extends ChangeNotifier {
  StopSelectionController();

  List<StopModel> _stops = [];
  List<StopModel> get stops => _stops;

  StopModel? _selectedStop;
  StopModel? get selectedStop => _selectedStop;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadStops() async {
    final route = RouteService.instance.selectedRoute;
    if (route == null) {
      _errorMessage = 'No route selected';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stops = await StopLocator.getStopsByRouteUseCase(route.id);
      if (_stops.isEmpty) {
        _errorMessage = 'No stops found for this route';
      }
    } catch (e) {
      _errorMessage = 'Failed to load stops';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectStop(StopModel stop) {
    _selectedStop = stop;
    notifyListeners();
  }

  void clearSelection() {
    _selectedStop = null;
    notifyListeners();
  }
}

class StopSelectionPage extends StatefulWidget {
  const StopSelectionPage({super.key});

  @override
  State<StopSelectionPage> createState() => _StopSelectionPageState();
}

class _StopSelectionPageState extends State<StopSelectionPage> {
  final StopSelectionController _controller = StopSelectionController();

  @override
  void initState() {
    super.initState();
    _controller.loadStops();
  }

  @override
  Widget build(BuildContext context) {
    final routeName = RouteService.instance.selectedRoute?.name ?? 'Route';

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Stop - $routeName'),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_controller.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _controller.loadStops,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (_controller.stops.isEmpty) {
            return const Center(child: Text('No stops found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.stops.length,
            itemBuilder: (context, index) {
              final stop = _controller.stops[index];
              final isSelected = _controller.selectedStop?.id == stop.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Text(
                      '${stop.sequenceOrder + 1}',
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    stop.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text('Stop ${stop.sequenceOrder + 1}'),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () => _controller.selectStop(stop),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _controller.selectedStop == null
                    ? null
                    : () {
                        Navigator.pop(context, _controller.selectedStop);
                      },
                child: const Text('Confirm Stop'),
              ),
            ),
          );
        },
      ),
    );
  }
}