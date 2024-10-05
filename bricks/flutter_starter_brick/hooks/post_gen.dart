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

  if (context.vars['has_vga']) {
    await _executeCommand(
      () => Process.run(
        'dart',
        ['pub', 'add', '--dev', 'very_good_analysis'],
      ),
      'Adding very_good_analysis',
    );
  } else {
    await _executeCommand(
      () => Process.run(
        'dart',
        ['pub', 'add', '--dev', 'flutter_lints'],
      ),
      'Adding flutter_lints',
    );
  }

  if (context.vars['has_di']) {
    await _executeCommand(
      () => Process.run('dart', ['pub', 'add', 'injectable']),
      'Adding injectable',
    );
    await _executeCommand(
      () => Process.run('dart', ['pub', 'add', 'get_it']),
      'Adding get_it',
    );
    await _executeCommand(
      () => Process.run(
        'dart',
        ['pub', 'add', '--dev', 'injectable_generator'],
      ),
      'Adding injectable_generator',
    );
  }

  await _executeCommand(
    () => Process.run('flutter', ['clean']),
    'Running flutter clean',
  );

  await _executeCommand(
    () => Process.run('flutter', ['pub', 'get']),
    'Running flutter pub get',
  );

  final usesBuildRunner = context.vars['has_di'];
  if (usesBuildRunner) {
    await _executeCommand(
      () => Process.run('dart', ['pub', 'add', '--dev', 'build_runner']),
      'Adding build_runner',
    );
    await _executeCommand(
      () => Process.run(
        'dart',
        ['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'],
      ),
      'Running build_runner',
    );
  }

  await _executeCommand(
    () => Process.run('dart', ['format', '.']),
    'Running dart format .',
  );

  await _executeCommand(
    () => Process.run('dart', ['fix', '--apply']),
    'Running dart fix --apply',
  );

  context.logger.success('🎉 Brick generated successfully!');
  context.logger.warn(
    'Do not forget to search the codebase for the TODOs'
    ' and change them according to the project needs.',
  );
}
