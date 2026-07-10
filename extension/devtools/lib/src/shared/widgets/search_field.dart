import 'package:flutter/material.dart';

/// Simple search/filter text field shared by `containers_list` and
/// `container_detail`.
///
/// Internally uncontrolled on purpose: it owns its own
/// `TextEditingController`, seeded once from [value] in `initState`.
/// Rebuilding it with a different [value] after the first build does
/// *not* move the cursor/selection — this avoids the classic Flutter bug
/// of fighting a controller that's recreated on every parent rebuild
/// (which would reset the cursor to the end on every keystroke). The
/// parent should treat [value] as "initial text" and get updates only
/// through [onChanged].
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.onChanged,
    this.value = '',
    this.hintText,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String? hintText;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        isDense: true,
        prefixIcon: const Icon(Icons.search, size: 18),
        hintText: widget.hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
