import 'package:ebus/features/routes/data/models/route_model.dart';
import 'package:ebus/features/routes/route_locator.dart';
import 'package:flutter/material.dart';

class RouteSelectionController extends ChangeNotifier {
  RouteSelectionController();

  List<RouteModel> _routes = [];
  List<RouteModel> get routes => _routes;

  RouteModel? _selectedRoute;
  RouteModel? get selectedRoute => _selectedRoute;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadRoutes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _routes = await RouteLocator.getActiveRoutesUseCase();
      if (_routes.isEmpty) {
        _errorMessage = 'No routes available';
      }
    } catch (e) {
      _errorMessage = 'Failed to load routes';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectRoute(RouteModel route) {
    _selectedRoute = route;
    notifyListeners();
  }

  void clearSelection() {
    _selectedRoute = null;
    notifyListeners();
  }
}

class RouteSelectionPage extends StatefulWidget {
  const RouteSelectionPage({super.key});

  @override
  State<RouteSelectionPage> createState() => _RouteSelectionPageState();
}

class _RouteSelectionPageState extends State<RouteSelectionPage> {
  final RouteSelectionController _controller = RouteSelectionController();

  @override
  void initState() {
    super.initState();
    _controller.loadRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Route'),
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
                    onPressed: _controller.loadRoutes,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (_controller.routes.isEmpty) {
            return const Center(child: Text('No routes found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.routes.length,
            itemBuilder: (context, index) {
              final route = _controller.routes[index];
              final isSelected = _controller.selectedRoute?.id == route.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.directions_bus,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  title: Text(
                    route.name,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: route.description != null
                      ? Text(route.description!)
                      : null,
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () => _controller.selectRoute(route),
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
                onPressed: _controller.selectedRoute == null
                    ? null
                    : () {
                        Navigator.pop(context, _controller.selectedRoute);
                      },
                child: const Text('Confirm Route'),
              ),
            ),
          );
        },
      ),
    );
  }
}