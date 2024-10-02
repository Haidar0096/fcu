import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_cli_utils/src/commands/command_args.dart';
import 'package:mason_logger/mason_logger.dart';

typedef _ProjectMetaData = ({
  String projectName,
  String projectDescription,
  String organization,
  String iosLanguage,
  String androidLanguage,
  String template,
  bool empty,
  List<String> targetPlatforms,
  String outputDirectory,
});

/// {@template new_project_command}
/// A [Command] to create a new Flutter project.
///
/// *Usage:* `flutter_cli_utils new_project`
///
/// {@endtemplate}
class NewProjectCommand extends Command<int> {
  /// {@macro new_project_command}
  NewProjectCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addOption(
        _projectDescriptionCommandOption.name,
        abbr: _projectDescriptionCommandOption.abbr,
        help: _projectDescriptionCommandOption.help,
      )
      ..addOption(
        _organizationCommandOption.name,
        abbr: _organizationCommandOption.abbr,
        help: _organizationCommandOption.help,
      )
      ..addOption(
        _projectNameCommandOption.name,
        abbr: _projectNameCommandOption.abbr,
        help: _projectNameCommandOption.help,
      )
      ..addOption(
        _iosLanguageCommandOption.name,
        abbr: _iosLanguageCommandOption.abbr,
        help: _iosLanguageCommandOption.help,
      )
      ..addOption(
        _androidLanguageCommandOption.name,
        abbr: _androidLanguageCommandOption.abbr,
        help: _androidLanguageCommandOption.help,
      )
      ..addOption(
        _templateCommandOption.name,
        abbr: _templateCommandOption.abbr,
        help: _templateCommandOption.help,
      )
      ..addFlag(
        _emptyCommandFlag.name,
        abbr: _emptyCommandFlag.abbr,
        help: _emptyCommandFlag.help,
      )
      ..addMultiOption(
        _targetPlatformsCommandMultiOption.name,
        help: _targetPlatformsCommandMultiOption.help,
      )
      ..addOption(
        _outputDirectoryCommandOption.name,
        abbr: _outputDirectoryCommandOption.abbr,
        help: _outputDirectoryCommandOption.help,
      )
      ..addFlag(
        _dryRunCommandFlag.name,
        help: _dryRunCommandFlag.help,
      );
  }

  final CommandOption _projectDescriptionCommandOption = const CommandOption(
    name: 'desc',
    abbr: 'd',
    help: 'Description for the project.',
    defaultsTo: 'My New Starter Flutter App',
    prompt: 'Enter a description for your project:',
  );

  final CommandOption _organizationCommandOption = const CommandOption(
    name: 'org',
    help: 'Organization for the project.',
    defaultsTo: 'com.my_company',
    prompt: 'Enter the organization for your project:',
  );

  final CommandOption _projectNameCommandOption = const CommandOption(
    name: 'name',
    abbr: 'n',
    help: 'Name for the project.',
    defaultsTo: 'my_project_name',
    prompt: 'Enter the project name:',
  );

  final CommandOption _iosLanguageCommandOption = const CommandOption(
    name: 'ios-lang',
    help: 'iOS language.',
    choices: ['swift', 'objc'],
    defaultsTo: 'swift',
    prompt: 'Select the iOS language:',
  );

  final CommandOption _androidLanguageCommandOption = const CommandOption(
    name: 'android-lang',
    help: 'Android language.',
    choices: ['java', 'kotlin'],
    defaultsTo: 'kotlin',
    prompt: 'Select the Android language:',
  );

  final CommandOption _templateCommandOption = const CommandOption(
    name: 'template',
    abbr: 't',
    help: 'Template for the project.',
    choices: [
      'app',
      'module',
      'package',
      'plugin',
      'plugin_ffi',
      'skeleton',
    ],
    defaultsTo: 'app',
    prompt: 'Select the template:',
  );

  final CommandFlag _emptyCommandFlag = const CommandFlag(
    name: 'empty',
    abbr: 'e',
    help: 'Create an empty project.',
    defaultsTo: false,
    prompt: 'Would you like to create an empty project?',
  );

  final CommandMultiOption _targetPlatformsCommandMultiOption =
      const CommandMultiOption(
    name: 'target-platforms',
    help: 'Target platforms for the project.',
    choices: ['ios', 'android', 'windows', 'linux', 'macos', 'web'],
    defaultsTo: ['android', 'ios', 'web', 'windows', 'linux', 'macos'],
    prompt: 'Select the target platforms:',
  );

  final CommandOption _outputDirectoryCommandOption = const CommandOption(
    name: 'output-directory',
    abbr: 'o',
    help: 'Output directory for the project.',
    defaultsTo: 'my_project_name',
    prompt: 'Enter the output directory for your project:',
  );

  final CommandFlag _dryRunCommandFlag = const CommandFlag(
    name: 'dry-run',
    help: 'Perform a dry run of the command.',
    defaultsTo: false,
    prompt: 'Would you like to perform a dry run of the command?',
  );

  @override
  String get description => 'Create a new Flutter project.';

  @override
  String get name => 'create';

  final Logger _logger;

  @override
  Future<int> run() async {
    // Prompt for project details for the args that were not provided
    // in the command line
    final metaData = await _promptForProjectMetaData();

    // Check the output directory
    final outputDir = Directory(metaData.outputDirectory);
    if (outputDir.existsSync()) {
      final overwrite = _logger.confirm('Directory already exists. Overwrite?');
      if (!overwrite) {
        _logger.err(
          'Directory already exists and will not be overwritten,'
          ' exiting...',
        );
        return ExitCode.cantCreate.code;
      }
    }

    // Check if the dry run flag is set
    final dryRun = argResults?.wasParsed(_dryRunCommandFlag.name) ?? false;
    if (dryRun) {
      _logDryRunDetails(metaData);
      return ExitCode.success.code;
    }

    // Run the Flutter create command
    _logger.info('Creating Flutter project...');
    try {
      final flutterCreateCommandResult =
          await _runFlutterCreateCommand(metaData);
      if (flutterCreateCommandResult.exitCode != 0) {
        throw Exception(
          'Failed to create project:\n${flutterCreateCommandResult.stderr}',
        );
      }
      _logger.success(
        'Flutter project created successfully at '
        '${outputDir.absolute.path}',
      );

      return ExitCode.success.code;
    } catch (error) {
      _logger.err('$error');
      return ExitCode.software.code;
    }
  }

  void _logDryRunDetails(_ProjectMetaData metaData) => _logger.info(
        'Running this command will create a new Flutter project with the '
        'following details:'
        '\n- Project Name: ${metaData.projectName}'
        '\n- Project Description: ${metaData.projectDescription}'
        '\n- Organization: ${metaData.organization}'
        '\n- iOS Language: ${metaData.iosLanguage}'
        '\n- Android Language: ${metaData.androidLanguage}'
        '\n- Template: ${metaData.template}'
        '\n- Empty: ${metaData.empty}'
        '\n- Target Platforms: ${metaData.targetPlatforms.join(', ')}'
        '\n- Output Directory: ${metaData.outputDirectory}'
        '\n\nExiting...',
      );

  Future<ProcessResult> _runFlutterCreateCommand(_ProjectMetaData metaData) =>
      Process.run(
        'flutter',
        [
          'create',
          '--project-name',
          metaData.projectName,
          '--description',
          metaData.projectDescription,
          '--org',
          metaData.organization,
          '--ios-language=${metaData.iosLanguage}',
          '--android-language=${metaData.androidLanguage}',
          '-t',
          metaData.template,
          if (metaData.empty) '-e',
          '--platforms',
          metaData.targetPlatforms.join(','),
          metaData.outputDirectory,
        ],
      );

  String _optionOrPrompt(String argName, String Function() promptForArg) =>
      argResults?.option(argName) ?? promptForArg();

  Future<_ProjectMetaData> _promptForProjectMetaData() async {
    final projectName =
        _optionOrPrompt(_projectNameCommandOption.name, _promptForProjectName);

    final projectDescription = _optionOrPrompt(
      _projectDescriptionCommandOption.name,
      _promptForProjectDescription,
    );

    final organization = _optionOrPrompt(
      _organizationCommandOption.name,
      _promptForOrganization,
    );

    final iosLanguage =
        _optionOrPrompt(_iosLanguageCommandOption.name, _promptForIosLanguage);

    final androidLanguage = _optionOrPrompt(
      _androidLanguageCommandOption.name,
      _promptForAndroidLanguage,
    );

    final template =
        _optionOrPrompt(_templateCommandOption.name, _promptForTemplate);

    final empty =
        argResults?.wasParsed(_emptyCommandFlag.name) ?? _promptForEmpty();

    final parsedTargetPlatforms =
        argResults?.multiOption(_targetPlatformsCommandMultiOption.name);
    final targetPlatforms = (parsedTargetPlatforms ?? []).isEmpty
        ? _promptForTargetPlatforms()
        : parsedTargetPlatforms!;

    final outputDirectory = _optionOrPrompt(
      _outputDirectoryCommandOption.name,
      () => _promptForOutputDirectory(projectName),
    );

    return (
      projectName: projectName,
      projectDescription: projectDescription,
      organization: organization,
      iosLanguage: iosLanguage,
      androidLanguage: androidLanguage,
      template: template,
      empty: empty,
      targetPlatforms: targetPlatforms,
      outputDirectory: outputDirectory,
    );
  }

  String _promptForProjectDescription() => _logger.prompt(
        _projectDescriptionCommandOption.prompt,
        defaultValue: _projectDescriptionCommandOption.defaultsTo,
      );

  String _promptForOrganization() => _logger.prompt(
        _organizationCommandOption.prompt,
        defaultValue: _organizationCommandOption.defaultsTo,
      );

  String _promptForProjectName() => _logger.prompt(
        _projectNameCommandOption.prompt,
        defaultValue: _projectNameCommandOption.defaultsTo,
      );

  String _promptForIosLanguage() => _logger.chooseOne(
        _iosLanguageCommandOption.prompt,
        choices: _iosLanguageCommandOption.choices!,
        defaultValue: _iosLanguageCommandOption.defaultsTo,
      );

  String _promptForAndroidLanguage() => _logger.chooseOne(
        _androidLanguageCommandOption.prompt,
        choices: _androidLanguageCommandOption.choices!,
        defaultValue: _androidLanguageCommandOption.defaultsTo,
      );

  String _promptForTemplate() => _logger.chooseOne(
        _templateCommandOption.prompt,
        choices: _templateCommandOption.choices!,
        defaultValue: _templateCommandOption.defaultsTo,
      );

  bool _promptForEmpty() => _logger.confirm(_emptyCommandFlag.prompt);

  List<String> _promptForTargetPlatforms() => _logger.chooseAny(
        _targetPlatformsCommandMultiOption.prompt,
        choices: _targetPlatformsCommandMultiOption.choices!,
        defaultValues: _targetPlatformsCommandMultiOption.defaultsTo,
      );

  String _promptForOutputDirectory(String projectName) => _logger.prompt(
        _outputDirectoryCommandOption.prompt,
        defaultValue: projectName,
      );
}
