import 'dart:io';

import 'package:flutter_cli_utils/src/version.dart';
import 'package:test/test.dart';

void main() {
  test('packageVersion matches the version in pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final versionMatch = RegExp(
      r'^version:\s*(\S+)\s*$',
      multiLine: true,
    ).firstMatch(pubspec);

    expect(versionMatch, isNotNull, reason: 'pubspec.yaml has no version');
    expect(
      packageVersion,
      versionMatch!.group(1),
      reason:
          'lib/src/version.dart is stale. Regenerate it with '
          '`dart run build_runner build --delete-conflicting-outputs`.',
    );
  });
}
