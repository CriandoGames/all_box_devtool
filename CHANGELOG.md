## Unreleased

Bug fixes found while validating the extension against a freshly published
`all_box: 0.6.0`, plus better diagnostics so the next bug (ours or the
user's) is easier to track down.

- **Fix:** `AllBoxVmServiceBridge` evaluated expressions against
  `package:all_box/all_box.dart`, which is a barrel file (`export`-only, no
  local declarations). The VM Service's `evaluate` only resolves names
  declared directly in the target library, not names it re-exports, so
  every eval of `AllBoxInspector.snapshotAsJson()` silently returned `null`
  — surfaced as "Could not load containers: ... returned null. Is the
  inspected app using all_box >= 0.5.0?" even though it was. Now targets
  `package:all_box/src/core/all_box_impl.dart`, where `AllBox` and
  `AllBoxInspector` are actually declared.
- **Fix:** `_evalToString` called `eval.safeGetInstance(instanceRef, null)`.
  `EvalOnDartLibrary`'s `_verifySaneValue` treats a `null` `isAlive` as
  "already cancelled" unconditionally (`isAlive?.disposed ?? true`), so
  *every* otherwise-successful eval threw `CancelledException` right after
  fetching its value — surfaced as "Could not load containers: Instance of
  'CancelledException'" (or an unreadable minified class name in `release`
  builds). Now passes `eval` itself (a `Disposable`) as `isAlive`.
- **New:** `shared/error_reporting.dart` — `logCaughtError()` logs every
  caught exception to the browser console with a greppable
  `[all_box_devtool]` prefix, the real `runtimeType`, and the stack trace
  (previously several call sites just stored the raw error object with no
  logging at all, so debugging relied entirely on `Object.toString()`,
  which is `Instance of 'SomeType'` for any exception without a custom
  `toString()` — and minified on top of that in `--release` builds).
  `friendlyErrorMessage()` maps known exception types (ours and
  `devtools_app_shared`'s) to an actionable message; the containers list
  and key editor now show that instead of a raw `$error` interpolation.

## 1.0.0

First real release — nothing prior to this was ever published, so this
ships directly as `1.0.0` instead of pretending a `0.x` history existed.
See [ARCHITECTURE.md](./ARCHITECTURE.md) for the full design rationale.

- **Containers list**: every `AllBox` container alive in the inspected
  app, filterable by name, with backend/pending-flush badges.
- **Container detail**: keys/values for the selected container,
  filterable by key, plus a storage summary (backend, key count,
  approximate size).
- **Edit in place**: view, edit (as raw JSON) or delete any key directly
  from the panel.
- **Polling + manual refresh**: the panel refreshes automatically every
  2 seconds, plus a manual refresh button — `all_box` 0.5.0 has no
  mutation events, so this is pull-based by design (see
  ARCHITECTURE.md, "Reactivity"/"Data Flow").
- Requires `all_box: ^0.6.0` in the inspected app.

## 0.1.0

- Initial DevTools extension package (template scaffold only).
