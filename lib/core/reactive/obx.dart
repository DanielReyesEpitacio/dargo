import 'package:dargo/core/reactive/rx.dart';
import 'package:dargo/core/reactive/rx_tracker.dart';
import 'package:flutter/widgets.dart';

class Obx extends StatefulWidget {
  final Widget Function() builder;

  const Obx(this.builder, {super.key});

  @override
  State<Obx> createState() => _ObxState();
}

class _ObxState extends State<Obx> {
  final List<Rx> _observables = [];

  void _trackObservables() {
    _observables.clear();
    RxTracker.startTracking((rx) {
      if (!_observables.contains(rx)) {
        _observables.add(rx);
        rx.addListener(_onChange);
      }
    });

    widget.builder();
    RxTracker.stopTracking();
  }

  void _onChange() => setState(() {});

  @override
  void initState() {
    super.initState();
    _trackObservables();
  }

  @override
  void dispose() {
    for (final rx in _observables) {
      rx.removeListener(_onChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder();
  }
}
