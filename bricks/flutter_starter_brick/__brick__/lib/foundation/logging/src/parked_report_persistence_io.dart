import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Native persistence for parked reports.
final class ParkedReportPersistence {
  ParkedReportPersistence._(this._file);

  static const String _fileName = 'parked_reports.jsonl';
  static const MethodChannel _backupExclusionChannel = MethodChannel(
    'foundation.logging/backup_exclusion',
  );

  final File _file;

  /// Creates persistence at the fixed application-support file home.
  static Future<ParkedReportPersistence> create() async {
    final directory = await getApplicationSupportDirectory();
    final persistence = ParkedReportPersistence._(
      File(path.join(directory.path, _fileName)),
    );
    if (await persistence._file.exists()) {
      await persistence._excludeFromIosBackup();
    }
    return persistence;
  }

  /// Reads one encoded JSON object per line, oldest first.
  Future<List<String>> readValues() async {
    if (!await _file.exists()) return const <String>[];
    return (await _file.readAsLines())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
  }

  /// Replaces the JSONL file and flushes the new queue to disk.
  Future<void> writeValues(List<String> values) async {
    await _file.create(recursive: true);
    await _excludeFromIosBackup();
    await _file.writeAsString('${values.join('\n')}\n', flush: true);
  }

  /// Removes the queue after the final report is acknowledged.
  Future<void> clearValues() async {
    if (await _file.exists()) await _file.delete();
  }

  Future<void> _excludeFromIosBackup() async {
    if (!Platform.isIOS) return;
    await _backupExclusionChannel.invokeMethod<void>(
      'excludeFileFromBackup',
      <String, String>{'path': _file.path},
    );
  }
}
