import 'package:dargo/core/ioc/omnipresent_ioc.dart';
import 'package:dargo/features/event_bus/event_bus.dart';

T? inject<T>() => OmnipresentIoC.inject<T>();
void emit<T>(T event) {
  var eventBus = OmnipresentIoC.inject<EventBus>();
  eventBus?.emit<T>(event);
}
