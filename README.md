# all_box_devtool

A DevTools extension for [`all_box`](https://pub.dev/packages/all_box): browse
and edit `AllBox` containers from Flutter/Dart DevTools.

Requires the inspected app to depend on `all_box: ^0.5.0`, which provides the
debug-only introspection API used by this extension.

## Features

- **Containers list**: every `AllBox` container currently alive in the inspected
  app, filterable by name, with backend and pending-flush badges.
- **Container detail**: a selected container's keys and values, filterable by
  key name, plus storage summary.
- **Edit in place**: tap a key to view, edit as raw JSON, or delete it. Writes
  go to the running app through the VM Service.
- **Polling refresh**: the panel polls every 2 seconds and also supports manual
  refresh. `all_box` 0.5.0 does not emit mutation events.

Introspection is a no-op in release builds, so the extension is intended for
debug/profile sessions.

## Getting Started

1. Make sure your app depends on `all_box: ^0.5.0`.
2. Add this package as a `dev_dependency`:

   ```yaml
   dev_dependencies:
     all_box_devtool: ^0.2.0
   ```

3. Run `flutter pub get`.
4. Run your app, open DevTools, and enable the extension when prompted.

## Additional Information

- Architecture and design notes: [ARCHITECTURE.md](./ARCHITECTURE.md).
- `all_box`: <https://github.com/CriandoGames/all_box>.
- Issues: <https://github.com/CriandoGames/all_box_devtool/issues>.
