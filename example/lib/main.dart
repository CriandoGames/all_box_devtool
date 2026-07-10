import 'dart:math';

import 'package:all_box/all_box.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AllBox.memory(
    'settings',
    initialData: {
      'theme': 'dark',
      'language': 'pt-BR',
      'launchCount': 1,
      'flags': {'beta': true, 'debugTools': true},
    },
  );

  await AllBox.memory(
    'session',
    initialData: {
      'userId': 'user_001',
      'token': 'local-dev-token',
      'roles': ['admin', 'tester'],
    },
  );

  runApp(const ExampleApp());
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final _settings = AllBox('settings');
  final _session = AllBox('session');
  final _random = Random();

  int get _launchCount => _settings.read<int>('launchCount') ?? 0;
  String get _theme => _settings.read<String>('theme') ?? 'dark';
  String get _token => _session.read<String>('token') ?? '';

  void _incrementLaunchCount() {
    _settings.write('launchCount', _launchCount + 1);
    setState(() {});
  }

  void _toggleTheme() {
    _settings.write('theme', _theme == 'dark' ? 'light' : 'dark');
    setState(() {});
  }

  void _rotateToken() {
    _session.write('token', 'token_${_random.nextInt(999999)}');
    _session.write('lastRotatedAt', DateTime.now().toIso8601String());
    setState(() {});
  }

  void _writeComplexValue() {
    _settings.write('profile', {
      'name': 'DevTools User',
      'updatedAt': DateTime.now().toIso8601String(),
      'scores': List<int>.generate(5, (_) => _random.nextInt(100)),
    });
    setState(() {});
  }

  void _removeLanguage() {
    _settings.remove('language');
    setState(() {});
  }

  void _eraseSession() {
    _session.erase();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'all_box DevTools Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('all_box DevTools Example')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatusCard(
              title: 'settings',
              values: {
                'theme': _theme,
                'launchCount': _launchCount,
                'keys': _settings.getKeys().join(', '),
              },
            ),
            const SizedBox(height: 12),
            _StatusCard(
              title: 'session',
              values: {
                'token': _token.isEmpty ? '<empty>' : _token,
                'keys': _session.getKeys().join(', '),
              },
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: _incrementLaunchCount,
                  child: const Text('Increment counter'),
                ),
                FilledButton.tonal(
                  onPressed: _toggleTheme,
                  child: const Text('Toggle theme'),
                ),
                FilledButton.tonal(
                  onPressed: _rotateToken,
                  child: const Text('Rotate token'),
                ),
                OutlinedButton(
                  onPressed: _writeComplexValue,
                  child: const Text('Write profile map'),
                ),
                OutlinedButton(
                  onPressed: _removeLanguage,
                  child: const Text('Remove language'),
                ),
                TextButton(
                  onPressed: _eraseSession,
                  child: const Text('Erase session'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Open DevTools and select the all_box_devtool tab. The extension '
              'polls every 2 seconds; use Refresh if you want to see a change '
              'immediately.',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.title, required this.values});

  final String title;
  final Map<String, Object?> values;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final entry in values.entries)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('${entry.key}: ${entry.value}'),
              ),
          ],
        ),
      ),
    );
  }
}
