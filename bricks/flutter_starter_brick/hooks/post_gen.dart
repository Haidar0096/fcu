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

  await _executeCommand(
    'Adding non-conditional dev dependencies',
    () => Process.run(
      'dart',
      [
        'pub',
        'add',
        '--dev',
        'very_good_analysis: ^6.0.0',
        'injectable_generator: ^2.6.2',
        'build_runner: ^2.4.13',
      ],
    ),
  );

  await _executeCommand(
    'Adding non-conditional standard dependencies',
    () => Process.run(
      'dart',
      [
        'pub',
        'add',
        'injectable: ^2.5.0',
        'get_it: ^8.0.0',
        'hydrated_bloc: ^9.1.5',
        'flutter_bloc: ^8.1.6',
        'bloc: ^8.1.4',
        'path_provider: ^2.1.4',
        'intl:any',
        'nested: ^1.0.0',
        'android_id: ^0.4.0',
        'device_info_plus: ^11.0.0',
        'package_info_plus: ^8.0.3',
        'go_router: ^14.3.0',
        'flutter_animate: ^4.5.0',
        'cached_network_image: ^3.4.1',
        'loading_animation_widget: ^1.3.0',
        'flutter_hooks: ^0.20.5',
        'carousel_slider: ^5.0.0'
      ],
    ),
  );

  await _executeCommand(
    'Adding other non-conditional dependencies',
    () => Process.run('flutter', [
      'pub',
      'add',
      'flutter_localizations',
      '--sdk=flutter',
    ]),
  );

  if (context.vars['has_ic']) {
    await _executeCommand(
      'Adding internet dependencies',
      () => Process.run(
        'dart',
        [
          'pub',
          'add',
          'fconnectivity: ^0.1.1',
          'dio: ^5.7.0',
          'dio_smart_retry: ^6.0.0',
          'pretty_dio_logger: ^1.4.0',
        ],
      ),
    );
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
            ),
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
