import 'package:flutter/widgets.dart';

class RouteDefinition {
  final String name;
  final String? tag;
  final Widget view;
  final Object? controller;

  const RouteDefinition({
    required this.name,
    this.tag,
    required this.view,
    this.controller,
  });
}
