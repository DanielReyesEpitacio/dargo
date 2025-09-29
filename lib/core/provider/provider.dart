import 'package:dargo/core/ioc/ioc_container.dart';

abstract class Provider {
  final IoCContainer context;

  const Provider(this.context);

  Future<void> register();

  Future<void> boot();
}
