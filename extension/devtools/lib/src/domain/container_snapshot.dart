import 'storage_backend.dart';

/// Pure data model, mirroring `all_box`'s `AllBoxContainerSnapshot.toJson()`
/// output (see `all_box/lib/src/debug/all_box_container_snapshot.dart`).
///
/// No Flutter imports, no I/O, no dependency on `connection/` — this must
/// stay trivially testable/mockable without a real VM Service connection.
///
/// **PT-BR:** Modelo de dados puro, espelhando a saída de
/// `AllBoxContainerSnapshot.toJson()` do `all_box` (veja
/// `all_box/lib/src/debug/all_box_container_snapshot.dart`).
///
/// Sem imports do Flutter, sem I/O, sem dependência de `connection/` — isto
/// precisa continuar trivialmente testável/mockável sem uma conexão real
/// com o VM Service.
class ContainerSnapshot {
  const ContainerSnapshot({
    required this.container,
    required this.isInitialized,
    required this.backend,
    required this.backendDetail,
    required this.pendingFlush,
    required this.entries,
    required this.approximateSizeBytes,
  });

  factory ContainerSnapshot.fromJson(Map<String, dynamic> json) {
    final rawEntries = json['entries'];
    return ContainerSnapshot(
      container: json['container'] as String? ?? '',
      isInitialized: json['isInitialized'] as bool? ?? false,
      backend: AllBoxBackendKind.fromJson(json['backend']),
      backendDetail: json['backendDetail'] as String?,
      pendingFlush: json['pendingFlush'] as bool? ?? false,
      entries: rawEntries is Map
          ? Map<String, dynamic>.from(rawEntries)
          : const <String, dynamic>{},
      approximateSizeBytes:
          (json['approximateSizeBytes'] as num?)?.toInt() ?? 0,
    );
  }

  final String container;
  final bool isInitialized;
  final AllBoxBackendKind backend;
  final String? backendDetail;
  final bool pendingFlush;
  final Map<String, dynamic> entries;
  final int approximateSizeBytes;

  String get backendLabel => backend.label(backendDetail);

  List<String> get sortedKeys => entries.keys.toList()..sort();

  int get length => entries.length;

  /// Case-insensitive filter over key names, used by
  /// `features/container_detail`'s search field.
  ///
  /// **PT-BR:** Filtro case-insensitive sobre nomes de chave, usado pelo
  /// campo de busca de `features/container_detail`.
  ContainerSnapshot filteredByKey(String query) {
    if (query.isEmpty) return this;
    final needle = query.toLowerCase();
    final filtered = <String, dynamic>{
      for (final e in entries.entries)
        if (e.key.toLowerCase().contains(needle)) e.key: e.value,
    };
    return ContainerSnapshot(
      container: container,
      isInitialized: isInitialized,
      backend: backend,
      backendDetail: backendDetail,
      pendingFlush: pendingFlush,
      entries: filtered,
      approximateSizeBytes: approximateSizeBytes,
    );
  }

  @override
  String toString() => 'ContainerSnapshot($container, backend: $backend, '
      '${entries.length} keys, pendingFlush: $pendingFlush)';
}
