import 'package:dargo/core/navigator/guards/guard.dart';
import 'package:dargo/core/navigator/guards/guard_configuration.dart';
import 'package:dargo/core/provider/provider.dart';
import 'package:dargo/features/event_bus/event_bus.dart';
import 'package:dargo/features/event_bus/event_bus_provider.dart';
import 'package:dargo/features/realtime/realtime.dart';
import 'package:dargo/test/app_route_dispatcher.dart';
import 'package:flutter/material.dart';

import 'core/dargo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var application = await Dargo(
    providers: (context) => [
      EventBusProvider(context),
      TestProvider(context),
      ListenersProvider(context),
      RealtimeProvider(context),
    ],
    config: (context) => [
      GuardConfiguration(guard: TestGuard(), applyOn: (routeInfo) => true),
    ],
    routes: (context) => AppRouteDispatcher(context),
    appFactory: (context, initialRoute, navigatorKey, onGenerateRoute) => MyApp(
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
      onGenerateRoute: onGenerateRoute,
    ),
  ).build();

  runApp(application);
}

class RealtimeProvider extends Provider {
  final MockAdapter adapter = MockAdapter();

  RealtimeProvider(super.context);

  @override
  Future<void> register() async {
    context.register<RealtimeCore>(
      (context) => RealtimeCore(
        adapter: adapter,
        context: {"emitterClientId": "El emitter clientId"},
        routes: [
          RealtimeRouteDefinition(event: "test", handler: (ctx) async {
            ctx.emit<Map<String,dynamic>>.call('respuesta',{
              "status":"ok",
              "receivedAt":DateTime.now().toIso8601String(),
            });
          }),
        ],
      ),
    );
  }

  @override
  Future<void> boot() async {
    var realtime = context.inject<RealtimeCore>();
    realtime.start();
    adapter.startEmittingTestEvents();

    Future.delayed(Duration(seconds: 100),(){
      adapter.stopEmitting();
      print("Prueba completada");
    });
  }
}

class ListenersProvider extends Provider {
  ListenersProvider(super.context);

  @override
  Future<void> boot() async {
    context.register<EventListener<TestEvent>>((context) => TestListener());
    context.register<EventListener<TestEvent>>(
      (context) => SecondTestListener(),
    );
  }

  @override
  Future<void> register() async {}
}

class TestEvent {
  final String msg;

  const TestEvent(this.msg);
}

class TestListener implements EventListener<TestEvent> {
  @override
  void onEvent(TestEvent event) {
    print("Evento detectado ${event.msg}");
  }
}

class SecondTestListener implements EventListener<TestEvent> {
  @override
  void onEvent(TestEvent event) {
    print("El segundo Listener: ${event.msg}");
  }
}

class ListenersProviders extends Provider {
  ListenersProviders(super.context);

  @override
  Future<void> boot() async {
    context.register<EventListener<TestEvent>>((factory) => TestListener());
  }

  @override
  Future<void> register() async {
    // TODO: implement register
  }
}

class TestProvider extends Provider {
  TestProvider(super.context);

  @override
  Future<void> boot() async {}

  @override
  Future<void> register() async {
    context.register<Service>((_) => Service());
  }
}

class Service {
  void test() {
    print("Este es un servicio de ejemplo jeje");
  }
}

class TestGuard extends Guard {
  @override
  RouteSettings? beforeEnter({required String next, String? prev}) {
    print("Este es un guard");
    return RouteSettings(name: "home");
  }
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String initialRoute;
  final Route<dynamic> Function(RouteSettings)? onGenerateRoute;

  const MyApp({
    super.key,
    required this.navigatorKey,
    required this.initialRoute,
    this.onGenerateRoute,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
      onGenerateRoute: onGenerateRoute,
    );
  }
}
