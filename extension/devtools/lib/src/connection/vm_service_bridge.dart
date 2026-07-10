import 'dart:convert';

import 'package:devtools_app_shared/service.dart';
import 'package:devtools_extensions/devtools_extensions.dart';

import '../data/containers_repository.dart';

/// The only class in this extension that talks to the inspected app through
/// the VM Service.
class AllBoxVmServiceBridge implements ContainersBridge {
  AllBoxVmServiceBridge();

  /// Public `all_box` entrypoint that exports `AllBox` and `AllBoxInspector`.
  static const _allBoxLibraryUri = 'package:all_box/all_box.dart';

  EvalOnDartLibrary? _eval;

  EvalOnDartLibrary _evalOnAllBox() {
    final service = serviceManager.service;
    if (service == null) {
      throw StateError(
        'AllBoxVmServiceBridge: no active VM Service connection.',
      );
    }

    return _eval ??= EvalOnDartLibrary(
      _allBoxLibraryUri,
      service,
      serviceManager: serviceManager,
      isolate: serviceManager.isolateManager.mainIsolate,
    );
  }

  /// Evaluates [expression] against `package:all_box/all_box.dart` and
  /// returns the resulting Dart string.
  Future<String> _evalToString(String expression) async {
    final eval = _evalOnAllBox();
    final instanceRef = await eval.eval(expression, isAlive: null);
    if (instanceRef == null) {
      throw StateError(
        'AllBoxVmServiceBridge: `$expression` returned null. Is the '
        'inspected app using all_box >= 0.5.0?',
      );
    }

    final instance = await eval.safeGetInstance(instanceRef, null);
    return instance.valueAsString ?? '';
  }

  /// Returns raw JSON-decoded container snapshot maps.
  @override
  Future<List<Map<String, dynamic>>> fetchSnapshot() async {
    final json = await _evalToString('AllBoxInspector.snapshotAsJson()');
    if (json.isEmpty) return const <Map<String, dynamic>>[];

    final decoded = jsonDecode(json);
    if (decoded is! List) return const <Map<String, dynamic>>[];
    return decoded.cast<Map<String, dynamic>>();
  }

  /// Returns a raw JSON-decoded snapshot for one container.
  Future<Map<String, dynamic>?> fetchSnapshotOf(String container) async {
    final escaped = jsonEncode(container);
    final json = await _evalToString(
      'AllBoxInspector.snapshotOfAsJson($escaped)',
    );
    if (json.isEmpty || json == 'null') return null;

    final decoded = jsonDecode(json);
    if (decoded is! Map<String, dynamic>) return null;
    return decoded;
  }

  /// Writes [value] under [key] in [container] on the inspected app.
  @override
  Future<void> writeValue(String container, String key, dynamic value) async {
    final expression = '(() { '
        'AllBox(${jsonEncode(container)}).write(${jsonEncode(key)}, '
        '${jsonEncode(value)}); '
        "return 'ok'; "
        '})()';
    await _evalToString(expression);
  }

  /// Removes [key] from [container] on the inspected app.
  @override
  Future<void> removeKey(String container, String key) async {
    final expression = '(() { '
        'AllBox(${jsonEncode(container)}).remove(${jsonEncode(key)}); '
        "return 'ok'; "
        '})()';
    await _evalToString(expression);
  }

  @override
  void dispose() {
    _eval?.dispose();
    _eval = null;
  }
}
