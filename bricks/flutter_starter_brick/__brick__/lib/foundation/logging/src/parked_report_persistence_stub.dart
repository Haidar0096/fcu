/// Unsupported-platform persistence for parked reports.
final class ParkedReportPersistence {
  const ParkedReportPersistence._();

  /// Stops when no supported persistence implementation exists.
  static Future<ParkedReportPersistence> create() =>
      Future<ParkedReportPersistence>.error(
        UnsupportedError('Parked report persistence is unavailable.'),
      );

  /// Unreachable because [create] always stops first.
  Future<List<String>> readValues() => Future<List<String>>.error(
    UnsupportedError('Parked report persistence is unavailable.'),
  );

  /// Unreachable because [create] always stops first.
  Future<void> writeValues(List<String> values) => Future<void>.error(
    UnsupportedError('Parked report persistence is unavailable.'),
  );

  /// Unreachable because [create] always stops first.
  Future<void> clearValues() => Future<void>.error(
    UnsupportedError('Parked report persistence is unavailable.'),
  );
}
