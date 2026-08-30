import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

/// {@template update_command}
/// A command which reports the supported CLI update steps.
/// {@endtemplate}
class UpdateCommand extends Command<int> {
  /// {@macro update_command}
  UpdateCommand({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  String get description => 'Show the supported source update steps.';

  static const String commandName = 'update';

  @override
  String get name => commandName;

  @override
  Future<int> run() async {
    _logger.info(
      'Automatic updates are unavailable because fcu is distributed as '
      'GitHub source. Clone or pull this repository, then run '
      '`bash scripts/activate.sh` from its root.',
    );
    return ExitCode.success.code;
  }
}
