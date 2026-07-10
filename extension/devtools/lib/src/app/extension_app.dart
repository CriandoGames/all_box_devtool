import 'package:all_observer/all_observer.dart';
import 'package:flutter/material.dart';

import '../connection/connection_state.dart';
import '../connection/vm_service_bridge.dart';
import '../data/containers_repository.dart';
import '../data/polling_controller.dart';
import '../features/container_detail/container_detail_view.dart';
import '../features/containers_list/containers_list_view.dart';

/// Root layout of the extension: a two-pane view with containers on the
/// left and the selected container detail on the right.
///
/// This widget owns the top-level state. Container data lives in
/// [ContainersRepository], polling lives in [PollingController], and the
/// selected container is local UI state.
class AllBoxExtensionApp extends StatefulWidget {
  const AllBoxExtensionApp({super.key});

  @override
  State<AllBoxExtensionApp> createState() => _AllBoxExtensionAppState();
}

class _AllBoxExtensionAppState extends State<AllBoxExtensionApp> {
  late final ContainersRepository _repository;
  late final PollingController _polling;
  final _selectedContainer = Observable<String?>(null);

  @override
  void initState() {
    super.initState();
    _repository = ContainersRepository(
      bridge: AllBoxVmServiceBridge(),
      isConnected: () => AllBoxConnectionStatus.isConnected,
    );
    _polling = PollingController(repository: _repository)..start();
  }

  @override
  void dispose() {
    _polling.dispose();
    _repository.dispose();
    _selectedContainer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 300,
            child: Observer(
              () => ContainersListView(
                repository: _repository,
                selectedContainer: _selectedContainer.value,
                onSelect: (name) => _selectedContainer.value = name,
                onRefresh: _polling.refreshNow,
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Observer(
              () => ContainerDetailView(
                repository: _repository,
                containerName: _selectedContainer.value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
