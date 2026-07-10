import 'package:all_box_devtool_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('example app renders all_box containers', (tester) async {
    await initializeExampleStorage(forceMemory: true);

    await tester.pumpWidget(
      const ExampleApp(
        storageInfo: ExampleStorageInfo(
          mode: 'memory',
          description: 'test storage',
        ),
      ),
    );

    expect(find.text('settings'), findsOneWidget);
    expect(find.text('session'), findsOneWidget);
    expect(find.textContaining('launchCount'), findsWidgets);
    expect(find.textContaining('local-dev-token'), findsOneWidget);
  });
}
