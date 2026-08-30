import 'dart:async';
import 'dart:convert';

import 'package:{{proj_name}}/foundation/logging/src/parked_report_persistence.dart';

/// Holds the reports that could not go out, so the next launch sends them.
class ParkedReportStore {
  ParkedReportStore._({
    required int? capacity,
    required ParkedReportPersistence persistence,
  }) : _capacity = capacity,
       _persistence = persistence {
    if (capacity != null && capacity <= 0) {
      throw ArgumentError.value(capacity, 'capacity', 'must be positive');
    }
  }

  /// Builds the platform persistence before the report sender can use it.
  static Future<ParkedReportStore> create({required int? capacity}) async =>
      ParkedReportStore._(
        capacity: capacity,
        persistence: await ParkedReportPersistence.create(),
      );

  /// Null until project setup records the project's own queue bound.
  final int? _capacity;
  final ParkedReportPersistence _persistence;
  Future<void> _mutationQueue = Future<void>.value();

  /// Parks [report], dropping the oldest once the project-selected cap is
  /// reached. An unset cap remains null rather than borrowing another queue's
  /// number.
  Future<void> park(Map<String, dynamic> report) =>
      _serializeMutation(() async {
        final parked = <String>[
          ...await _persistence.readValues(),
          jsonEncode(report),
        ];
        final capacity = _capacity;
        final trimmed = capacity != null && parked.length > capacity
            ? parked.sublist(parked.length - capacity)
            : parked;

        await _persistence.writeValues(trimmed);
      });

  /// Returns the oldest report without clearing it.
  ///
  /// The returned `encoded` is the exact stored record the acknowledgement
  /// must present;
  /// a racing or duplicate drain can therefore never remove a different
  /// report.
  Future<({String encoded, Map<String, dynamic> report})?> peek() =>
      _serializeMutation(() async {
        final parked = await _persistence.readValues();
        if (parked.isEmpty) return null;

        final encoded = parked.first;
        final decoded = jsonDecode(encoded);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Parked report is not a JSON object.');
        }
        return (encoded: encoded, report: decoded);
      });

  /// Removes [encoded] only when it is still the oldest parked report.
  Future<void> acknowledge({required String encoded}) => _serializeMutation(
    () async {
      final parked = await _persistence.readValues();
      if (parked.isEmpty || parked.first != encoded) {
        throw StateError('The parked report awaiting acknowledgement changed.');
      }

      final remaining = parked.sublist(1);
      if (remaining.isEmpty) {
        await _persistence.clearValues();
      } else {
        await _persistence.writeValues(remaining);
      }
    },
  );

  Future<T> _serializeMutation<T>(Future<T> Function() mutation) {
    final completer = Completer<T>();
    _mutationQueue = _mutationQueue.then((_) async {
      try {
        completer.complete(await mutation());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }
}
