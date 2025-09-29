class RouteInfo {
  final String name;
  final String? previousRouteName;
  final List<String> tags;

  const RouteInfo({
    required this.name,
    this.tags = const [],
    this.previousRouteName,
  });
}
