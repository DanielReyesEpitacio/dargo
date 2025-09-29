import '../ioc/ioc_container.dart';
import 'route_configuration.dart';
import 'route_definition.dart';

abstract class RouteDispatcher {
  final IoCContainer context;

  const RouteDispatcher(this.context);

  RouteConfiguration directRoutes();

  List<RouteDefinition> indirectRoutes(dynamic Function() arguments);

  RouteConfiguration? installationRoutes(dynamic Function() arguments) => null;
}
