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

  // Delete the lib directory `flutter create` wrote so it cannot conflict
  // with the generated code. Mason runs this hook inside the output
  // directory; a fresh output directory has no lib/ yet, so the delete is
  // skipped rather than failing the generation.
  await _executeCommand(
    'Deleting lib directory',
    () async {
      final lib = Directory('lib');
      if (lib.existsSync()) lib.deleteSync(recursive: true);
    },
  );
}
