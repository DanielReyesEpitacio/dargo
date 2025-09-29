import 'package:flutter/widgets.dart';

abstract class Guard {
  bool shouldApply({required String next}) => false;

  RouteSettings? beforeEnter({
    required String next,
    String? prev,
  });
}
