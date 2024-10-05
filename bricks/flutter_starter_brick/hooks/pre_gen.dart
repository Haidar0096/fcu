import 'dart:io';

import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  Progress progress;

  Future<void> _executeCommand(
    Future<void> Function() fn,
    String message,
  ) async {
    progress = context.logger.progress(message);
    await fn();
    progress.complete();
  }

  await _executeCommand(
    () async => Directory('lib').deleteSync(recursive: true),
    'Deleting lib directory',
  );
}
