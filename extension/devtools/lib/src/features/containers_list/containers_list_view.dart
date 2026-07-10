import 'package:all_observer/all_observer.dart';
import 'package:flutter/material.dart';

import '../../data/containers_repository.dart';
import '../../domain/container_snapshot.dart';
import '../../shared/error_reporting.dart';
import '../../shared/utils/bytes_format.dart';
import '../../shared/widgets/badge.dart';
import '../../shared/widgets/search_field.dart';
import 'containers_list_controller.dart';

/// Left panel: every container in the inspected app, filterable by name.
class ContainersListView extends StatefulWidget {
  const ContainersListView({
    super.key,
    required this.repository,
    required this.selectedContainer,
    required this.onSelect,
    required this.onRefresh,
  });

  final ContainersRepository repository;
  final String? selectedContainer;
  final ValueChanged<String> onSelect;
  final Future<void> Function() onRefresh;

  @override
  State<ContainersListView> createState() => _ContainersListViewState();
}

class _ContainersListViewState extends State<ContainersListView> {
  final _controller = ContainersListController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: SearchField(
                  hintText: 'Filter containers',
                  onChanged: _controller.setQuery,
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
                onPressed: () => widget.onRefresh(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Observer(() {
            final repository = widget.repository;
            final containers = _filteredContainers(repository);

            if (repository.lastError != null && repository.containers.isEmpty) {
              return _ErrorState(error: repository.lastError!);
            }

            if (containers.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    repository.isLoading
                        ? 'Loading containers...'
                        : 'No containers found.\nMake sure the inspected '
                            'app has called AllBox.init()/.memory() at '
                            'least once, and is running in debug/profile '
                            'mode.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: containers.length,
              itemBuilder: (context, index) {
                final snapshot = containers[index];
                return _ContainerListTile(
                  snapshot: snapshot,
                  selected: snapshot.container == widget.selectedContainer,
                  onTap: () => widget.onSelect(snapshot.container),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  List<ContainerSnapshot> _filteredContainers(ContainersRepository repository) {
    final query = _controller.query.value.toLowerCase();
    if (query.isEmpty) return repository.containers;
    return repository.containers
        .where((c) => c.container.toLowerCase().contains(query))
        .toList(growable: false);
  }
}

class _ContainerListTile extends StatelessWidget {
  const _ContainerListTile({
    required this.snapshot,
    required this.selected,
    required this.onTap,
  });

  final ContainerSnapshot snapshot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      selected: selected,
      title: Text(snapshot.container),
      subtitle: Text(
        '${snapshot.length} keys - ${formatBytes(snapshot.approximateSizeBytes)}',
      ),
      trailing: Wrap(
        spacing: 4,
        children: [
          if (snapshot.pendingFlush)
            const AllBoxBadge(label: 'pending', color: Colors.orange),
          AllBoxBadge(label: snapshot.backend.label, color: Colors.blueGrey),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Could not load containers',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: colorScheme.error),
            ),
            const SizedBox(height: 8),
            Text(
              friendlyErrorMessage(error),
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.error),
            ),
            const SizedBox(height: 8),
            SelectableText(
              // Technical detail for bug reports — full text is in the
              // browser console (see error_reporting.dart), this is just
              // enough to identify *which* console line to look for.
              error.runtimeType.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
