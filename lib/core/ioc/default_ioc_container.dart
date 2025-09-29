import 'ioc_container.dart';

class DefaultIoCContainer implements IoCContainer {
  final Map<Type, List<_BeanEntry>> _registry = {};

  @override
  void register<T>(BeanFactory<T> factory,
      {String? tag, BeanScope scope = BeanScope.singleton}) {
    final entry = _BeanEntry<T>(factory: factory, scope: scope, tag: tag);
    _registry.putIfAbsent(T, () => []).add(entry);
  }

  @override
  T inject<T>({BeanScope? scope, String? qualifier}) {
    final entries = _registry[T];
    if (entries == null || entries.isEmpty) {
      throw Exception("Dependencia no registrada para tipo $T");
    }

    final entry = (qualifier != null)
        ? entries.firstWhere(
            (e) => e.tag == qualifier,
            orElse: () => throw Exception(
                "No se encontró implementación con qualifier '$qualifier'"),
          ) as _BeanEntry<T>
        : entries.first as _BeanEntry<T>;

    if (entry.scope == BeanScope.singleton) {
      entry._instance ??= entry.factory(this);
      return entry._instance!;
    } else {
      return entry.factory(this);
    }
  }

  @override
  List<T> injectAll<T>() {
    final entries = _registry[T];
    if (entries == null) return [];
    return entries.map<T>((entry) {
      if (entry.scope == BeanScope.singleton) {
        entry._instance ??= entry.factory(this);
        return entry._instance!;
      } else {
        return entry.factory(this);
      }
    }).toList();
  }

  @override
  T injectOf<T, U>({BeanScope? scope}) {
    final entries = _registry[T];
    if (entries == null || entries.isEmpty) {
      throw Exception("Dependencia no registrada para tipo $T");
    }

    final entry = entries.firstWhere(
      (e) => e.factory(this) is U,
      orElse: () => throw Exception("No se encontró implementación de tipo $U"),
    );

    if (entry.scope == BeanScope.singleton) {
      entry._instance ??= entry.factory(this);
      return entry._instance!;
    } else {
      return entry.factory(this);
    }
  }
}

class _BeanEntry<T> {
  final BeanFactory<T> factory;
  final BeanScope scope;
  final String? tag;
  T? _instance;

  _BeanEntry({required this.factory, required this.scope, this.tag});
}
