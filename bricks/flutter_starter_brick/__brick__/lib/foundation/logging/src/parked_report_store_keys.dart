/// The stored keys the parked-report store owns.
abstract final class ParkedReportStoreKeys {
  /// Holds the reports waiting for the next launch, one JSON string each.
  static const String parkedReports = 'ParkedReportStore.parked_reports';
}
