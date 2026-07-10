import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around the DevTools-provided global `serviceManager`.
///
/// **PT-BR:** Wrapper fino sobre o `serviceManager` global fornecido pelo
/// DevTools.
class AllBoxConnectionStatus {
  const AllBoxConnectionStatus._();

  /// Whether DevTools has an active VM Service connection and has finished
  /// identifying the connected app.
  ///
  /// **PT-BR:** Se o DevTools tem uma conexão ativa com o VM Service e já
  /// terminou de identificar o app conectado.
  static bool get isConnected =>
      serviceManager.connectedState.value.connected &&
      serviceManager.connectedAppInitialized;

  /// Fires whenever connection status may have changed. Consumers should use
  /// this only as a rebuild trigger and re-read [isConnected].
  ///
  /// **PT-BR:** Dispara sempre que o status de conexão pode ter mudado.
  /// Consumidores devem usar isto apenas como gatilho de rebuild e reler
  /// [isConnected] em seguida.
  static Listenable get changes => serviceManager.connectedState;
}
