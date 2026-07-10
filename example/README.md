# all_box_devtool example

This app is a local target for testing the DevTools extension.

Run it in debug/profile mode, open DevTools, and select the `all_box_devtool`
tab. The app initializes two in-memory containers:

- `settings`
- `session`

The buttons mutate those containers so the extension can exercise polling,
manual refresh, editing, deletion, and JSON value rendering.

## Run

```powershell
cd example
flutter pub get
flutter run -d chrome
```

The extension build must exist at `extension/devtools/build` before opening
DevTools. From the repository root, run:

```powershell
.\tool\prepare_devtools_extension.ps1
```
