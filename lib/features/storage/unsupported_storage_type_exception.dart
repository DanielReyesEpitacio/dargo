class UnsupportedStorageTypeException implements Exception {
  final Type type;
  final String? key;

  UnsupportedStorageTypeException(this.type, {this.key});

  @override
  String toString() {
    final keyInfo = key != null ? 'for key "$key"' : '';
    return 'UnsupportedStorageTypeException: Type: "$type"$keyInfo is not supported by the current LocalStorage implementation ';
  }
}
