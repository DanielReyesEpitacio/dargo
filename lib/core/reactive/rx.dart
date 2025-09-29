import 'package:dargo/core/reactive/rx_tracker.dart';
import 'package:flutter/cupertino.dart';

class Rx<T> extends ValueNotifier<T> {
  Rx(super.value);

  @override
  T get value {
    RxTracker.notifyRead(this);
    return super.value;
  }
}

typedef RxInt = Rx<int>;
typedef RxBool = Rx<bool>;
typedef RxString = Rx<String>;
//typedef RxList<T> = Rx<List<T>>;
