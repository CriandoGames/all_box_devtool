// `all_box_devtool` (the anchor package) has no runtime API of its own —
// see lib/all_box_devtool.dart. This test only guards against the import
// silently breaking (e.g. a typo'd `library;` or export).

import 'package:flutter_test/flutter_test.dart';

// ignore: unused_import
import 'package:all_box_devtool/all_box_devtool.dart';

void main() {
  test('package:all_box_devtool/all_box_devtool.dart imports cleanly', () {
    // Intentionally no assertions beyond "the import above compiled and
    // ran": this package is a marker/anchor for DevTools extension
    // discovery (see ARCHITECTURE.md, ADR-0001), not a library with
    // behavior to test.
    expect(true, isTrue);
  });
}
