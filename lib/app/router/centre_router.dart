import 'package:ebus/app/router/app_routes.dart';
import 'package:ebus/features/auth/presentation/pages/driver_login_page.dart';
import 'package:ebus/features/auth/presentation/pages/driver_sign_up_page.dart';
import 'package:ebus/features/home/presentation/pages/home_page.dart';
import 'package:ebus/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:flutter/material.dart';

class CentreRouter {
  CentreRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      case AppRoutes.driverLogin:
        return MaterialPageRoute<void>(
          builder: (_) => const DriverLoginPage(),
          settings: settings,
        );
      case AppRoutes.driverSignUp:
        return MaterialPageRoute<void>(
          builder: (_) => const DriverSignUpPage(),
          settings: settings,
        );
      case AppRoutes.profileEdit:
        return MaterialPageRoute<bool>(
          builder: (_) => const EditProfilePage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => _UnknownRoutePage(routeName: settings.name),
          settings: settings,
        );
    }
  }
}

class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage({required this.routeName});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Not Found')),
      body: Center(
        child: Text('No route defined for ${routeName ?? 'unknown'}'),
      ),
    );
  }
}
