import 'package:flutter/material.dart';

import '../../data/containers_repository.dart';
import 'json_value_editor.dart';

/// Dialog to view, edit, or delete a single entry of a container.
class KeyEditorDialog extends StatefulWidget {
  const KeyEditorDialog({
    super.key,
    required this.repository,
    required this.container,
    required this.entryKey,
    required this.initialValue,
  });

  final ContainersRepository repository;
  final String container;
  final String entryKey;
  final dynamic initialValue;

  /// Shows the dialog. Returns `true` if a write or delete happened,
  /// `false`/`null` if the user cancelled.
  static Future<bool?> show(
    BuildContext context, {
    required ContainersRepository repository,
    required String container,
    required String entryKey,
    required dynamic initialValue,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => KeyEditorDialog(
        repository: repository,
        container: container,
        entryKey: entryKey,
        initialValue: initialValue,
      ),
    );
  }

  @override
  State<KeyEditorDialog> createState() => _KeyEditorDialogState();
}

class _KeyEditorDialogState extends State<KeyEditorDialog> {
  late dynamic _pendingValue = widget.initialValue;
  bool _valid = true;
  bool _busy = false;
  Object? _error;

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() => _run(
        () => widget.repository.writeValue(
          widget.container,
          widget.entryKey,
          _pendingValue,
        ),
      );

  Future<void> _delete() => _run(
        () => widget.repository.removeKey(widget.container, widget.entryKey),
      );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(widget.entryKey, overflow: TextOverflow.ellipsis),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Container: ${widget.container}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            JsonValueEditor(
              initialValue: widget.initialValue,
              onChanged: (value) => _pendingValue = value,
              onValidityChanged: (valid) => setState(() => _valid = valid),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                'Failed: $_error',
                style: TextStyle(color: colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _busy ? null : _delete,
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
          child: const Text('Delete'),
        ),
        FilledButton(
          onPressed: _busy || !_valid ? null : _save,
          child: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
