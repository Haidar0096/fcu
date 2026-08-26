import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:{{proj_name}}/foundation/logging/src/parked_report_store_keys.dart';

/// Holds the reports that could not go out, so the next launch sends them.
///
/// Hides `shared_preferences`, the only package this class imports.
///
/// Chosen deviation from "a tiny on-device FILE": writing a file means
/// importing `dart:io`, which the dependency rules keep out of shared code
/// and which would not build on web. The outcome the rule fixes — the report
/// waits on the device and rides the next launch instead of being thrown
/// away — is unchanged, and the storage method is the project's own to pick.
class ParkedReportStore {
  ParkedReportStore({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  /// How many reports wait at most, so the queue stays tiny. A project that
  /// must never lose a report raises this.
  static const int capacity = 20;

  final SharedPreferences _sharedPreferences;

  /// Parks [report], dropping the oldest once [capacity] is reached.
  Future<void> park(Map<String, dynamic> report) async {
    final parked = <String>[..._read(), jsonEncode(report)];
    final trimmed = parked.length > capacity
        ? parked.sublist(parked.length - capacity)
        : parked;

    await _sharedPreferences.setStringList(
      ParkedReportStoreKeys.parkedReports,
      trimmed,
    );
  }

  /// Returns everything parked and clears the store in the same step, so a
  /// drain can never send the same report twice.
  Future<List<Map<String, dynamic>>> takeAll() async {
    final parked = _read();
    if (parked.isEmpty) return const <Map<String, dynamic>>[];

    await _sharedPreferences.remove(ParkedReportStoreKeys.parkedReports);

    return parked
        .map<Object?>(jsonDecode)
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  List<String> _read() =>
      _sharedPreferences.getStringList(ParkedReportStoreKeys.parkedReports) ??
      const <String>[];
}
