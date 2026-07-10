/// Shared layout constants for this extension's widgets.
///
/// `DevToolsExtension` (the root widget in `main.dart`) already themes
/// colors/typography to match the host DevTools window, so this file is
/// deliberately narrow — spacing only, no `ThemeData`/colors here.
///
/// **PT-BR:** Constantes de layout compartilhadas pelos widgets desta
/// extensão.
///
/// O `DevToolsExtension` (widget raiz em `main.dart`) já aplica tema de
/// cores/tipografia para combinar com a janela do DevTools que o hospeda,
/// então este arquivo é propositalmente restrito — apenas espaçamento, sem
/// `ThemeData`/cores aqui.
class AllBoxSpacing {
  const AllBoxSpacing._();

  static const double sm = 4;
  static const double md = 8;
  static const double lg = 16;
}
