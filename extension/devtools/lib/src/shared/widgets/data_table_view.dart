import 'package:flutter/material.dart';

import '../../domain/entry.dart';
import '../utils/json_format.dart';

/// Key/value listing for a container's entries.
///
/// A plain `ListView` instead of Flutter's `DataTable` on purpose:
/// `DataTable` doesn't scroll/virtualize well for large row counts and
/// forces a fixed row height that doesn't suit multi-line JSON values.
/// Tapping a row (when [onTapEntry] is supplied) opens
/// `features/key_editor/key_editor_dialog.dart` from the caller — this
/// widget stays dumb/reusable and doesn't know about editing itself.
class DataTableView extends StatelessWidget {
  const DataTableView({super.key, required this.entries, this.onTapEntry});

  final List<ContainerEntry> entries;
  final ValueChanged<ContainerEntry>? onTapEntry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return ListTile(
          dense: true,
          title: Text(
            entry.key,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            prettyJson(entry.value),
            style: textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(entry.typeLabel, style: textTheme.labelSmall),
          onTap: onTapEntry == null ? null : () => onTapEntry!(entry),
        );
      },
    );
  }
}
