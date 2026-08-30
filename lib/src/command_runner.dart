import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:cli_completion/cli_completion.dart';
import 'package:flutter_cli_utils/src/commands/commands.dart';
import 'package:flutter_cli_utils/src/version.dart';
import 'package:mason_logger/mason_logger.dart';

const executableName = 'fcu';
const description = 'Helpful commands for Flutter developers.';

/// {@template flutter_cli_utils_command_runner}
/// A [CommandRunner] for the CLI.
///
/// ```bash
/// $ fcu --version
/// ```
/// {@endtemplate}
class FlutterCliUtilsCommandRunner extends CompletionCommandRunner<int> {
  /// {@macro flutter_cli_utils_command_runner}
  FlutterCliUtilsCommandRunner({Logger? logger})
    : _logger = logger ?? Logger(),
      super(executableName, description) {
    argParser
      ..addFlag(
        'version',
        abbr: 'v',
        negatable: false,
        help: 'Print the current version.',
      )
      ..addFlag(
        'verbose',
        help: 'Noisy logging, including all shell commands executed.',
      );

    addCommand(NewProjectCommand(logger: _logger));
    addCommand(UpdateCommand(logger: _logger));
  }

  @override
  void printUsage() => _logger.info(usage);

  final Logger _logger;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final topLevelResults = parse(args);
      if (topLevelResults['verbose'] == true) {
        _logger.level = Level.verbose;
      }
      return await runCommand(topLevelResults) ?? ExitCode.success.code;
    } on FormatException catch (e, stackTrace) {
      // On format errors, show the commands error message, root usage and
      // exit with an error code
      _logger
        ..err(e.message)
        ..err('$stackTrace')
        ..info('')
        ..info(usage);
      return ExitCode.usage.code;
    } on UsageException catch (e) {
      // On usage errors, show the commands usage message and
      // exit with an error code
      _logger
        ..err(e.message)
        ..info('')
        ..info(e.usage);
      return ExitCode.usage.code;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    // Fast track completion command
    if (topLevelResults.command?.name == 'completion') {
      await super.runCommand(topLevelResults);
      return ExitCode.success.code;
    }

    const tab = '  ';
    _logger
      ..detail('Argument information:')
      ..detail('${tab}Top level options:');
    for (final option in topLevelResults.options) {
      if (topLevelResults.wasParsed(option)) {
        _logger.detail('$tab- $option: ${topLevelResults[option]}');
      }
    }
    if (topLevelResults.command != null) {
      final commandResult = topLevelResults.command!;
      _logger
        ..detail('${tab}Command: ${commandResult.name}')
        ..detail('$tab${tab}Command options:');
      for (final option in commandResult.options) {
        if (commandResult.wasParsed(option)) {
          _logger.detail('$tab$tab- $option: ${commandResult[option]}');
        }
      }
    }

    final int? exitCode;
    if (topLevelResults['version'] == true) {
      _logger.info(packageVersion);
      exitCode = ExitCode.success.code;
    } else {
      exitCode = await super.runCommand(topLevelResults);
    }

    return exitCode;
  }
}
