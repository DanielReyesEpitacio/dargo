import 'package:dargo/core/reactive/rx.dart';

class RxList<T> extends Rx<List<T>> {
  RxList([List<T>? initial]) : super(initial ?? []);

  void add(T item) {
    value = [...value, item];
  }

  void remove(T item) {
    value = value.where((e) => e != item).toList();
  }

  void clear() {
    value = [];
  }
}
