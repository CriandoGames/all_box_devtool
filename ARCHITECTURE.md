# Architecture

## Status

`all_box_devtool` is a standalone DevTools extension package for apps that use
`all_box: ^0.6.0`.

The inspected app exposes debug-only snapshots through `AllBoxInspector`. This
extension reads and writes data through the VM Service. As of `all_box` 0.6.0
the inspected app does emit a debug-only `all_box:mutation` VM Service
extension event on every write/remove/erase, but this extension doesn't
consume it yet, so it still uses polling plus manual refresh (see "Current
Scope" below).

## Package Layout

```text
all_box_devtool/
  pubspec.yaml                 # anchor package consumed as dev_dependency
  lib/all_box_devtool.dart      # marker library; no runtime API
  extension/devtools/           # Flutter Web DevTools extension app
```

The extension app is not published independently. It is shipped as part of the
anchor package and discovered by DevTools from `extension/devtools/config.yaml`.

## Layers

- `connection/`: the only layer that talks to DevTools globals and VM Service.
- `data/`: owns refresh, mutation orchestration, and observable app state.
- `domain/`: pure data models decoded from snapshot JSON.
- `features/`: UI feature folders that consume `data/` and `domain/`.
- `shared/`: reusable widgets and formatting helpers used by multiple features.

Feature widgets must not call `serviceManager`, `EvalOnDartLibrary`, or VM
Service APIs directly. They go through `ContainersRepository`.

## Data Flow

1. `PollingController` calls `ContainersRepository.refresh()` immediately and
   then every 2 seconds.
2. `ContainersRepository` checks the DevTools connection and calls
   `AllBoxVmServiceBridge.fetchSnapshot()`.
3. `AllBoxVmServiceBridge` evaluates `AllBoxInspector.snapshotAsJson()` in the
   inspected app's main isolate.
4. JSON maps are converted to `ContainerSnapshot` domain objects.
5. UI reads repository observables through `Observer`.

Manual refresh calls the same repository method. Edit/delete operations go
through `ContainersRepository.writeValue()` and `removeKey()`, then force a new
snapshot read so the UI sees the mutation result.

## Reactivity

The extension app uses `all_observer` internally:

- `ContainersRepository` stores containers, loading state, and last error as
  observables.
- List/detail filter controllers store their query as observables.
- UI rebuilds with `Observer`.
- Domain models and VM Service bridge classes stay non-reactive.

This keeps reactivity near UI/application state without mixing it into DTOs or
VM Service boundary code.

## Refresh Concurrency

Polling, manual refresh, and post-write refresh can overlap. The repository
coalesces concurrent refresh calls into one in-flight future. After a write or
delete, it waits for any older refresh to finish and then starts a fresh read.

## Current Scope

Implemented:

- containers list;
- container detail;
- key filtering;
- storage summary;
- edit/delete as raw JSON;
- polling plus manual refresh;
- `all_observer` based UI state.

Not implemented:

- push updates from VM Service events — `all_box` 0.6.0 already posts an
  `all_box:mutation` extension event on write/remove/erase; this extension
  could subscribe to it instead of polling, but doesn't yet;
- mutation log;
- storage backend file path or localStorage key display;
- broad widget test coverage.
