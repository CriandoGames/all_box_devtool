import 'dart:async';

import 'containers_repository.dart';

/// Decides *when* [ContainersRepository.refresh] runs: a periodic timer
/// plus manual refreshes (e.g. a refresh button), coalesced so a manual
/// refresh doesn't race a timer tick that's already in flight.
///
/// Kept separate from [ContainersRepository] on purpose — the repository
/// only knows how to fetch once; this controller is the only place that
/// knows about timing/scheduling (see ARCHITECTURE.md, "Princípios de
/// separação": `data/` is the only place that decides *when* to fetch).
///
/// **PT-BR:** Decide *quando* [ContainersRepository.refresh] roda: um timer
/// periódico mais atualizações manuais (ex.: um botão de refresh),
/// coalescidas para que uma atualização manual não entre em corrida com um
/// tick do timer já em andamento.
///
/// Mantido separado de [ContainersRepository] de propósito — o repositório
/// só sabe buscar uma vez; este controller é o único lugar que sabe sobre
/// timing/agendamento (veja ARCHITECTURE.md, "Princípios de separação":
/// `data/` é o único lugar que decide *quando* buscar).
class PollingController {
  PollingController({
    required this.repository,
    this.interval = const Duration(seconds: 2),
  });

  final ContainersRepository repository;

  /// How often to poll while [start]ed. 2s by default: frequent enough to
  /// feel live for typical interactive debugging, cheap enough not to
  /// spam the VM Service with `eval` calls.
  ///
  /// **PT-BR:** Com que frequência fazer polling enquanto [start]ado. 2s
  /// por padrão: frequente o suficiente para parecer ao vivo em depuração
  /// interativa típica, barato o suficiente para não sobrecarregar o VM
  /// Service com chamadas `eval`.
  final Duration interval;

  Timer? _timer;

  bool get isPolling => _timer != null;

  /// Starts periodic polling. Triggers one immediate [refreshNow] so the
  /// UI doesn't sit empty for a full [interval] after opening the panel.
  void start() {
    if (_timer != null) return;
    unawaited(refreshNow());
    _timer = Timer.periodic(interval, (_) => unawaited(refreshNow()));
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Manual refresh (e.g. a "Refresh" button). Delegates straight to the
  /// repository, which already de-dupes concurrent calls.
  Future<void> refreshNow() => repository.refresh();

  /// Stops polling. Call from the owning widget's `dispose()`.
  void dispose() => stop();
}
