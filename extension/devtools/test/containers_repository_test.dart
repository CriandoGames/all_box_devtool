import 'dart:async';

import 'package:all_box_devtool_extension/src/data/containers_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('refresh stores parsed containers and clears errors', () async {
    final bridge = _FakeBridge()
      ..snapshots.add(
        Future.value([
          _snapshot('b'),
          _snapshot('a'),
        ]),
      );
    final repository = ContainersRepository(
      bridge: bridge,
      isConnected: () => true,
    );
    addTearDown(repository.dispose);

    await repository.refresh();

    expect(repository.lastError, isNull);
    expect(repository.isLoading, isFalse);
    expect(repository.containers.map((c) => c.container), ['a', 'b']);
  });

  test('concurrent refresh calls share one in-flight fetch', () async {
    final pending = Completer<List<Map<String, dynamic>>>();
    final bridge = _FakeBridge()..snapshots.add(pending.future);
    final repository = ContainersRepository(
      bridge: bridge,
      isConnected: () => true,
    );
    addTearDown(repository.dispose);

    final first = repository.refresh();
    final second = repository.refresh();

    expect(bridge.fetchCount, 1);
    expect(repository.isLoading, isTrue);

    pending.complete([_snapshot('main')]);
    await Future.wait([first, second]);

    expect(repository.containers.single.container, 'main');
    expect(repository.isLoading, isFalse);
  });

  test('write waits for older refresh then fetches a fresh snapshot', () async {
    final firstRefresh = Completer<List<Map<String, dynamic>>>();
    final bridge = _FakeBridge()
      ..snapshots.add(firstRefresh.future)
      ..snapshots.add(Future.value([_snapshot('after-write')]));
    final repository = ContainersRepository(
      bridge: bridge,
      isConnected: () => true,
    );
    addTearDown(repository.dispose);

    final pollingRefresh = repository.refresh();
    final write = repository.writeValue('main', 'key', 'value');

    expect(bridge.writeCalls, 1);
    expect(bridge.fetchCount, 1);

    firstRefresh.complete([_snapshot('before-write')]);
    await pollingRefresh;
    await write;

    expect(bridge.fetchCount, 2);
    expect(repository.containers.single.container, 'after-write');
  });

  test('refresh records connection error without calling bridge', () async {
    final bridge = _FakeBridge();
    final repository = ContainersRepository(
      bridge: bridge,
      isConnected: () => false,
    );
    addTearDown(repository.dispose);

    await repository.refresh();

    expect(repository.lastError, isA<StateError>());
    expect(bridge.fetchCount, 0);
  });
}

Map<String, dynamic> _snapshot(String container) {
  return {
    'container': container,
    'isInitialized': true,
    'backend': 'memory',
    'pendingFlush': false,
    'entries': <String, dynamic>{},
    'approximateSizeBytes': 0,
  };
}

class _FakeBridge implements ContainersBridge {
  final snapshots = <Future<List<Map<String, dynamic>>>>[];
  int fetchCount = 0;
  int writeCalls = 0;
  int removeCalls = 0;
  bool disposed = false;

  @override
  Future<List<Map<String, dynamic>>> fetchSnapshot() {
    fetchCount++;
    if (snapshots.isEmpty) {
      return Future.value(const <Map<String, dynamic>>[]);
    }
    return snapshots.removeAt(0);
  }

  @override
  Future<void> writeValue(String container, String key, dynamic value) async {
    writeCalls++;
  }

  @override
  Future<void> removeKey(String container, String key) async {
    removeCalls++;
  }

  @override
  void dispose() {
    disposed = true;
  }
}
