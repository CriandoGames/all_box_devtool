import 'package:all_box_devtool_extension/src/domain/storage_backend.dart';
import 'package:all_box_devtool_extension/src/domain/container_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson parses snapshot fields with safe fallbacks', () {
    final snapshot = ContainerSnapshot.fromJson({
      'container': 'settings',
      'isInitialized': true,
      'backend': 'memory',
      'backendDetail': 'testMemory',
      'pendingFlush': false,
      'entries': {'theme': 'dark', 'count': 2},
      'approximateSizeBytes': 42,
    });

    expect(snapshot.container, 'settings');
    expect(snapshot.isInitialized, isTrue);
    expect(snapshot.backend, AllBoxBackendKind.memory);
    expect(snapshot.backendDetail, 'testMemory');
    expect(snapshot.backendLabel, 'Memory');
    expect(snapshot.pendingFlush, isFalse);
    expect(snapshot.entries, {'theme': 'dark', 'count': 2});
    expect(snapshot.approximateSizeBytes, 42);
  });

  test('filteredByKey filters case-insensitively without mutating source', () {
    final snapshot = ContainerSnapshot.fromJson({
      'container': 'settings',
      'backend': 'memory',
      'entries': {'ThemeMode': 'dark', 'token': 'abc'},
    });

    final filtered = snapshot.filteredByKey('theme');

    expect(filtered.entries, {'ThemeMode': 'dark'});
    expect(snapshot.entries, {'ThemeMode': 'dark', 'token': 'abc'});
  });

  test('backendLabel includes optional all_box web backend detail', () {
    final localStorage = ContainerSnapshot.fromJson({
      'container': 'settings',
      'backend': 'web',
      'backendDetail': 'localStorage',
    });
    final indexedDb = ContainerSnapshot.fromJson({
      'container': 'settings',
      'backend': 'web',
      'backendDetail': 'indexedDBMigration',
    });

    expect(localStorage.backendLabel, 'Web (localStorage)');
    expect(indexedDb.backendLabel, 'Web (IndexedDB migration)');
  });
}
