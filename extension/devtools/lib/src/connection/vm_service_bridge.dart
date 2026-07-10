import 'dart:convert';

import 'package:devtools_app_shared/service.dart';
import 'package:devtools_extensions/devtools_extensions.dart';

import '../data/containers_repository.dart';

/// The only class in this extension that talks to the inspected app through
/// the VM Service.
///
/// **PT-BR:** A única classe nesta extensão que conversa com o app
/// inspecionado através do VM Service.
class AllBoxVmServiceBridge implements ContainersBridge {
  AllBoxVmServiceBridge();

  /// Library where `AllBox` and `AllBoxInspector` are actually *declared*.
  ///
  /// `package:all_box/all_box.dart` is a barrel file — it only has `export`
  /// statements, no local declarations. The VM Service's `evaluate` only
  /// resolves names declared directly in the target library, not names it
  /// re-exports from another file, so eval'ing against the barrel file
  /// fails to find `AllBoxInspector` (silently, returning a null
  /// `InstanceRef` instead of throwing). Pointing this at the file where
  /// both classes are actually declared fixes that.
  ///
  /// **PT-BR:** Biblioteca onde `AllBox` e `AllBoxInspector` são de fato
  /// *declarados*. `package:all_box/all_box.dart` é um barrel file — só tem
  /// `export`, nenhuma declaração local. O `evaluate` do VM Service só
  /// resolve nomes declarados diretamente na biblioteca alvo, não nomes
  /// reexportados de outro arquivo, então avaliar contra o barrel file falha
  /// em achar `AllBoxInspector` (silenciosamente, retornando um
  /// `InstanceRef` nulo em vez de lançar exceção). Apontar isso para o
  /// arquivo onde as duas classes são de fato declaradas resolve isso.
  static const _allBoxLibraryUri = 'package:all_box/src/core/all_box_impl.dart';

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
  ///
  /// **PT-BR:** Avalia [expression] em relação a
  /// `package:all_box/all_box.dart` e retorna a string Dart resultante.
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
  ///
  /// **PT-BR:** Retorna mapas de snapshot de containers já decodificados de
  /// JSON.
  @override
  Future<List<Map<String, dynamic>>> fetchSnapshot() async {
    final json = await _evalToString('AllBoxInspector.snapshotAsJson()');
    if (json.isEmpty) return const <Map<String, dynamic>>[];

    final decoded = jsonDecode(json);
    if (decoded is! List) return const <Map<String, dynamic>>[];
    return decoded.cast<Map<String, dynamic>>();
  }

  /// Returns a raw JSON-decoded snapshot for one container.
  ///
  /// **PT-BR:** Retorna um snapshot já decodificado de JSON para um único
  /// container.
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
  ///
  /// **PT-BR:** Escreve [value] sob [key] em [container] no app
  /// inspecionado.
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
  ///
  /// **PT-BR:** Remove [key] de [container] no app inspecionado.
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
