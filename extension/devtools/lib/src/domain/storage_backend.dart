/// Which concrete storage backend a container is currently persisted with.
///
/// Deliberately duplicated from `all_box`'s own `AllBoxBackendKind` (see
/// `all_box/lib/src/debug/all_box_container_snapshot.dart`) instead of
/// importing it: this extension runs in a separate process/isolate from
/// the inspected app and only ever receives its data as JSON strings over
/// the VM Service `eval` boundary (see `connection/vm_service_bridge.dart`)
/// — it cannot share Dart types with the inspected app directly.
enum AllBoxBackendKind {
  io,
  web,
  memory,
  unsupported,
  custom;

  /// Parses the `backend` field produced by
  /// `AllBoxContainerSnapshot.toJson()` (an enum `.name`, e.g. `'io'`).
  /// Falls back to [unsupported] for anything unrecognized, so a future
  /// `all_box` version adding a new backend kind doesn't crash the panel
  /// — it just shows up as "unsupported" until this extension is updated.
  static AllBoxBackendKind fromJson(Object? raw) {
    if (raw is! String) return AllBoxBackendKind.unsupported;
    return AllBoxBackendKind.values.firstWhere(
      (kind) => kind.name == raw,
      orElse: () => AllBoxBackendKind.unsupported,
    );
  }

  /// Short label for badges/tables.
  String get label {
    switch (this) {
      case AllBoxBackendKind.io:
        return 'IO (disk)';
      case AllBoxBackendKind.web:
        return 'Web (localStorage)';
      case AllBoxBackendKind.memory:
        return 'Memory';
      case AllBoxBackendKind.unsupported:
        return 'Unsupported';
      case AllBoxBackendKind.custom:
        return 'Custom';
    }
  }
}
