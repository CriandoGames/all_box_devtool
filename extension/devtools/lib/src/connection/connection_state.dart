import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around the DevTools-provided global `serviceManager`.
class AllBoxConnectionStatus {
  const AllBoxConnectionStatus._();

  /// Whether DevTools has an active VM Service connection and has finished
  /// identifying the connected app.
  static bool get isConnected =>
      serviceManager.connectedState.value.connected &&
      serviceManager.connectedAppInitialized;

  /// Fires whenever connection status may have changed. Consumers should use
  /// this only as a rebuild trigger and re-read [isConnected].
  static Listenable get changes => serviceManager.connectedState;
}
