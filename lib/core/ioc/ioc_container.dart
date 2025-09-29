enum BeanScope { singleton, transient }

typedef BeanFactory<T> = T Function(IoCContainer);

abstract class IoCContainer {
  void register<T>(BeanFactory<T> factory, {String? tag});
  T inject<T>({BeanScope? scope, String? qualifier});
  T injectOf<T, U>({BeanScope? scope});
  List<T> injectAll<T>();
}
