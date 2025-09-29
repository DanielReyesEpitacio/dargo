import 'package:dargo/core/ioc/default_ioc_container.dart';
import 'package:dargo/core/ioc/ioc_container.dart';
import 'package:dargo/core/ioc/omnipresent_ioc.dart';
import 'package:dargo/core/navigator/dargo_navigator.dart';
import 'package:dargo/core/navigator/guards/guard.dart';
import 'package:dargo/core/navigator/guards/guard_configuration.dart';
import 'package:dargo/core/navigator/route_configuration.dart';
import 'package:dargo/core/navigator/route_dispatcher.dart';
import 'package:dargo/core/provider/provider.dart';
import 'package:flutter/material.dart';

//TODO: Eliminar la lista de guards, ya no se usará directo
class Dargo {
  final IoCContainer _ioc;
  final List<Provider> Function(IoCContainer) _providersFactory;
  final List<Guard> Function(IoCContainer) _guardsFactory;
  final RouteDispatcher Function(IoCContainer) _routeDispatcherFactory;
  final List<GuardConfiguration> Function(IoCContainer) _guardsConfiguration;
  final Widget Function(
    IoCContainer context,
    String initialRoute,
    GlobalKey<NavigatorState> navigatorKey,
    Route<dynamic> Function(RouteSettings)? onGenerateRoute,
  ) _appFactory;

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final DargoNavigator _navigator;
  late final List<Provider> _providers;
  late final List<Guard> _guards;
  late final RouteDispatcher _routeDispatcher;

  Dargo({
    IoCContainer? ioc,
    List<Provider> Function(IoCContainer)? providers,
    List<Guard> Function(IoCContainer)? guards,
    List<GuardConfiguration> Function(IoCContainer)? config,
    required RouteDispatcher Function(IoCContainer) routes,
    required Widget Function(
      IoCContainer context,
      String initialRoute,
      GlobalKey<NavigatorState> navigatorKey,
      Route<dynamic> Function(RouteSettings)? onGenerateRoute,
    ) appFactory,
  })  : _ioc = ioc ?? DefaultIoCContainer(),
        _providersFactory = providers ?? ((_) => []),
        _guardsFactory = guards ?? ((_) => []),
        _routeDispatcherFactory = routes,
        _appFactory = appFactory,
        _guardsConfiguration = config ?? ((_) => []);

  Future<Widget> build() async {
    _providers = _providersFactory(_ioc);
    _guards = _guardsFactory(_ioc);

    _navigator =
        DargoNavigator(_navigatorKey, _guards, _guardsConfiguration.call(_ioc));
    _ioc.register<DargoNavigator>((_) => _navigator);
    OmnipresentIoC.setIoc(_ioc);

    _routeDispatcher = _routeDispatcherFactory(_ioc);

    await _initProviders();
    await _bootProviders();

    final RouteConfiguration baseConfig = _routeDispatcher.directRoutes();
    final RouteConfiguration? installConfig =
        _routeDispatcher.installationRoutes(() => null);

    final bool isFirstInstalling = false;

    final initialConfig =
        isFirstInstalling ? installConfig ?? baseConfig : baseConfig;

    Route<dynamic> generateRoute(RouteSettings settings) {
      final matchedRoute = initialConfig.routes.firstWhere(
        (route) => route.name == settings.name,
        orElse: () => throw Exception('Route not found: ${settings.name}'),
      );

      return MaterialPageRoute(
        builder: (_) => matchedRoute.view,
        settings: settings,
      );
    }

    return _appFactory(
      _ioc,
      initialConfig.initialRoute,
      _navigatorKey,
      generateRoute,
    );
  }

  Future<void> _initProviders() async {
    for (final provider in _providers) {
      await provider.register();
    }
  }

  Future<void> _bootProviders() async {
    for (final provider in _providers) {
      await provider.boot();
    }
  }
}
