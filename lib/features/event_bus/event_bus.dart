import 'package:dargo/core/ioc/ioc_container.dart';

class EventBus {
  final IoCContainer _container;

  EventBus(this._container);

  void emit<T>(T event) {
    var listeners = _container.injectAll<EventListener<T>>();

    for (var listener in listeners) {
      listener.onEvent(event);
    }
  }
}

abstract class AppEvent {}

abstract class EventListener<T> {
  void onEvent(T event);
}
