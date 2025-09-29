import 'package:dargo/core/provider/provider.dart';

import 'event_bus.dart';

class EventBusProvider extends Provider {
  EventBusProvider(super.context);

  @override
  Future<void> boot() async {
    context.register<EventBus>((context) => EventBus(context));
  }

  @override
  Future<void> register() async {}
}
