import 'dart:io';

import 'package:mason/mason.dart';
import 'package:xml/xml.dart';

Future<void> run(HookContext context) async {
  Progress progress;

  Future<void> _executeCommand(
    String message,
    Future<ProcessResult> Function() fn,
  ) async {
    progress = context.logger.progress(message);
    final result = await fn();
    if (result.exitCode != 0) {
      progress.fail('Failed: ${result.stderr}');
      context.logger.err('Command failed with exit code ${result.exitCode}');
      context.logger.err('stdout: ${result.stdout}');
      context.logger.err('stderr: ${result.stderr}');
    } else {
      progress.complete();
    }
  }

  await _executeCommand(
    'Adding dev dependencies',
    () => Process.run(
      'dart',
      [
        'pub',
        'add',
        '--dev',
        'very_good_analysis:^10.0.0',
        'build_runner:^2.10.5',
        'go_router_builder:^4.1.3',
        'build_verify:^3.1.1',
        'json_serializable:^6.11.4',
        'flutter_launcher_icons:^0.14.4'
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
        'get_it:^9.2.0',
        'hydrated_bloc:^10.1.1',
        'flutter_bloc:^9.1.1',
        'bloc:^9.2.0',
        'path_provider:^2.1.5',
        'path:^1.9.1',
        'collection:^1.19.1',
        'android_id:^0.5.1',
        'device_info_plus:^12.3.0',
        'package_info_plus:^9.0.0',
        'go_router:^17.0.1',
        'flutter_animate:^4.5.2',
        'rxdart:^0.28.0',
        'dio:^5.9.0',
        'json_annotation:^4.9.0'
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
      try {
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
        return ProcessResult(0, 0, 'Success', '');
      } catch (e) {
        return ProcessResult(0, 1, '', e.toString());
      }
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
