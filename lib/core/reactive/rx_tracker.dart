import 'package:dargo/core/reactive/rx.dart';

typedef _ReadCallback = void Function(Rx rx);

class RxTracker {
  static _ReadCallback? _callback;

  static void startTracking(_ReadCallback callback) {
    _callback = callback;
  }

  static void stopTracking() {
    _callback = null;
  }

  static void notifyRead(Rx rx) {
    _callback?.call(rx);
  }
}
