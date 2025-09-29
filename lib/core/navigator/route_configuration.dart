import 'route_definition.dart';

class RouteConfiguration {
  final String initialRoute;
  final List<RouteDefinition> routes;

  const RouteConfiguration({
    required this.initialRoute,
    required this.routes,
  });
}
