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
