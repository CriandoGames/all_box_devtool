import 'package:all_observer/all_observer.dart';

import '../domain/container_snapshot.dart';

abstract class ContainersBridge {
  Future<List<Map<String, dynamic>>> fetchSnapshot();

  Future<void> writeValue(String container, String key, dynamic value);

  Future<void> removeKey(String container, String key);

  void dispose();
}

/// Single source of truth for the containers currently visible in the
/// inspected app.
///
/// The extension is pull-based because `all_box` 0.5.0 exposes debug
/// snapshots, not mutation events. [PollingController] and manual refresh
/// actions call [refresh] to fetch a new snapshot through the VM Service.
class ContainersRepository {
  ContainersRepository({
    required ContainersBridge bridge,
    required bool Function() isConnected,
  })  : _bridge = bridge,
        _isConnected = isConnected;

  final ContainersBridge _bridge;
  final bool Function() _isConnected;

  final _containers = Observable<List<ContainerSnapshot>>(
    const <ContainerSnapshot>[],
  );
  final _isLoading = false.obs;
  final _lastError = Observable<Object?>(null);

  Future<void>? _refreshInFlight;

  List<ContainerSnapshot> get containers => _containers.value;
  bool get isLoading => _isLoading.value;
  Object? get lastError => _lastError.value;

  /// Re-fetches every container from the inspected app.
  ///
  /// Concurrent calls share the same in-flight future instead of starting
  /// duplicate VM Service evaluations.
  Future<void> refresh() {
    return _refreshInFlight ??= _runRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<void> _runRefresh() async {
    if (!_isConnected()) {
      _lastError.value = StateError('Not connected to an inspected app.');
      return;
    }

    _isLoading.value = true;
    try {
      final raw = await _bridge.fetchSnapshot();
      _containers.value = raw.map(ContainerSnapshot.fromJson).toList(
            growable: false,
          )..sort((a, b) => a.container.compareTo(b.container));
      _lastError.value = null;
    } on Object catch (error, stackTrace) {
      // ignore: avoid_print
      print(
        'all_box_devtool DEBUG: refresh failed — '
        'type=${error.runtimeType}, error=$error\n$stackTrace',
      );
      _lastError.value = error;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Writes [value] under [key] in [container] on the inspected app, then
  /// fetches a fresh snapshot so callers see the new value immediately.
  Future<void> writeValue(String container, String key, dynamic value) async {
    await _bridge.writeValue(container, key, value);
    await _refreshAfterMutation();
  }

  /// Removes [key] from [container] on the inspected app, then fetches a
  /// fresh snapshot. See [writeValue].
  Future<void> removeKey(String container, String key) async {
    await _bridge.removeKey(container, key);
    await _refreshAfterMutation();
  }

  Future<void> _refreshAfterMutation() async {
    final inFlight = _refreshInFlight;
    if (inFlight != null) {
      await inFlight;
    }
    await refresh();
  }

  /// Look up an already-fetched container by name, without a new round
  /// trip. Returns `null` if [refresh] has not found it.
  ContainerSnapshot? byName(String container) {
    for (final snapshot in _containers.value) {
      if (snapshot.container == container) return snapshot;
    }
    return null;
  }

  void dispose() {
    _bridge.dispose();
    _containers.close();
    _isLoading.close();
    _lastError.close();
  }
}
