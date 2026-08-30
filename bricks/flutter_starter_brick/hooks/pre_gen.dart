import 'dart:io';

import 'package:mason/mason.dart';

const String _freshOutputSentinelName = 'fcu_fresh_flutter_output.sentinel';
const String _freshOutputSentinelVersion = 'fcu-fresh-flutter-output-v1';

Future<void> run(HookContext context) async {
  Progress progress;

  Future<void> _executeCommand(
    String message,
    Future<void> Function() fn,
  ) async {
    progress = context.logger.progress(message);
    await fn();
    progress.complete();
  }

  // Delete only the `lib` directory from the `flutter create` run that the
  // fcu command completed immediately before this brick. Direct Mason use
  // has no one-time token and stops before touching the directory.
  await _executeCommand(
    'Deleting lib directory',
    () async {
      final outputRoot = Directory.current.resolveSymbolicLinksSync();
      final sentinel = File(
        '$outputRoot${Platform.pathSeparator}$_freshOutputSentinelName',
      );
      final token = context.vars['fresh_output_token'] as String? ?? '';
      final expectedSentinel =
          '$_freshOutputSentinelVersion\n$token\n$outputRoot\n';
      final hasFreshFlutterOutput = token.isNotEmpty &&
          sentinel.existsSync() &&
          sentinel.readAsStringSync() == expectedSentinel &&
          File('.metadata').existsSync() &&
          File('pubspec.yaml').existsSync() &&
          File('lib/main.dart').existsSync();
      if (!hasFreshFlutterOutput) {
        throw StateError(
          'The starter brick can replace lib/ only in fresh output handed '
          'off by `fcu create`. No files were changed.',
        );
      }

      sentinel.deleteSync();
      final lib = Directory('lib');
      if (lib.existsSync()) lib.deleteSync(recursive: true);
    },
  );
}
