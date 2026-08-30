import 'package:json_annotation/json_annotation.dart';

part 'error_report_dto.g.dart';

/// How serious one report is. Two values and no more: a report is either
/// something that failed, or something worth knowing that did not fail.
///
/// There is no `debug` value on purpose — a report not worth sending is not
/// composed at all — and no `warning`, which would be a third word for the
/// same two cases. These names are the report wire's `info` and `error`
/// values, so one word means one thing across the app and the project's
/// report table.
enum ErrorReportLevel { info, error }

/// One report on its way out of the app.
///
/// Request-only: the receiver answers with no body, so the read direction is
/// not generated.
@JsonSerializable(createFactory: false)
final class ErrorReportDto {
  const ErrorReportDto({
    required this.app,
    required this.level,
    required this.message,
    required this.stack,
    required this.correlationId,
    required this.occurredAt,
    required this.flow,
  });

  /// The short name of the app that sent this report.
  ///
  /// The project's report table takes reports from every app it owns — the
  /// phone app, the website, an admin panel — so without this a phone crash
  /// and a website crash are one undifferentiated pile.
  final String app;

  /// How serious this report is.
  final ErrorReportLevel level;

  /// The same composed message the log line carried, so a report and its
  /// log line stay recognizable as the same failure.
  final String message;

  /// Where the failure came from.
  final String stack;

  /// The backend-minted id for the request behind this report, when one
  /// exists.
  final String? correlationId;

  /// When the failure happened on the device.
  final DateTime occurredAt;

  /// The last actions the user took before the failure, oldest first.
  final List<Map<String, dynamic>> flow;

  /// The body of the request that carries this report.
  Map<String, dynamic> toJson() => _$ErrorReportDtoToJson(this);
}
