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
    'Adding dev dependencies',
    () => Process.run(
      'dart',
      [
        'pub',
        'add',
        '--dev',
        'very_good_analysis: ^7.0.0',
        'injectable_generator: ^2.7.0',
        'build_runner: ^2.4.15',
        'go_router_builder: ^2.8.0',
        'build_verify: ^3.1.0',
      ],
    ),
  );

  await _executeCommand(
    'Adding dependencies',
    () => Process.run(
      'dart',
      [
        'pub',
        'add',
        'injectable: ^2.5.0',
        'get_it: ^8.0.3',
        'hydrated_bloc: ^10.0.0',
        'flutter_bloc: ^9.0.0',
        'bloc: ^9.0.0',
        'path_provider: ^2.1.5',
        'intl:any',
        'nested: ^1.0.0',
        'android_id: ^0.4.0',
        'device_info_plus: ^11.3.0',
        'package_info_plus: ^8.2.1',
        'go_router: ^14.8.0',
        'flutter_animate: ^4.5.2',
        'cached_network_image: ^3.4.1',
        'loading_animation_widget: ^1.3.0',
        'fconnectivity: ^0.5.0',
        'dio: ^5.8.0+1',
      ],
    ),
  );

  await _executeCommand(
    'Adding sdk dependencies',
    () => Process.run('flutter', [
      'pub',
      'add',
      'flutter_localizations',
      '--sdk=flutter',
    ]),
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
    'Running dart fix --apply',
    () => Process.run('dart', ['fix', '--apply']),
  );

  await _executeCommand(
    'Running dart format .',
    () => Process.run('dart', ['format', '.']),
  );

  context.logger.success('🎉 Brick generated successfully!');
  context.logger.warn(
    'Do not forget to search the codebase for the TODOs'
    ' and change them according to the project needs.',
  );
}
