import 'package:ebus/app/theme/design_tokens.dart';
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
    } catch (_) {
      _errorMessage = 'Failed to load routes.';
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
      MaterialPageRoute(builder: (_) => CreateRoutePage(initial: route)),
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
          'Delete "${route.routeName}" and its ${route.totalStops} stops? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFD93025)),
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
      SnackBar(content: Text(ok ? 'Route deleted' : 'Failed to delete')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Manage Routes'),
        actions: [
          IconButton(
            onPressed: _controller.loadRoutes,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: AppSpacing.xs),
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
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _controller.errorMessage ?? 'No routes',
                      style: text.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: _controller.loadRoutes,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: _controller.routes.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final route = _controller.routes[index];
              final bool deleting = _controller.deletingId == route.routeId;
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.hairline, width: 1),
                ),
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
                    IconButton(
                      onPressed: deleting ? null : () => _onEdit(route),
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: deleting ? null : () => _onDelete(route),
                      icon: deleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Color(0xFFD93025),
                            ),
                      tooltip: 'Delete',
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
