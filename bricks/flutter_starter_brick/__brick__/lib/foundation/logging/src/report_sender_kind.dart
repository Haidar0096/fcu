/// Names which report sender the app uses.
///
/// One value ships. A second destination costs exactly this: one value
/// here, one implementation beside `BackendReportSender`, and one arm in the
/// switch inside the dependency injection file — no call site changes.
enum ReportSenderKind {
  /// Posts the report to the project's own receiver endpoint.
  ownBackend,
}
