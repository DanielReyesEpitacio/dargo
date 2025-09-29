import 'package:dargo/core/navigator/dargo_navigator.dart';
import 'package:dargo/core/navigator/route_configuration.dart';
import 'package:dargo/core/navigator/route_definition.dart';
import 'package:dargo/core/navigator/route_dispatcher.dart';
import 'package:dargo/core/reactive/obx.dart';
import 'package:dargo/core/reactive/rx.dart';
import 'package:dargo/features/event_bus/event_bus.dart';
import 'package:dargo/features/realtime/realtime.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class AppRouteDispatcher extends RouteDispatcher {
  AppRouteDispatcher(super.context);

  @override
  RouteConfiguration directRoutes() {
    return RouteConfiguration(
      initialRoute: "user",
      routes: [
        RouteDefinition(
          name: "home",
          view: Scaffold(
            body: Center(child: Center(child: Text("data"))),
          ),
        ),
        RouteDefinition(
          name: "user",
          view: Test(
            navigator: context.inject<DargoNavigator>(),
            service: context.inject<Service>(),
            eventBus: context.inject<EventBus>(),
            realtimeCore: context.inject<RealtimeCore>(),
          ),
        ),
        RouteDefinition(
          name: "second",
          view: ViewTwo(
            navigator: context.inject<DargoNavigator>(),
            realtimeCore: context.inject<RealtimeCore>(),
          ),
        ),
      ],
    );
  }

  @override
  List<RouteDefinition> indirectRoutes(Function() arguments) {
    return [];
  }
}

class ViewTwo extends StatelessWidget {
  final DargoNavigator navigator;
  final RealtimeCore realtimeCore;

  const ViewTwo({
    super.key,
    required this.navigator,
    required this.realtimeCore,
  });

  @override
  Widget build(BuildContext context) {
    realtimeCore.on(
      "respuesta",
      (data) {print("Este es otro evento pero no hago nada jejej");},
    );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Otra vista"),
            ElevatedButton(
              onPressed: () => navigator.back(),
              child: const Text("Regresar"),
            ),
          ],
        ),
      ),
    );
  }
}

class Test extends StatelessWidget {
  final DargoNavigator navigator;
  final Service service;
  final EventBus eventBus;
  final RealtimeCore realtimeCore;

  @override
  Widget build(BuildContext context) {
    service.test();
    final counter = RxInt(0);

    realtimeCore.on("respuesta", (data) {
      print("Test recibido: ${data}");
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text("El nombre del usuario"),
        leading: const Icon(Icons.person),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("HOla dargo que hace?"),
            Obx(() => Text(counter.value.toString())),
            ElevatedButton(
              onPressed: () => counter.value = counter.value + 1,
              child: const Text("El child"),
            ),
            ElevatedButton(
              onPressed: () {
                eventBus.emit(new TestEvent("Todo ok"));
                navigator.to("second");
              },
              child: Text("Dale vato loto"),
            ),
          ],
        ),
      ),
    );
  }

  const Test({
    super.key,
    required this.navigator,
    required this.service,
    required this.eventBus,
    required this.realtimeCore,
  });
}
