import 'package:dargo/core/navigator/guards/guard.dart';
import 'package:dargo/core/navigator/guards/guard_configuration.dart';
import 'package:dargo/core/navigator/guards/route_info.dart';
import 'package:flutter/cupertino.dart';

//TODO: Eliminar lo relacionado a los guards directos, ya no se utilizará de esa forma.
class DargoNavigator {
  final GlobalKey<NavigatorState> _navigatorKey;
  final List<Guard> _guards;
  final List<String> _routeStack = [];
  final List<GuardConfiguration> _configs;

  DargoNavigator(this._navigatorKey, this._guards, this._configs);

  Future<dynamic> to(String routeName, {dynamic params}) async {
    final previous = _routeStack.isNotEmpty ? _routeStack.last : null;

    // final redirect = await _checkGuards(routeName, previous);
    final redirect = _checkGuardConfiguration(RouteInfo(
      name: routeName,
      previousRouteName: previous,
    ));
    if (redirect != null) {
      return _navigatorKey.currentState!.pushReplacementNamed(
        redirect.name!,
        arguments: redirect.arguments,
      );
    }

    _routeStack.add(routeName);

    return _navigatorKey.currentState?.pushNamed(
      routeName,
      arguments: params,
    );
  }

  Future<dynamic> toReplaceAll(String routeName, {dynamic params}) {
    final redirect = _checkGuards(routeName, null);

    if (redirect != null) {
      return _navigatorKey.currentState!.pushNamedAndRemoveUntil(
        redirect.name!,
        (route) => false,
        arguments: redirect.arguments,
      );
    }

    _routeStack
      ..clear()
      ..add(routeName);

    return _navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: params,
    );
  }

  Future<dynamic> toReplace(String routeName, {dynamic params}) {
    final previous = _routeStack.isNotEmpty ? _routeStack.last : null;

    final redirect = _checkGuards(routeName, previous);
    if (redirect != null) {
      return _navigatorKey.currentState!.pushReplacementNamed(
        redirect.name!,
        arguments: redirect.arguments,
      );
    }

    if (_routeStack.isNotEmpty) {
      _routeStack.removeLast();
    }

    return _navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: params);
  }

  void back([dynamic result]) {
    if (_routeStack.isNotEmpty) {
      _routeStack.removeLast();
    }

    _navigatorKey.currentState?.pop(result);
  }

  RouteSettings? _checkGuards(String routeName, prev) {
    for (final guard in _guards) {
      final redirect = guard.beforeEnter(next: routeName, prev: prev);

      if (redirect != null) {
        return redirect;
      }
    }

    return null;
  }

  RouteSettings? _checkGuardConfiguration(RouteInfo routeInfo) {
    for (final routeConfig in _configs) {
      final shouldBeApplied = routeConfig.applyOn(routeInfo);
      if (!shouldBeApplied) {
        return null;
      }

      final redirect = routeConfig.guard.beforeEnter(next: routeInfo.name);
      if (redirect != null) {
        return redirect;
      }
    }

    return null;
  }
}
