import 'dart:convert';

/// Compact preview of a JSON-decoded value, for table cells in
/// `container_detail`. Strings are shown as-is (no surrounding quotes);
/// everything else is JSON-encoded. Falls back to `.toString()` if
/// encoding fails for some reason — shouldn't happen in practice, since
/// values already round-tripped through `AllBoxContainerSnapshot.toJson()`
/// on the `all_box` side, which sanitizes non-encodable values into
/// placeholder strings before they ever reach this extension.
String prettyJson(dynamic value) {
  if (value == null) return 'null';
  if (value is String) return value;
  try {
    return jsonEncode(value);
  } on Object {
    return value.toString();
  }
}
