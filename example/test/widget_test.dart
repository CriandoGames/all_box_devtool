import 'package:all_box/all_box.dart';
import 'package:all_box_devtool_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('example app renders all_box containers', (tester) async {
    await AllBox.memory(
      'settings',
      initialData: {'theme': 'dark', 'launchCount': 1},
    );
    await AllBox.memory(
      'session',
      initialData: {'token': 'test-token'},
    );

    await tester.pumpWidget(const ExampleApp());

    expect(find.text('settings'), findsOneWidget);
    expect(find.text('session'), findsOneWidget);
    expect(find.textContaining('launchCount'), findsWidgets);
    expect(find.textContaining('test-token'), findsOneWidget);
  });
}
