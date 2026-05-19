import 'package:ebus/app/router/app_routes.dart';
import 'package:ebus/app/theme/design_tokens.dart';
import 'package:ebus/core/services/navigation_service.dart';
import 'package:ebus/core/services/route_service.dart';
import 'package:ebus/core/services/stop_service.dart';
import 'package:ebus/features/auth/auth_locator.dart';
import 'package:ebus/features/auth/domain/entities/user_profile.dart';
import 'package:ebus/features/auth/domain/entities/user_role.dart';
import 'package:ebus/features/home/presentation/controllers/location_update_controller.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<UserProfile?> _profileFuture;
  final LocationUpdateController _locationController = LocationUpdateController();

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<UserProfile?> _loadProfile() {
    return AuthLocator.getCurrentUserProfileUseCase();
  }

  Future<void> _openProfileEditor() async {
    final Object? result = await Navigator.of(context).pushNamed(AppRoutes.profileEdit);
    if (!mounted || result != true) return;
    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  UserProfile _fallbackProfile() {
    return const UserProfile(
      id: '',
      email: '',
      role: UserRole.passenger,
      fullName: null,
    );
  }

  Future<void> _onLogout(BuildContext context) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await AuthLocator.signOutUseCase();
      await NavigationService.pushNamedAndRemoveUntil<void>(AppRoutes.driverLogin);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Logout failed. Please try again.')),
      );
    }
  }

  Future<void> _openPassengerTracking() async {
    await Navigator.of(context).pushNamed(AppRoutes.passengerTracking);
  }

  Future<void> _openRouteList() async {
    await Navigator.of(context).pushNamed(AppRoutes.routeList);
  }

  Future<void> _openCreateRoute() async {
    await Navigator.of(context).pushNamed(AppRoutes.createRoute);
    if (mounted) setState(() {});
  }

  Future<void> _openManageRoutes() async {
    await Navigator.of(context).pushNamed(AppRoutes.manageRoutes);
    if (mounted) setState(() {});
  }

  Future<void> _openRouteSelection() async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.routeSelection);
    if (result != null && mounted) {
      RouteService.instance.setRoute(result as dynamic);
      setState(() {});
    }
  }

  Future<void> _openStopSelection() async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.stopSelection);
    if (result != null && mounted) {
      StopService.instance.setStop(result as dynamic);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (BuildContext context, AsyncSnapshot<UserProfile?> snapshot) {
        final UserProfile profile = snapshot.data ?? _fallbackProfile();
        final bool isDriver = profile.role == UserRole.driver;
        final bool loading = snapshot.connectionState != ConnectionState.done;

        return Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: AppBar(
            title: const Text('eBus'),
            actions: [
              IconButton(
                onPressed: _openProfileEditor,
                tooltip: 'Profile',
                icon: const Icon(Icons.person_outline),
              ),
              IconButton(
                onPressed: () => _onLogout(context),
                tooltip: 'Logout',
                icon: const Icon(Icons.logout),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            isDriver ? 'Driver.' : 'Passenger.',
                            style: text.displayMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            isDriver
                                ? 'Manage routes and broadcast your current stop.'
                                : 'Track your bus or browse routes.',
                            style: text.headlineMedium?.copyWith(
                              color: AppColors.inkMuted80,
                              fontSize: 21,
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                            ),
                          ),
                          if (profile.email.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              profile.email,
                              style: text.bodySmall?.copyWith(
                                color: AppColors.inkMuted48,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                          if (isDriver)
                            _DriverSection(
                              locationController: _locationController,
                              onCreateRoute: _openCreateRoute,
                              onManageRoutes: _openManageRoutes,
                              onViewRoutes: _openRouteList,
                              onSelectRoute: _openRouteSelection,
                              onSelectStop: _openStopSelection,
                              onRouteCleared: () => setState(() {}),
                            )
                          else
                            _PassengerSection(
                              onTrack: _openPassengerTracking,
                              onViewRoutes: _openRouteList,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _PassengerSection extends StatelessWidget {
  const _PassengerSection({
    required this.onTrack,
    required this.onViewRoutes,
  });

  final VoidCallback onTrack;
  final VoidCallback onViewRoutes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(onPressed: onTrack, child: const Text('Track Bus')),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton(onPressed: onViewRoutes, child: const Text('View Routes')),
      ],
    );
  }
}

class _DriverSection extends StatelessWidget {
  const _DriverSection({
    required this.locationController,
    required this.onCreateRoute,
    required this.onManageRoutes,
    required this.onViewRoutes,
    required this.onSelectRoute,
    required this.onSelectStop,
    required this.onRouteCleared,
  });

  final LocationUpdateController locationController;
  final VoidCallback onCreateRoute;
  final VoidCallback onManageRoutes;
  final VoidCallback onViewRoutes;
  final VoidCallback onSelectRoute;
  final VoidCallback onSelectStop;
  final VoidCallback onRouteCleared;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool hasRoute = RouteService.instance.hasRoute;
    final bool hasStop = StopService.instance.hasStop;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel('Broadcast'),
        const SizedBox(height: AppSpacing.sm),
        _SummaryCard(
          label: 'Route',
          value: hasRoute ? RouteService.instance.selectedRoute!.name : 'Not selected',
          description: hasRoute
              ? RouteService.instance.selectedRoute!.description
              : null,
          trailing: hasRoute
              ? IconButton(
                  onPressed: () {
                    RouteService.instance.clearRoute();
                    onRouteCleared();
                  },
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Clear route',
                )
              : null,
          onTap: onSelectRoute,
        ),
        const SizedBox(height: AppSpacing.sm),
        _SummaryCard(
          label: 'Current stop',
          value: hasStop ? StopService.instance.selectedStop!.name : 'Not set',
          onTap: hasRoute ? onSelectStop : null,
        ),
        const SizedBox(height: AppSpacing.md),
        ListenableBuilder(
          listenable: locationController,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton.icon(
                  onPressed: () => locationController.toggleExtraFields(),
                  icon: Icon(
                    locationController.showExtraFields
                        ? Icons.remove_circle_outline
                        : Icons.add_circle_outline,
                    size: 18,
                  ),
                  label: Text(
                    locationController.showExtraFields
                        ? 'Remove distance & time'
                        : 'Add estimated distance & time',
                  ),
                ),
                if (locationController.showExtraFields) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: locationController.distanceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Distance (km)',
                            hintText: 'e.g. 2.5',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: locationController.timeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Time (min)',
                            hintText: 'e.g. 5',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            );
          },
        ),
        ListenableBuilder(
          listenable: locationController,
          builder: (context, _) {
            final bool enabled = hasRoute && hasStop && !locationController.isUpdating;
            return FilledButton(
              onPressed: enabled
                  ? () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await locationController.updateLocation();
                      if (!context.mounted) return;
                      final msg = locationController.successMessage ??
                          locationController.errorMessage;
                      if (msg != null) {
                        messenger.showSnackBar(SnackBar(content: Text(msg)));
                      }
                    }
                  : null,
              child: locationController.isUpdating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text('Confirm Location'),
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        _SectionLabel('Routes'),
        const SizedBox(height: AppSpacing.sm),
        _ActionRow(
          label: 'Create new route',
          onTap: onCreateRoute,
        ),
        const Divider(height: 1),
        _ActionRow(
          label: 'Manage routes',
          onTap: onManageRoutes,
        ),
        const Divider(height: 1),
        _ActionRow(
          label: 'View all routes',
          onTap: onViewRoutes,
          showDivider: false,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'All interactive elements share one accent. Tap a row to open it.',
          style: text.labelSmall,
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.inkMuted48,
            letterSpacing: 0,
          ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    this.description,
    this.trailing,
    this.onTap,
  });

  final String label;
  final String value;
  final String? description;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.parchment,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: text.labelSmall),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: text.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        style: text.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              if (onTap != null && trailing == null)
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.inkMuted48,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.inkMuted48,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
