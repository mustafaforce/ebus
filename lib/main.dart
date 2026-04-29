import 'package:ebus/app/router/centre_router.dart';
import 'package:ebus/app/router/app_routes.dart';
import 'package:ebus/app/theme/app_theme.dart';
import 'package:ebus/core/constants/supabase_config.dart';
import 'package:ebus/core/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const EBusApp());
}

class EBusApp extends StatelessWidget {
  const EBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eBus',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      navigatorObservers: <NavigatorObserver>[NavigationService.routeObserver],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: AppTheme.themeMode,
      initialRoute: AppRoutes.driverLogin,
      onGenerateRoute: CentreRouter.onGenerateRoute,
      onGenerateInitialRoutes: (String initialRouteName) {
        return <Route<dynamic>>[
          CentreRouter.onGenerateRoute(RouteSettings(name: initialRouteName)),
        ];
      },
    );
  }
}