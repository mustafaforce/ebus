import 'package:flutter/material.dart';

class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();

  static NavigatorState? get _navigator => navigatorKey.currentState;

  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return _navigator!.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return _navigator!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName, {
    Object? arguments,
    RoutePredicate? predicate,
  }) {
    return _navigator!.pushNamedAndRemoveUntil<T>(
      newRouteName,
      predicate ?? (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  static void pop<T extends Object?>([T? result]) {
    if (_navigator?.canPop() ?? false) {
      _navigator?.pop<T>(result);
    }
  }
}
