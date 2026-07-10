import 'package:all_observer/all_observer.dart';
import 'package:flutter/material.dart';

import '../../data/containers_repository.dart';
import '../../domain/entry.dart';
import '../../shared/widgets/data_table_view.dart';
import '../../shared/widgets/search_field.dart';
import '../key_editor/key_editor_dialog.dart';
import '../storage_info/storage_info_panel.dart';
import 'container_detail_controller.dart';

/// Right panel: the selected container's keys and values.
class ContainerDetailView extends StatefulWidget {
  const ContainerDetailView({
    super.key,
    required this.repository,
    required this.containerName,
  });

  final ContainersRepository repository;
  final String? containerName;

  @override
  State<ContainerDetailView> createState() => _ContainerDetailViewState();
}

class _ContainerDetailViewState extends State<ContainerDetailView> {
  final _controller = ContainerDetailController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openEditor(String containerName, ContainerEntry entry) {
    return KeyEditorDialog.show(
      context,
      repository: widget.repository,
      container: containerName,
      entryKey: entry.key,
      initialValue: entry.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final containerName = widget.containerName;
    if (containerName == null) {
      return const Center(child: Text('Select a container on the left.'));
    }

    return Observer(() {
      final snapshot = widget.repository.byName(containerName);
      if (snapshot == null) {
        return Center(
          child: Text(
            widget.repository.isLoading
                ? 'Loading...'
                : '"$containerName" was not found in the last refresh.',
          ),
        );
      }

      final filtered = snapshot.filteredByKey(_controller.query.value);
      final entries = filtered.entries.entries
          .map(ContainerEntry.fromMapEntry)
          .toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Text(
              containerName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: StorageInfoPanel(snapshot: snapshot),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SearchField(
              hintText: 'Filter keys',
              onChanged: _controller.setQuery,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          Expanded(
            child: entries.isEmpty
                ? const Center(child: Text('No keys match this filter.'))
                : DataTableView(
                    entries: entries,
                    onTapEntry: (entry) => _openEditor(containerName, entry),
                  ),
          ),
        ],
      );
    });
  }
}
