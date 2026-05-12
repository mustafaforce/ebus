import 'package:ebus/features/route_list/data/models/route_with_stops_model.dart';
import 'package:ebus/features/route_list/route_list_locator.dart';
import 'package:ebus/features/route_management/presentation/pages/create_route_page.dart';
import 'package:ebus/features/route_management/route_management_locator.dart';
import 'package:flutter/material.dart';

class ManageRoutesController extends ChangeNotifier {
  ManageRoutesController();

  List<RouteWithStopsModel> _routes = [];
  List<RouteWithStopsModel> get routes => _routes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _deletingId;
  String? get deletingId => _deletingId;

  Future<void> loadRoutes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _routes = await RouteListLocator.getRoutesWithStopsUseCase();
      if (_routes.isEmpty) {
        _errorMessage = 'No routes yet. Create one.';
      }
    } catch (e) {
      _errorMessage = 'Failed to load routes';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRoute(String routeId) async {
    _deletingId = routeId;
    notifyListeners();
    try {
      await RouteManagementLocator.deleteRouteUseCase(routeId);
      _routes = _routes.where((r) => r.routeId != routeId).toList();
      return true;
    } catch (_) {
      return false;
    } finally {
      _deletingId = null;
      notifyListeners();
    }
  }
}

class ManageRoutesPage extends StatefulWidget {
  const ManageRoutesPage({super.key});

  @override
  State<ManageRoutesPage> createState() => _ManageRoutesPageState();
}

class _ManageRoutesPageState extends State<ManageRoutesPage> {
  final ManageRoutesController _controller = ManageRoutesController();

  @override
  void initState() {
    super.initState();
    _controller.loadRoutes();
  }

  Future<void> _onEdit(RouteWithStopsModel route) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateRoutePage(initial: route),
      ),
    );
    if (result == true && mounted) {
      await _controller.loadRoutes();
    }
  }

  Future<void> _onDelete(RouteWithStopsModel route) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete route?'),
        content: Text(
          'Delete "${route.routeName}" and all its ${route.totalStops} stops? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final bool ok = await _controller.deleteRoute(route.routeId);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? 'Route deleted' : 'Failed to delete route'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Routes'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _controller.loadRoutes(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.routes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_controller.errorMessage ?? 'No routes'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _controller.loadRoutes,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.routes.length,
            itemBuilder: (context, index) {
              final route = _controller.routes[index];
              final bool isDeleting =
                  _controller.deletingId == route.routeId;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.directions_bus,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              route.routeName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (route.routeDescription != null)
                              Text(
                                route.routeDescription!,
                                style: TextStyle(
                                  color: colors.outline,
                                  fontSize: 13,
                                ),
                              ),
                            Text(
                              '${route.totalStops} stops',
                              style: TextStyle(
                                color: colors.outline,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: isDeleting ? null : () => _onEdit(route),
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        onPressed: isDeleting ? null : () => _onDelete(route),
                        icon: isDeleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(Icons.delete, color: colors.error),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
