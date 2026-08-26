import 'dart:io';

import 'package:mason/mason.dart';
import 'package:xml/xml.dart';

/// The entitlement macOS demands before a sandboxed app may open an OUTGOING
/// connection. The starter's error logger posts every report to the project's
/// own receiver endpoint, so without this key the macOS sandbox denies that
/// request — and the sender is silent by design, so the loss is invisible.
const String _macOsNetworkClientEntitlement =
    'com.apple.security.network.client';

/// The two entitlement files `flutter create` writes for a macOS target. Both
/// need the key: the debug/profile one for local runs, the release one for the
/// shipped build.
const List<String> _macOsEntitlementsFiles = [
  'macos/Runner/DebugProfile.entitlements',
  'macos/Runner/Release.entitlements',
];

/// Adds [_macOsNetworkClientEntitlement] to one entitlements plist unless it
/// is already there, so a re-run cannot write the key twice.
///
/// Returns whether the file was rewritten.
bool _addMacOsNetworkClientEntitlement(File file) {
  final document = XmlDocument.parse(file.readAsStringSync());
  final dict = document.findAllElements('dict').first;
  final alreadyDeclared = dict.findElements('key').any(
        (XmlElement key) => key.innerText == _macOsNetworkClientEntitlement,
      );
  if (alreadyDeclared) return false;
  dict.children.add(
    XmlElement(XmlName('key'), [], [
      XmlText(_macOsNetworkClientEntitlement),
    ]),
  );
  dict.children.add(XmlElement(XmlName('true'), [], [], true));
  file.writeAsStringSync(
    '${document.toXmlString(pretty: true, indent: '\t')}\n',
  );
  return true;
}

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
      throw Exception('Command failed: $message\n${result.stderr}');
    } else {
      progress.complete();
    }
  }

  await _executeCommand(
    'Making shell scripts executable',
    () => Process.run('chmod', [
      '+x',
      'scripts/create_android_builds/create_android_builds.sh',
      'scripts/upload_to_test_flight/upload_to_testflight.sh',
      'scripts/upload_to_play_store/upload_to_playstore.sh',
      'scripts/build_web/build_web.sh',
    ]),
  );

  await _executeCommand(
    'Adding dev dependencies',
    () => Process.run(
      'dart',
      [
        'pub',
        'add',
        '--dev',
        'very_good_analysis:^10.1.0',
        'build_runner:^2.11.1',
        'go_router_builder:^4.2.0',
        'json_serializable:^6.12.0',
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
        'android_id:^0.5.1',
        'device_info_plus:^12.3.0',
        'package_info_plus:^9.0.0',
        'go_router:^17.1.0',
        'flutter_animate:^4.5.2',
        'rxdart:^0.28.0',
        // 5.10.0 is the floor: `DioExceptionType.transformTimeout`, which the
        // networking client switches on, does not exist before it.
        'dio:^5.10.0',
        'json_annotation:^4.10.0',
        'shared_preferences:^2.5.4',
        'uuid:^4.5.2'
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
        // A project generated without an Android target owns no manifest, so
        // this step does nothing rather than failing the generation — the
        // same guard the macOS entitlements step below carries.
        if (!file.existsSync()) return ProcessResult(0, 0, 'Success', '');
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
    'Adding network client entitlement to macos entitlements',
    () async {
      try {
        for (final path in _macOsEntitlementsFiles) {
          final file = File(path);
          // A project generated without a macOS target owns neither file, so
          // this step does nothing rather than failing the generation.
          if (!file.existsSync()) continue;
          _addMacOsNetworkClientEntitlement(file);
        }
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
    'Running flutter gen-l10n',
    () => Process.run('flutter', ['gen-l10n']),
  );

  await _executeCommand(
    'Running build_runner',
    () => Process.run(
      'dart',
      ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    ),
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
