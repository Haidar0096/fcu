import 'package:{{proj_name}}/foundation/logging/src/error_report_dto.dart';

/// The one road every report leaves the app by.
///
/// `ErrorLogger` hands each report here and knows nothing else about it;
/// only the implementation behind this interface knows the destination, so
/// changing destinations is one new class plus one registration line.
abstract class ReportSender {
  /// Sends [report].
  ///
  /// Never throws and never surfaces anything: a failed upload is parked and
  /// retried on the next launch, and the user is not disturbed by a report
  /// that did not make it.
  Future<void> send(ErrorReportDto report);

  /// Sends everything an earlier launch parked, then clears it. Called once
  /// at boot, never awaited by the launch.
  Future<void> sendParkedReports();
}
