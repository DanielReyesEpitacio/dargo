import 'package:dargo/core/navigator/guards/guard.dart';
import 'package:dargo/core/navigator/guards/route_info.dart';

typedef GuardPredicate = bool Function(RouteInfo);

class GuardConfiguration {
  final Guard guard;
  final GuardPredicate applyOn;

  const GuardConfiguration({required this.guard, required this.applyOn});
}
