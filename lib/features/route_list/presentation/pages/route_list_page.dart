import 'package:ebus/app/theme/design_tokens.dart';
import 'package:ebus/features/route_list/data/models/route_with_stops_model.dart';
import 'package:ebus/features/route_list/route_list_locator.dart';
import 'package:flutter/material.dart';

class RouteListController extends ChangeNotifier {
  RouteListController();

  List<RouteWithStopsModel> _routes = [];
  List<RouteWithStopsModel> get routes => _routes;

  final Set<String> _expandedRoutes = {};
  bool isRouteExpanded(String routeId) => _expandedRoutes.contains(routeId);

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
        _errorMessage = 'No routes available.';
      }
    } catch (_) {
      _errorMessage = 'Failed to load routes.';
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
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('Routes')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.routes.isEmpty) {
            return _EmptyState(
              message: _controller.errorMessage ?? 'No routes',
              onRetry: _controller.loadRoutes,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: _controller.routes.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final route = _controller.routes[index];
              final bool expanded = _controller.isRouteExpanded(route.routeId);
              return _RouteCard(
                route: route,
                expanded: expanded,
                onTap: () => _controller.toggleRoute(route.routeId),
                text: text,
              );
            },
          );
        },
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.route,
    required this.expanded,
    required this.onTap,
    required this.text,
  });

  final RouteWithStopsModel route;
  final bool expanded;
  final VoidCallback onTap;
  final TextTheme text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.hairline, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(route.routeName, style: text.titleMedium),
                          if (route.routeDescription != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              route.routeDescription!,
                              style: text.bodySmall,
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            '${route.totalStops} stops',
                            style: text.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.inkMuted48,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  const Divider(height: 1),
                  ...route.stops.asMap().entries.map((entry) {
                    final int i = entry.key;
                    final stop = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text(
                              '${i + 1}',
                              style: text.labelSmall?.copyWith(
                                color: AppColors.inkMuted48,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(stop.stopName, style: text.bodyLarge),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.xs),
                ],
              ),
              crossFadeState:
                  expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: text.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
