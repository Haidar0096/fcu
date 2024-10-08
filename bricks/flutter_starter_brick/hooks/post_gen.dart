import 'dart:io';

import 'package:mason/mason.dart';
import 'package:xml/xml.dart';

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
        ['pub', 'add', '--dev', 'very_good_analysis: ^6.0.0'],
      ),
    );
  } else {
    await _executeCommand(
      'Adding flutter_lints',
      () => Process.run(
        'dart',
        ['pub', 'add', '--dev', 'flutter_lints: ^5.0.0'],
      ),
    );
  }

  await _executeCommand(
    'Adding injectable',
    () => Process.run('dart', ['pub', 'add', 'injectable: ^2.5.0']),
  );
  await _executeCommand(
    'Adding get_it',
    () => Process.run('dart', ['pub', 'add', 'get_it: ^8.0.0']),
  );
  await _executeCommand(
    'Adding injectable_generator',
    () => Process.run(
      'dart',
      ['pub', 'add', '--dev', 'injectable_generator: ^2.6.2'],
    ),
  );

  await _executeCommand(
    'Adding hydrated_bloc',
    () => Process.run('dart', ['pub', 'add', 'hydrated_bloc: ^9.1.5']),
  );

  await _executeCommand(
    'Adding path_provider',
    () => Process.run('dart', ['pub', 'add', 'path_provider: ^2.1.4']),
  );

  await _executeCommand(
    'Adding flutter_localizations',
    () => Process.run(
      'flutter',
      ['pub', 'add', 'flutter_localizations', '--sdk=flutter'],
    ),
  );

  await _executeCommand(
    'Adding intl',
    () => Process.run('flutter', ['pub', 'add', 'intl:any']),
  );

  await _executeCommand(
    'Adding nested',
    () => Process.run('dart', ['pub', 'add', 'nested: ^1.0.0']),
  );

  await _executeCommand(
    'Adding flutter_bloc',
    () => Process.run('flutter', ['pub', 'add', 'flutter_bloc: ^8.1.6']),
  );

  await _executeCommand(
    'Adding bloc',
    () => Process.run('dart', ['pub', 'add', 'bloc: ^8.1.4']),
  );

  if (context.vars['has_ic']) {
    await _executeCommand(
      'Adding internet_connection_checker_plus',
      () => Process.run(
        'flutter',
        ['pub', 'add', 'internet_connection_checker_plus: ^2.5.2'],
      ),
    );
    await _executeCommand(
      'Adding connectivity_plus',
      () => Process.run(
        'flutter',
        ['pub', 'add', 'connectivity_plus: ^6.0.5'],
      ),
    );
  }

  await _executeCommand(
    'Adding build_runner',
    () => Process.run(
      'dart',
      ['pub', 'add', '--dev', 'build_runner: ^2.4.13'],
    ),
  );

  if (context.vars['has_ic']) {
    await _executeCommand(
      'Adding internet permission to android manifest',
      () async {
        final file = File('android/app/src/main/AndroidManifest.xml');
        final document = XmlDocument.parse(await file.readAsString());
        final manifestElement = document.findElements('manifest').first;
        final internetPermission = XmlElement(
          XmlName('uses-permission'),
          [
            XmlAttribute(
              XmlName('android:name'),
              'android.permission.INTERNET',
            )
          ],
        );
        manifestElement.children.insert(0, internetPermission);
        await file.writeAsString(document.toXmlString(pretty: true));
      },
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

  await _executeCommand(
    'Running build_runner',
    () => Process.run(
      'dart',
      ['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    ),
  );

  await _executeCommand(
    'Running flutter gen-l10n',
    () => Process.run('flutter', ['gen-l10n']),
  );

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
