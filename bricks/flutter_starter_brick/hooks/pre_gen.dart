import 'dart:io';

import 'package:mason/mason.dart';

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

  // Delete the lib directory to avoid conflicts with the generated code
  await _executeCommand(
    'Deleting lib directory',
    () async => Directory('lib').deleteSync(recursive: true),
  );
}
