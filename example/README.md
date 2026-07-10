# all_box_devtool example

This app is a local target for testing the DevTools extension against real
`AllBox` containers.

It initializes two containers:

- `settings`
- `session`

The buttons mutate those containers so the extension can exercise polling,
manual refresh, editing, deletion, JSON value rendering, pending flush state,
and backend detection.

## Prepare the Extension

From the repository root:

```powershell
.\tool\prepare_devtools_extension.ps1
```

This builds the extension web app into `extension/devtools/build` and validates
the DevTools extension metadata.

## Run on Web

```powershell
cd example
flutter run -d chrome
```

On Web, this example uses `AllBox.memory()`. This is useful for quickly testing
that DevTools can discover the extension, call `AllBoxInspector`, list
containers, edit values, delete keys, and refresh.

## Run on Android

```powershell
cd example
flutter devices
flutter run -d <android-device-id>
```

On Android, this example uses `AllBox.init(..., path: documentsDirectory)`,
backed by real file storage through `path_provider`. This is the better test
for backend-specific fields such as storage backend, pending flush state, and
approximate size.

After the app starts, open DevTools from your IDE or from the Flutter run
output, then select the `all_box_devtool` tab. The example includes a
`devtools_options.yaml` file that enables the extension automatically.
