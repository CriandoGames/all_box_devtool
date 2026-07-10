import 'package:all_observer/all_observer.dart';

/// UI-local state for the container detail panel.
class ContainerDetailController {
  final query = ''.obs;

  void setQuery(String value) {
    if (value == query.value) return;
    query.value = value;
  }

  void dispose() {
    query.close();
  }
}
