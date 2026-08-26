import 'package:json_annotation/json_annotation.dart';

part 'error_report_dto.g.dart';

/// How serious one report is. Two values and no more: a report is either
/// something that failed, or something worth knowing that did not fail.
///
/// There is no `debug` value on purpose — a report not worth sending is not
/// composed at all — and no `warning`, which would be a third word for the
/// same two cases. The two names match `EventLoggerLevel`'s own `info` and
/// `error`, so one word means one thing across the app and across the
/// project's report table.
enum ErrorReportLevel { info, error }

/// One report on its way out of the app.
///
/// Request-only: the receiver answers with no body, so the read direction is
/// not generated.
@JsonSerializable(createFactory: false)
final class ErrorReportDto {
  const ErrorReportDto({
    required this.appShortName,
    required this.level,
    required this.message,
    required this.occurredAt,
    required this.flow,
    this.stackTrace,
    this.backendCorrelationId,
  });

  /// The short name of the app that sent this report.
  ///
  /// The project's report table takes reports from every app it owns — the
  /// phone app, the website, an admin panel — so without this a phone crash
  /// and a website crash are one undifferentiated pile.
  final String appShortName;

  /// How serious this report is.
  final ErrorReportLevel level;

  /// The same composed message the log line carried, so a report and its
  /// log line stay recognizable as the same failure.
  final String message;

  /// When the failure happened on the device.
  final DateTime occurredAt;

  /// The last actions the user took before the failure, oldest first.
  final List<String> flow;

  /// Where the failure came from. A synthesized failure carries the caller's
  /// current stack rather than nothing.
  final String? stackTrace;

  /// The id the project's backend put on the response behind this failure,
  /// so the report can be joined to the request that produced it. The app
  /// never mints one: a failure with no backend call behind it leaves this
  /// empty.
  final String? backendCorrelationId;

  /// The body of the request that carries this report.
  Map<String, dynamic> toJson() => _$ErrorReportDtoToJson(this);
}
