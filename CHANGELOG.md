## 1.0.1

- Remove the published `all_box: ^0.6.0` dependency constraint from the
  DevTools anchor package, so apps can use `all_box` 0.6.x, 0.7.x, and the
  1.0.0 beta channel without dependency solver conflicts.
- Display the optional `backendDetail` field from newer `all_box` inspector
  snapshots, including Web localStorage/IndexedDB backend details.

## 1.0.0

- Initial DevTools extension package (template scaffold only).
