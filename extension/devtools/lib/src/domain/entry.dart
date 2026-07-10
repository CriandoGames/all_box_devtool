/// A single key/value row inside a container, as shown by
/// `features/container_detail`'s table. Thin wrapper over a
/// `MapEntry<String, dynamic>` from `ContainerSnapshot.entries` — exists
/// mainly to give the UI a stable, named type instead of passing raw
/// `MapEntry`s around, and a place to hang derived display info (runtime
/// type label) without recomputing it in every widget.
class ContainerEntry {
  const ContainerEntry({required this.key, required this.value});

  factory ContainerEntry.fromMapEntry(MapEntry<String, dynamic> entry) {
    return ContainerEntry(key: entry.key, value: entry.value);
  }

  final String key;
  final dynamic value;

  /// Best-effort label for the value's Dart type, as decoded from JSON
  /// (so this reflects JSON types — `int`/`double`, `String`, `bool`,
  /// `List`, `Map`, `null` — not the original Dart type on the inspected
  /// app's side; `all_box` only stores JSON-encodable values anyway).
  String get typeLabel {
    if (value == null) return 'null';
    if (value is bool) return 'bool';
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is String) return 'String';
    if (value is List) return 'List';
    if (value is Map) return 'Map';
    return value.runtimeType.toString();
  }

  @override
  String toString() => 'ContainerEntry($key: $value)';
}
