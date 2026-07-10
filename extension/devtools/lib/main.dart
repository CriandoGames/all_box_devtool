import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';

import 'src/app/extension_app.dart';

void main() {
  runApp(const AllBoxDevToolsExtension());
}

/// Entry point required by `package:devtools_extensions` — see
/// https://docs.flutter.dev/tools/devtools/custom-tool. `DevToolsExtension`
/// handles the DevTools-to-extension handshake and populates the globals
/// (`serviceManager`, `extensionManager`, `dtdManager`) used throughout
/// `src/connection/`.
///
/// **PT-BR:** Ponto de entrada exigido pelo `package:devtools_extensions` —
/// veja https://docs.flutter.dev/tools/devtools/custom-tool. O
/// `DevToolsExtension` cuida do handshake entre o DevTools e a extensão e
/// popula os globais (`serviceManager`, `extensionManager`, `dtdManager`)
/// usados em todo o `src/connection/`.
class AllBoxDevToolsExtension extends StatelessWidget {
  const AllBoxDevToolsExtension({super.key});

  @override
  Widget build(BuildContext context) {
    return const DevToolsExtension(
      child: AllBoxExtensionApp(),
    );
  }
}
