import 'package:ebus/features/route_list/data/models/route_with_stops_model.dart';
import 'package:ebus/features/route_list/route_list_locator.dart';
import 'package:flutter/material.dart';

class RouteListController extends ChangeNotifier {
  RouteListController();

  List<RouteWithStopsModel> _routes = [];
  List<RouteWithStopsModel> get routes => _routes;

  Set<String> _expandedRoutes = {};
  Set<String> get expandedRoutes => _expandedRoutes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadRoutes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _routes = await RouteListLocator.getRoutesWithStopsUseCase();
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

  void toggleRoute(String routeId) {
    if (_expandedRoutes.contains(routeId)) {
      _expandedRoutes.remove(routeId);
    } else {
      _expandedRoutes.add(routeId);
    }
    notifyListeners();
  }

  bool isRouteExpanded(String routeId) {
    return _expandedRoutes.contains(routeId);
  }
}

class RouteListPage extends StatefulWidget {
  const RouteListPage({super.key});

  @override
  State<RouteListPage> createState() => _RouteListPageState();
}

class _RouteListPageState extends State<RouteListPage> {
  final RouteListController _controller = RouteListController();

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
        title: const Text('Route List'),
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
              final isExpanded = _controller.isRouteExpanded(route.routeId);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => _controller.toggleRoute(route.routeId),
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
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: colors.outline,
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Container(
                        width: double.infinity,
                        color: colors.surfaceContainerHighest,
                        child: Column(
                          children: [
                            const Divider(height: 1),
                            ...route.stops.asMap().entries.map((entry) {
                              final stopIndex = entry.key;
                              final stop = entry.value;
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: colors.primary,
                                  child: Text(
                                    '${stopIndex + 1}',
                                    style: TextStyle(
                                      color: colors.onPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(stop.stopName),
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 0,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}