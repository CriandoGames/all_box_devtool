import 'package:flutter/material.dart';

import '../../domain/container_snapshot.dart';
import '../../shared/utils/bytes_format.dart';
import '../../shared/widgets/badge.dart';

/// Compact summary of a container's storage state: backend kind,
/// pending-flush indicator, key count, and approximate size.
///
/// Pure display — every field it needs is already on [ContainerSnapshot]
/// (`AllBoxInspector.snapshotAsJson()` already includes all of it), so
/// this widget makes no VM Service calls of its own and doesn't belong
/// under `connection/`.
///
/// Deliberately does **not** show a file path or `localStorage` key:
/// `all_box`'s `AllBoxIoStorage`/`AllBoxWebStorage` don't expose those
/// publicly today (see ARCHITECTURE.md, "Fase 0 — o que foi feito" —
/// backend classification there is name-based specifically to avoid
/// importing those classes). Showing a real path would need a small
/// additive change on the `all_box` side first; left as a follow-up
/// rather than guessing at internals.
class StorageInfoPanel extends StatelessWidget {
  const StorageInfoPanel({super.key, required this.snapshot});

  final ContainerSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AllBoxBadge(label: snapshot.backendLabel, color: Colors.blueGrey),
        if (snapshot.pendingFlush)
          const AllBoxBadge(label: 'flush pending', color: Colors.orange),
        if (!snapshot.isInitialized)
          const AllBoxBadge(label: 'not initialized', color: Colors.red),
        Text('${snapshot.length} keys', style: textTheme.bodySmall),
        Text(
          '~${formatBytes(snapshot.approximateSizeBytes)}',
          style: textTheme.bodySmall,
        ),
      ],
    );
  }
}
