import 'package:ebus/app/router/app_routes.dart';
import 'package:ebus/core/services/navigation_service.dart';
import 'package:ebus/features/auth/auth_locator.dart';
import 'package:ebus/features/auth/domain/entities/user_profile.dart';
import 'package:ebus/features/auth/domain/entities/user_role.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = AuthLocator.getCurrentUserProfileUseCase();
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
        ? 'Auth is ready. Next we can build driver route selection and stop update.'
        : 'Auth is ready. Next we can build passenger route search and live bus tracking.';
  }

  IconData _roleIcon(UserRole role) {
    return role == UserRole.driver
        ? Icons.directions_bus_rounded
        : Icons.person_pin_circle_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => _onLogout(context),
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<UserProfile?>(
        future: _profileFuture,
        builder: (BuildContext context, AsyncSnapshot<UserProfile?> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final UserProfile profile = snapshot.data ?? _fallbackProfile();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _appBarTitle(profile.role),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: Padding(
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
