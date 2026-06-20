import 'package:flutter/material.dart';

class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get _nav => navigatorKey.currentState;
  static BuildContext? get context => navigatorKey.currentContext;

  static Future<T?> pushNamed<T>(String route, {Object? args}) =>
      _nav!.pushNamed<T>(route, arguments: args);

  static Future<T?> pushReplacementNamed<T, TO>(String route,
          {Object? args, TO? result}) =>
      _nav!.pushReplacementNamed<T, TO>(route, arguments: args, result: result);

  static Future<T?> pushNamedAndRemoveUntil<T>(String route,
          {Object? args, bool Function(Route<dynamic>)? predicate}) =>
      _nav!.pushNamedAndRemoveUntil<T>(
        route,
        predicate ?? (_) => false,
        arguments: args,
      );

  static void pop<T>([T? result]) => _nav!.pop<T>(result);

  static bool canPop() => _nav?.canPop() ?? false;
}
