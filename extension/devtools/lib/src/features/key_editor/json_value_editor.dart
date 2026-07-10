import 'dart:convert';

import 'package:flutter/material.dart';

/// Multi-line JSON text editor with inline validation.
///
/// `all_box` only stores JSON-encodable values (`String`, `num`, `bool`,
/// `null`, `List`, `Map`), so editing "as raw JSON text" matches exactly
/// what can actually be written back — no separate per-type widgets
/// needed for the MVP.
class JsonValueEditor extends StatefulWidget {
  const JsonValueEditor({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.onValidityChanged,
  });

  /// Already-decoded JSON value (String/num/bool/null/List/Map) — this
  /// widget encodes it to pretty-printed text for the initial edit.
  final dynamic initialValue;

  /// Called with the freshly-decoded value every time the text parses as
  /// valid JSON. Not called while the text is invalid JSON — check
  /// [onValidityChanged] (or just disable "Save") for that case.
  final ValueChanged<dynamic> onChanged;

  /// Called with `true`/`false` whenever the text becomes valid/invalid
  /// JSON. Optional — callers that just want the latest valid value can
  /// skip it and rely on [onChanged] never firing for invalid text.
  final ValueChanged<bool>? onValidityChanged;

  @override
  State<JsonValueEditor> createState() => _JsonValueEditorState();
}

class _JsonValueEditorState extends State<JsonValueEditor> {
  static const _encoder = JsonEncoder.withIndent('  ');

  late final TextEditingController _controller = TextEditingController(
    text: _encoder.convert(widget.initialValue),
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String text) {
    try {
      final decoded = jsonDecode(text);
      if (_error != null) setState(() => _error = null);
      widget.onValidityChanged?.call(true);
      widget.onChanged(decoded);
    } on FormatException catch (e) {
      setState(() => _error = e.message);
      widget.onValidityChanged?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _handleChanged,
      maxLines: 10,
      minLines: 3,
      style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        errorText: _error,
        helperText: 'Raw JSON — must be a type all_box can store '
            '(String, num, bool, null, List, Map).',
        helperMaxLines: 2,
      ),
    );
  }
}
