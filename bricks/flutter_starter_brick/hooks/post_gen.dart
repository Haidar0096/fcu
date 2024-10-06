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

  if (context.vars['has_vga']) {
    await _executeCommand(
      'Adding very_good_analysis',
      () => Process.run(
        'dart',
        ['pub', 'add', '--dev', 'very_good_analysis'],
      ),
    );
  } else {
    await _executeCommand(
      'Adding flutter_lints',
      () => Process.run(
        'dart',
        ['pub', 'add', '--dev', 'flutter_lints'],
      ),
    );
  }

  if (context.vars['has_di']) {
    await _executeCommand(
      'Adding injectable',
      () => Process.run('dart', ['pub', 'add', 'injectable']),
    );
    await _executeCommand(
      'Adding get_it',
      () => Process.run('dart', ['pub', 'add', 'get_it']),
    );
    await _executeCommand(
      'Adding injectable_generator',
      () => Process.run(
        'dart',
        ['pub', 'add', '--dev', 'injectable_generator'],
      ),
    );
  }

  await _executeCommand(
    'Running flutter clean',
    () => Process.run('flutter', ['clean']),
  );

  await _executeCommand(
    'Running flutter pub get',
    () => Process.run('flutter', ['pub', 'get']),
  );

  final usesBuildRunner = context.vars['has_di'];
  if (usesBuildRunner) {
    await _executeCommand(
      'Adding build_runner',
      () => Process.run('dart', ['pub', 'add', '--dev', 'build_runner']),
    );
    await _executeCommand(
      'Running build_runner',
      () => Process.run(
        'dart',
        ['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'],
      ),
    );
  }

  await _executeCommand(
    'Running dart format .',
    () => Process.run('dart', ['format', '.']),
  );

  await _executeCommand(
    'Running dart fix --apply',
    () => Process.run('dart', ['fix', '--apply']),
  );

  context.logger.success('🎉 Brick generated successfully!');
  context.logger.warn(
    'Do not forget to search the codebase for the TODOs'
    ' and change them according to the project needs.',
  );
}
