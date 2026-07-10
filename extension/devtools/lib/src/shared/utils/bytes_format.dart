/// Formats a byte count as a short, human-readable string (`B`/`KB`/`MB`).
/// Used for `ContainerSnapshot.approximateSizeBytes` in the containers
/// list.
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
}
