import 'package:shared_preferences/shared_preferences.dart';
import 'package:{{proj_name}}/foundation/logging/src/parked_report_store_keys.dart';

/// Browser persistence for parked reports.
final class ParkedReportPersistence {
  ParkedReportPersistence._(this._preferences);

  final SharedPreferences _preferences;

  /// Opens the browser's persistent preference store.
  static Future<ParkedReportPersistence> create() async =>
      ParkedReportPersistence._(await SharedPreferences.getInstance());

  /// Reads the encoded parked-report queue, oldest first.
  Future<List<String>> readValues() async =>
      _preferences.getStringList(ParkedReportStoreKeys.parkedReports) ??
      const <String>[];

  /// Replaces the encoded parked-report queue.
  Future<void> writeValues(List<String> values) async {
    final stored = await _preferences.setStringList(
      ParkedReportStoreKeys.parkedReports,
      values,
    );
    if (!stored) throw StateError('Failed to park an error report.');
  }

  /// Removes the queue after the final report is acknowledged.
  Future<void> clearValues() async {
    final removed = await _preferences.remove(
      ParkedReportStoreKeys.parkedReports,
    );
    if (!removed) {
      throw StateError('Failed to acknowledge a parked error report.');
    }
  }
}
