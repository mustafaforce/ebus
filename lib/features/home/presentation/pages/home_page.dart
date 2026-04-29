import 'package:ebus/app/router/app_routes.dart';
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
    final Object? result = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.profileEdit);
    final bool didUpdate = result == true;
    if (!mounted || !didUpdate) {
      return;
    }
    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  UserProfile _fallbackProfile() {
    return const UserProfile(
      id: '',
      email: 'User',
      role: UserRole.passenger,
      fullName: null,
    );
  }

  Future<void> _onLogout(BuildContext context) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await AuthLocator.signOutUseCase();
      await NavigationService.pushNamedAndRemoveUntil<void>(
        AppRoutes.driverLogin,
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Logout failed. Please try again.')),
      );
    }
  }

  String _appBarTitle(UserRole role) {
    return role == UserRole.driver ? 'eBus Driver' : 'eBus Passenger';
  }

  String _welcomeTitle(UserRole role) {
    return role == UserRole.driver ? 'Welcome Driver' : 'Welcome Passenger';
  }

  String _roleMessage(UserRole role) {
    return role == UserRole.driver
        ? 'Select your route and update your current stop to let passengers track your bus.'
        : 'Track your bus or browse all routes and stops.';
  }

  Future<void> _openPassengerTracking() async {
    await Navigator.of(context).pushNamed(AppRoutes.passengerTracking);
  }

  Future<void> _openRouteList() async {
    await Navigator.of(context).pushNamed(AppRoutes.routeList);
  }

  IconData _roleIcon(UserRole role) {
    return role == UserRole.driver
        ? Icons.directions_bus_rounded
        : Icons.person_pin_circle_rounded;
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
    final ColorScheme colors = Theme.of(context).colorScheme;

    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (BuildContext context, AsyncSnapshot<UserProfile?> snapshot) {
        final UserProfile profile = snapshot.data ?? _fallbackProfile();

        return Scaffold(
          appBar: AppBar(
            title: Text(_appBarTitle(profile.role)),
            actions: [
              IconButton(
                onPressed: _openProfileEditor,
                tooltip: 'Edit profile',
                icon: const Icon(Icons.account_circle_rounded),
              ),
              IconButton(
                onPressed: () => _onLogout(context),
                tooltip: 'Logout',
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: snapshot.connectionState != ConnectionState.done
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors.primary.withValues(alpha: 0.16),
                              colors.secondary.withValues(alpha: 0.13),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _roleIcon(profile.role),
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _welcomeTitle(profile.role),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              profile.email,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: colors.surface.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(_roleMessage(profile.role)),
                            ),
                            if (profile.role == UserRole.passenger) ...[
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _openPassengerTracking,
                                  icon: const Icon(Icons.map),
                                  label: const Text('Track Bus'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _openRouteList,
                                  icon: const Icon(Icons.list),
                                  label: const Text('View Routes'),
                                ),
                              ),
                            ] else if (profile.role == UserRole.driver) ...[
                              const SizedBox(height: 24),
                              if (RouteService.instance.hasRoute) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: colors.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: colors.onPrimaryContainer,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Selected Route',
                                              style: TextStyle(
                                                color: colors.onPrimaryContainer,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              RouteService.instance.selectedRoute!.name,
                                              style: TextStyle(
                                                color: colors.onPrimaryContainer,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            if (RouteService.instance.selectedRoute!.description != null)
                                              Text(
                                                RouteService.instance.selectedRoute!.description!,
                                                style: TextStyle(
                                                  color: colors.onPrimaryContainer.withValues(alpha: 0.7),
                                                  fontSize: 12,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          RouteService.instance.clearRoute();
                                          setState(() {});
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          color: colors.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _openRouteSelection,
                                  icon: Icon(RouteService.instance.hasRoute ? Icons.swap_horiz : Icons.map),
                                  label: Text(RouteService.instance.hasRoute ? 'Change Route' : 'Select Route'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (StopService.instance.hasStop) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: colors.secondaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: colors.onSecondaryContainer,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Current Stop',
                                              style: TextStyle(
                                                color: colors.onSecondaryContainer,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              StopService.instance.selectedStop!.name,
                                              style: TextStyle(
                                                color: colors.onSecondaryContainer,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: RouteService.instance.hasRoute ? _openStopSelection : null,
                                  icon: const Icon(Icons.location_on),
                                  label: Text(StopService.instance.hasStop ? 'Change Stop' : 'Update Stop'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ListenableBuilder(
                                listenable: _locationController,
                                builder: (context, _) {
                                  return SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: (RouteService.instance.hasRoute && StopService.instance.hasStop)
                                          ? () async {
                                              await _locationController.updateLocation();
                                              if (mounted) {
                                                if (_locationController.successMessage != null) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(_locationController.successMessage!),
                                                      backgroundColor: Colors.green,
                                                    ),
                                                  );
                                                } else if (_locationController.errorMessage != null) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(_locationController.errorMessage!),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          : null,
                                      icon: _locationController.isUpdating
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(Icons.upload),
                                      label: Text(_locationController.isUpdating ? 'Updating...' : 'Confirm Location Update'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
