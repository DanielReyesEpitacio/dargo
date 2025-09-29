import 'dart:async';

typedef RealtimeMiddleware = Future<void> Function(
    RealtimeContext ctx, Future<void> Function() next);
typedef RealtimeGuard = bool Function(RealtimeContext ctx);
typedef RealtimeHandler = Future<void> Function(RealtimeContext ctx);
typedef RealtimeEventCallback<T> = void Function(T data);

abstract interface class RealtimeAdapter {
  void Function(String event, Map<String, dynamic> payload)? onMessage;

  void send(String event, Map<String, dynamic> data);
  void broadcast(String event, Map<String, dynamic> data);
  void off(String event, void Function(dynamic data) callback);
}

class RealtimeContext<T> {
  final String type;
  final Map<String, dynamic>? payload;
  final String? channel;
  final String? applicationId;
  final String? emitterClientId;
  final String? localClientId;
  final T appContext;
  final void Function(String, Map<String, dynamic>) send;
  final void Function(String, Map<String, dynamic>) broadcast;
  final void Function<T>(String, T) emit;
  final Map<String, dynamic> meta = {};

  RealtimeContext({
    required this.type,
    this.payload,
    this.channel,
    this.applicationId,
    this.emitterClientId,
    this.localClientId,
    required this.send,
    required this.broadcast,
    required this.emit,
    required this.appContext,
  });
}

class RealtimeRouteDefinition {
  final String event;
  final List<RealtimeGuard> guards;
  final List<RealtimeMiddleware> middlware;
  final RealtimeHandler handler;

  const RealtimeRouteDefinition(
      {required this.event,
      required this.handler,
      this.guards = const [],
      this.middlware = const []});
}

class _RealtimeRoute {
  final List<RealtimeGuard> guards;
  final List<RealtimeMiddleware> middleware;
  final RealtimeHandler handler;

  const _RealtimeRoute(
      {required this.guards, required this.middleware, required this.handler});
}

class RealtimeCore {
  final List<RealtimeMiddleware> _globalMiddleware = [];
  final Map<String, _RealtimeRoute> _routes = {};
  final Map<String, List<RealtimeEventCallback<dynamic>>> _eventListeners = {};
  late final RealtimeAdapter _adapter;
  Map<String, dynamic> _appContext = {};
  String? _clientId;

  RealtimeCore(
      {required RealtimeAdapter adapter,
      Map<String, dynamic> context = const {},
      List<RealtimeMiddleware> middleware = const [],
      List<RealtimeRouteDefinition> routes = const []}) {
    _adapter = adapter;
    _appContext = context;
    _clientId = context["clientId"];
    _globalMiddleware.addAll(middleware);
    registerRoutes(routes);
  }

  void registerRoutes(List<RealtimeRouteDefinition> routes) {
    for (final route in routes) {
      _routes[route.event] = _RealtimeRoute(
          guards: route.guards,
          middleware: route.middlware,
          handler: route.handler);
    }
  }

  void on(String event, RealtimeEventCallback callback) {
    _eventListeners.putIfAbsent(event, () => []).add(callback);
  }

  void off(String event, RealtimeEventCallback callback) {
    _eventListeners[event]?.remove(callback);
    _adapter.off(event, callback);
  }

  void emit<T>(String event, T data) {
    final callbacks = _eventListeners[event] ?? [];
    for (final RealtimeEventCallback<T> cb in callbacks.cast<RealtimeEventCallback<T>>()) {
      cb(data);
    }
  }

  void start() {
    _adapter.onMessage = (type, fullPayload) async {
      final ctx = _createContext(type, fullPayload);
      try {
        await _runMiddleware(_globalMiddleware, ctx);
        final route = _routes[type];

        if (route == null) {
          ctx.send.call('info', {"message": "Ruta no encontrada"});
          return;
        }

        if (!_runGuards(route.guards, ctx)) return;
        await _runMiddleware(route.middleware, ctx);
        await route.handler(ctx);
      } catch (e) {
        ctx.send.call('error', {"message": e.toString()});
      }
    };
  }

  bool _runGuards(List<RealtimeGuard> guards, RealtimeContext ctx) {
    for (final guard in guards) {
      if (!guard(ctx)) return false;
    }

    return true;
  }

  Future<void> _runMiddleware(
      List<RealtimeMiddleware> middleware, RealtimeContext ctx) async {
    var index = -1;

    Future<void> next([int i = 0]) async {
      if (i <= index) throw Exception("next() llamado multiples veces");
      index = i;
      if (i < middleware.length) {
        await middleware[i](ctx, () => next(i + 1));
      }
    }

    await next();
  }

  RealtimeContext _createContext(
      String type, Map<String, dynamic> fullPayload) {
    return RealtimeContext(
      type: type,
      payload: fullPayload["payload"],
      channel: fullPayload["channel"],
      applicationId: fullPayload["applicationId"],
      emitterClientId: fullPayload["emitterClientId"],
      localClientId: _clientId,
      send: _adapter.send,
      broadcast: _adapter.broadcast,
      emit: emit,
      appContext: _appContext,
    );
  }
}

class MockAdapter implements RealtimeAdapter {
  @override
  void Function(String event, Map<String, dynamic> payload)? onMessage;

  Timer? _timer;
  int _counter = 0;

  @override
  void send(String event, Map<String, dynamic> data) {
    print('MockAdapter.send: $event, $data');
  }

  @override
  void broadcast(String event, Map<String, dynamic> data) {
    print('MockAdapter.broadcast: $event, $data');
  }

  @override
  void off(String event, void Function(dynamic data) callback) {
    print('MockAdapter.off: $event');
  }

  void startEmittingTestEvents() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      _counter++;
      final payload = {
        'payload': {
          'message': 'Evento de prueba #$_counter',
          'timestamp': DateTime.now().toIso8601String()
        },
        'channel': 'test-channel',
        'applicationId': 'test-app',
        'clientId': 'test-client',
      };

      onMessage?.call('test', payload);
    });
  }

  void stopEmitting() {
    _timer?.cancel();
  }
}

void main() {
  final adapter = MockAdapter();

  final realtime = RealtimeCore(adapter: adapter, context: {
    "clientId": "El clientId"
  }, routes: [
    RealtimeRouteDefinition(
        event: "test",
        handler: (ctx) async {
          print("Manejador ejecutad");
          ctx.emit<Map<String,dynamic>>.call('respuesta',
              {'status': 'ok', 'receivedAt': DateTime.now().toIso8601String()});
        })
  ]);

  realtime.on("respuesta", (data) {
    print("Test recibido: ${data}");
  });

  realtime.start();
  adapter.startEmittingTestEvents();

  Future.delayed(Duration(seconds: 30),(){
    adapter.stopEmitting();
    print("Prueba completada");
  });
}
