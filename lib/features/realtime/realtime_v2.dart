typedef RealtimeMiddleware =
    void Function(RealtimeContext, void Function(RealtimeContext));
typedef RealtimeGuard = bool Function(RealtimeContext);



abstract class RealtimeAdapter {
  void onMessage(void Function(dynamic) callback);

  void send(dynamic data);
}

class RealtimeConfig {
  final List<RealtimeMiddleware> globalMiddlewares;
  final List<RealtimeRouteDefinition> routes;

  const RealtimeConfig({
    this.globalMiddlewares = const [],
    this.routes = const [],
  });
}

class RealtimeRouteDefinition {
  final String route;
  final List<RealtimeGuard> guards;
  final List<RealtimeMiddleware> middlewares;
  final void Function(RealtimeContext, void Function()) handler;

  const RealtimeRouteDefinition({
    required this.route,
    required this.handler,
    this.guards = const [],
    this.middlewares = const [],
  });
}

class RealtimeContext<T> {
  final String localClientId;
  final String emitterClientId;
  final T applicationContext;

  const RealtimeContext({
    required this.localClientId,
    required this.emitterClientId,
    required this.applicationContext,
  });

}

class Realtime {
  final Map<Type, List<Function>> _listeners = const {};

  const Realtime();


  void on<T>(void Function(T) callback) {
    var listenerList = _listeners[T];
    if (listenerList == null) {
      _listeners[T] = [];
    }

    listenerList!.add(callback);
  }

  void off<T>(void Function(T) callback) {
    var listenerList = _listeners[T];

    if (listenerList == null) {
      return;
    }

    listenerList.remove(callback);
  }
}
