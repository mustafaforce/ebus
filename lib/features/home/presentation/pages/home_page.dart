import 'package:ebus/app/router/app_routes.dart';
import 'package:ebus/core/network/supabase_client_provider.dart';
import 'package:ebus/core/services/navigation_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _currentDriverEmail() {
    try {
      return SupabaseClientProvider.client.auth.currentUser?.email ?? 'Driver';
    } catch (_) {
      return 'Driver';
    }
  }

  Future<void> _onLogout(BuildContext context) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await SupabaseClientProvider.client.auth.signOut();
      await NavigationService.pushNamedAndRemoveUntil<void>(
        AppRoutes.driverLogin,
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Logout failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String email = _currentDriverEmail();
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('eBus Driver'),
        actions: [
          IconButton(
            onPressed: () => _onLogout(context),
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
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
                  Text(
                    'Welcome Driver',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(email, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Auth is ready. Next we can build driver route selection and stop update.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
