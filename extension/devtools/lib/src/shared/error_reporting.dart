/// Single place where every caught exception in this extension gets logged
/// and translated into something a user can act on.
///
/// This extension talks to the inspected app exclusively through VM Service
/// `eval`, which is a wide surface for things to go wrong in ways that have
/// nothing to do with a bug in the user's code — wrong library URI, a stale
/// build, a disconnected isolate, an `all_box` version mismatch, or (as
/// happened during development — see git history / CHANGELOG) a bug in how
/// this extension itself calls `EvalOnDartLibrary`. The goal here is that
/// *our* bugs are exactly as diagnosable as the user's.
///
/// **PT-BR:** Único lugar onde toda exceção capturada nesta extensão é
/// logada e traduzida em algo que o usuário consiga agir. Esta extensão só
/// conversa com o app inspecionado via `eval` do VM Service, uma superfície
/// ampla para erros que não têm nada a ver com um bug do código do usuário —
/// URI de library errada, build desatualizado, isolate desconectado,
/// incompatibilidade de versão do `all_box`, ou (como já aconteceu durante o
/// desenvolvimento) um bug em como esta própria extensão chama
/// `EvalOnDartLibrary`. O objetivo aqui é que os *nossos* bugs sejam tão
/// diagnosticáveis quanto os do usuário.
library;

import 'package:devtools_app_shared/service.dart';
import 'package:flutter/foundation.dart';
import 'package:vm_service/vm_service.dart' show RPCError, Sentinel;

/// Logs [error]/[stackTrace] to the browser console with a consistent,
/// greppable prefix, tagged with where it was caught from.
///
/// Always logs (this is a debug/profile-only developer tool, not a shipped
/// app — there's no "too verbose for prod" concern here), so anyone hitting
/// a bug can open the console and immediately see the real exception type
/// and stack trace, instead of whatever a bare `$error` happens to print
/// (which, for exception types with no custom `toString()`, is just
/// `Instance of 'SomeType'` — actively unhelpful, and in `--release` builds
/// `SomeType` itself is minified on top of that).
///
/// **PT-BR:** Loga [error]/[stackTrace] no console do navegador com um
/// prefixo consistente e fácil de buscar, marcado com a origem da captura.
/// Sempre loga (esta é uma ferramenta de desenvolvedor debug/profile-only,
/// não um app publicado — não existe aqui a preocupação de "verboso demais
/// para produção"), então qualquer pessoa que encontrar um bug pode abrir o
/// console e ver imediatamente o tipo real da exceção e o stack trace, em
/// vez do que um `$error` puro imprime (que, para tipos de exceção sem
/// `toString()` próprio, é só `Instance of 'SomeType'` — nada útil, e em
/// builds `--release` até o `SomeType` vem minificado).
void logCaughtError(String where, Object error, StackTrace stackTrace) {
  debugPrint(
    '[all_box_devtool] $where failed — '
    'type: ${error.runtimeType}, error: $error\n'
    '$stackTrace',
  );
}

/// Turns [error] into a message a user can act on, shown directly in the
/// panel UI.
///
/// Falls back to a generic-but-still-actionable message ("check the browser
/// console, or file an issue") for anything not explicitly recognized below
/// — this list is expected to grow as new failure modes are found, not to
/// be exhaustive from day one.
///
/// **PT-BR:** Transforma [error] numa mensagem que o usuário consiga agir,
/// mostrada direto na UI do painel. Cai num fallback genérico-mas-ainda-
/// acionável ("olhe o console do navegador, ou abra uma issue") para
/// qualquer coisa não reconhecida explicitamente abaixo — esta lista deve
/// crescer conforme novos modos de falha forem encontrados, não é pra ser
/// exaustiva desde o primeiro dia.
String friendlyErrorMessage(Object error) {
  // Our own bridge code throws StateError with an already-actionable,
  // specific message (see vm_service_bridge.dart) — surface it as-is.
  if (error is StateError) {
    return error.message;
  }

  if (error is CancelledException) {
    return 'The request to the inspected app was cancelled before it '
        'finished — this is usually transient (e.g. right after a hot '
        'restart or a DevTools reconnect). Wait a moment and try the '
        'refresh button again; if it keeps happening, please file an issue.';
  }

  if (error is LibraryNotFound) {
    return "Could not find the `${error.name}` library in the inspected "
        "app's isolate. Make sure the app depends on all_box >= 0.6.0, "
        'that you ran a fresh `flutter pub get`, and that this is a debug '
        'or profile build (not release — AllBoxInspector is a no-op there '
        'by design).';
  }

  if (error is EvalErrorException) {
    return 'The inspected app threw while evaluating an all_box_devtool '
        'expression (`${error.expression}`). Open the browser console for '
        'the full error, or evaluate the same expression manually in '
        "DevTools' Debugger > Console to see it directly.";
  }

  // Covers `EvalSentinelException` too — it extends `SentinelException`.
  if (error is SentinelException) {
    return 'The VM Service returned a Sentinel instead of a value — the '
        'object being inspected is likely gone (e.g. the isolate reloaded '
        'mid-request). Try refreshing.';
  }

  if (error is UnknownEvalException) {
    return 'Got an unexpected result evaluating '
        '`${error.expression}` against the inspected app. Open the '
        'browser console for details.';
  }

  if (error is FormatException) {
    return "The inspected app's response could not be parsed as JSON. "
        'This usually means an all_box_devtool / all_box version '
        'mismatch — make sure both are on their latest compatible '
        'versions.';
  }

  if (error is RPCError) {
    return 'The VM Service rejected the request '
        '(${error.code}: ${error.message}). Try reconnecting to the '
        'inspected app from the DevTools home screen.';
  }

  if (error is Sentinel) {
    return 'The VM Service returned a Sentinel (${error.kind}) instead of '
        'a value — the isolate likely reloaded mid-request. Try '
        'refreshing.';
  }

  return 'Unexpected error (${error.runtimeType}). Full details were '
      'logged to the browser console (F12 → Console, search for '
      '"all_box_devtool") — please include that when filing an issue via '
      '"Report an issue" above.';
}
