import 'dart:io';

import 'package:mason/mason.dart';

late Progress _progress;

Future<void> _executeWithProgress(
  HookContext context,
  Future<void> Function() fn,
  String message,
) async {
  _progress = context.logger.progress(message);
  await fn();
  _progress.complete();
}

Future<void> run(HookContext context) async {
  if (context.vars['has_vga']) {
    await _executeWithProgress(
      context,
      () async => Process.run(
        'dart',
        ['pub', 'add', '--dev', 'very_good_analysis'],
      ),
      'Adding very_good_analysis',
    );
  } else {
    await _executeWithProgress(
      context,
      () async => Process.run(
        'dart',
        ['pub', 'add', '--dev', 'flutter_lints'],
      ),
      'Adding flutter_lints',
    );
  }

  if (context.vars['has_envs']) {
    await _executeWithProgress(
      context,
      () async => File('lib/main.dart').delete(),
      'Deleting main.dart',
    );
  }

  await _executeWithProgress(
    context,
    () async => Process.run('flutter', ['pub', 'get']),
    'Running flutter pub get',
  );

  await _executeWithProgress(
    context,
    () async => Process.run('dart', ['format', '.']),
    'Running dart format .',
  );
}
