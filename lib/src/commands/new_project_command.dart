import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_cli_utils/src/commands/command_arg.dart';
import 'package:mason_logger/mason_logger.dart';

typedef _FlutterProjectCreationData = ({
  String projectName,
  String projectDescription,
  String organization,
  String devName,
  String iosLanguage,
  String androidLanguage,
  String template,
  List<String> targetPlatforms,
  String outputDirectory,
  bool overwriteExistingDirectory,
  bool useStarterBrick,
  bool initGitRepo,
});

/// {@template new_project_command}
/// A [Command] to create a new Flutter project.
///
/// *Usage:* `fcu create`
///
/// {@endtemplate}
class NewProjectCommand extends Command<int> {
  /// {@macro new_project_command}
  NewProjectCommand({required Logger logger}) : _logger = logger {
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
        _developerNameCommandOption.name,
        help: _developerNameCommandOption.help,
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
      ..addMultiOption(
        _targetPlatformsCommandMultiOption.name,
        help: _targetPlatformsCommandMultiOption.help,
      )
      ..addOption(
        _outputDirectoryCommandOption.name,
        abbr: _outputDirectoryCommandOption.abbr,
        help: _outputDirectoryCommandOption.help,
      )
      ..addFlag(_dryRunCommandFlag.name, help: _dryRunCommandFlag.help)
      ..addFlag(
        _useStarterBrickCommandFlag.name,
        help: _useStarterBrickCommandFlag.help,
      )
      ..addFlag(
        _overwriteExistingDirectoryCommandFlag.name,
        help: _overwriteExistingDirectoryCommandFlag.help,
      )
      ..addFlag(
        _initializeGitRepoCommandFlag.name,
        help: _initializeGitRepoCommandFlag.help,
      );
  }

  Progress? _progress;

  final CommandOption _projectDescriptionCommandOption = const CommandOption(
    name: 'desc',
    abbr: 'd',
    help: 'Description for the project.',
    defaultsTo: 'A new Flutter project',
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
    defaultsTo: 'my_app',
    prompt: 'Enter the project name:',
  );

  final CommandOption _developerNameCommandOption = const CommandOption(
    name: 'dev-name',
    help: 'Developer name passed to the starter brick.',
    defaultsTo: 'developer',
    prompt: 'What is your name?',
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
    choices: ['app', 'module', 'package', 'plugin', 'plugin_ffi', 'skeleton'],
    defaultsTo: 'app',
    prompt: 'Select the template:',
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

  final CommandFlag _useStarterBrickCommandFlag = const CommandFlag(
    name: 'use-starter-brick',
    help: 'Use the starter brick.',
    defaultsTo: false,
    prompt: 'Would you like to use the starter brick?',
  );

  final CommandFlag _overwriteExistingDirectoryCommandFlag = const CommandFlag(
    name: 'overwrite-existing-directory',
    help: 'Overwrite the existing directory if it exists.',
    defaultsTo: false,
    prompt:
        'If the output directory already exists, would you like to '
        'overwrite it?',
  );

  final CommandFlag _initializeGitRepoCommandFlag = const CommandFlag(
    name: 'initialize-git-repo',
    help: 'Initialize a git repository in the project directory.',
    defaultsTo: false,
    prompt:
        'Would you like to initialize a git repository in the project'
        ' directory?',
  );

  @override
  String get description => 'Create a new Flutter project.';

  @override
  String get name => 'create';

  final Logger _logger;

  @override
  Future<int> run() async {
    final creationData = await _promptForProjectCreationData();

    // A dry run only reads and prints, so it answers before anything on
    // disk is touched.
    final dryRun = argResults?.flag(_dryRunCommandFlag.name) ?? false;
    if (dryRun) {
      _logDryRunDetails(creationData);
      return ExitCode.success.code;
    }

    final outputDir = Directory(creationData.outputDirectory);
    if (outputDir.existsSync()) {
      if (!creationData.overwriteExistingDirectory) {
        _logger.err(
          'Directory already exists and will not be overwritten,'
          ' exiting...',
        );
        return ExitCode.cantCreate.code;
      } else {
        _progress = _logger.progress('Deleting existing directory...');
        outputDir.deleteSync(recursive: true);
        _progress?.complete();
      }
    }

    _progress = _logger.progress(
      'Creating Flutter project at '
      '${outputDir.absolute.path}',
    );
    try {
      final flutterCreateCommandResult = await _runFlutterCreateCommand(
        creationData,
      );
      if (flutterCreateCommandResult.exitCode != 0) {
        throw Exception(
          'Failed to create project:\n${flutterCreateCommandResult.stderr}',
        );
      }
      _progress?.complete();

      if (creationData.useStarterBrick) {
        await _runStarterBrick(creationData);
      }

      if (creationData.initGitRepo) {
        await _initGitRepo(creationData);
      }

      if (creationData.useStarterBrick) {
        _logger.info(buildStarterNextSteps(creationData.outputDirectory));
      }

      return ExitCode.success.code;
    } catch (error) {
      _progress?.fail();
      _logger.err('$error');
      return ExitCode.software.code;
    }
  }

  Future<void> _initGitRepo(_FlutterProjectCreationData creationData) async {
    _progress = _logger.progress(
      'Initializing git repository and creating first'
      ' commit...',
    );

    final gitIgnoreLines = [
      '\n# Generated files',
      '**/dependency_injection.config.dart',
      '**/**.g.dart',
      // The route table is reviewed like hand-written code, so it is tracked.
      '!lib/router/src/router.g.dart',
      '**/**.freezed.dart',
      '',
      '# IAI',
      '.iai/scratchpad/',
      '',
      '# Android Kotlin metadata',
      '/android/.kotlin/',
      '',
      '# CocoaPods lockfiles',
      'ios/Podfile.lock',
      'macos/Podfile.lock',
      '',
      '# Deployment secrets',
      'scripts/upload_to_play_store/service_account_json_path',
      'scripts/upload_to_test_flight/api_key_name',
      'scripts/upload_to_test_flight/issuer_id',
      '',
      '# Fastlane generated files',
      'android/fastlane/report.xml',
      'android/fastlane/README.md',
    ].join('\n');
    final addToGitIgnoreResult = await Process.run('bash', [
      '-c',
      'echo "$gitIgnoreLines" >> .gitignore',
    ], workingDirectory: creationData.outputDirectory);
    if (addToGitIgnoreResult.exitCode != 0) {
      throw Exception(
        'Failed to add files to .gitignore:\n${addToGitIgnoreResult.stderr}',
      );
    }

    final gitInitResult = await Process.run('git', [
      'init',
    ], workingDirectory: creationData.outputDirectory);
    if (gitInitResult.exitCode != 0) {
      throw Exception(
        'Failed to initialize git repository:\n${gitInitResult.stderr}',
      );
    }

    final gitAddResult = await Process.run('git', [
      'add',
      '.',
    ], workingDirectory: creationData.outputDirectory);
    if (gitAddResult.exitCode != 0) {
      throw Exception(
        'Failed to add files to git repository:\n${gitAddResult.stderr}',
      );
    }

    final gitCommitResult = await Process.run('git', [
      'commit',
      '-m',
      "'Initial commit'",
    ], workingDirectory: creationData.outputDirectory);
    if (gitCommitResult.exitCode != 0) {
      throw Exception(
        'Failed to create initial commit:\n${gitCommitResult.stderr}',
      );
    }

    _progress?.complete();
  }

  Future<void> _runStarterBrick(
    _FlutterProjectCreationData creationData,
  ) async {
    _progress = _logger.progress('Running `mason init`...');
    final masonInitResult = await Process.run('mason', [
      'init',
    ], workingDirectory: creationData.outputDirectory);
    if (masonInitResult.exitCode != 0) {
      throw Exception(
        'Failed to run `mason init` in project:\n${masonInitResult.stderr}',
      );
    }
    _progress?.complete();

    _progress = _logger.progress('Running `mason add`...');
    final masonAddResult = await Process.run('mason', [
      'add',
      'flutter_starter_brick',
    ], workingDirectory: creationData.outputDirectory);
    if (masonAddResult.exitCode != 0) {
      throw Exception(
        'Failed to run `mason add flutter_starter_brick` in project:\n'
        '${masonAddResult.stderr}',
      );
    }
    _progress?.complete();

    _progress = _logger.progress('Running `mason get`...');
    final masonGetResult = await Process.run('mason', [
      'get',
    ], workingDirectory: creationData.outputDirectory);
    if (masonGetResult.exitCode != 0) {
      throw Exception(
        'Failed to run `mason get` in project:\n${masonGetResult.stderr}',
      );
    }
    _progress?.complete();

    _progress = _logger.progress('Running `mason make`...');
    // `mason make` inherits this process' stdio, so its own output is already
    // on the terminal and its `stderr` stream is not connected to read back.
    final masonMakeProcess = await Process.start(
      'mason',
      buildStarterBrickMakeArguments(
        projectName: creationData.projectName,
        projectDescription: creationData.projectDescription,
        organization: creationData.organization,
        developerName: creationData.devName,
      ),
      workingDirectory: creationData.outputDirectory,
      mode: ProcessStartMode.inheritStdio,
    );
    final masonMakeExitCode = await masonMakeProcess.exitCode;
    if (masonMakeExitCode != 0) {
      throw Exception(
        'Failed to run `mason make flutter_starter_brick` in project '
        '(exit code $masonMakeExitCode); see the output above.',
      );
    }
    _progress?.complete();
  }

  void _logDryRunDetails(_FlutterProjectCreationData creationData) =>
      _logger.info(
        'Running this command will create a new Flutter project with the '
        'following details:'
        '\n- Project Name: ${creationData.projectName}'
        '\n- Project Description: ${creationData.projectDescription}'
        '\n- Organization: ${creationData.organization}'
        '\n- Developer Name: ${creationData.devName}'
        '\n- iOS Language: ${creationData.iosLanguage}'
        '\n- Android Language: ${creationData.androidLanguage}'
        '\n- Template: ${creationData.template}'
        '\n- Target Platforms: ${creationData.targetPlatforms.join(', ')}'
        '\n- Output Directory: ${creationData.outputDirectory}'
        '\n\nExiting...',
      );

  Future<ProcessResult> _runFlutterCreateCommand(
    _FlutterProjectCreationData creationData,
  ) {
    final isApp = creationData.template == 'app';
    final isPlugin = creationData.template == 'plugin';
    final isPluginFfi = creationData.template == 'plugin_ffi';
    return Process.run('flutter', [
      'create',
      '--project-name',
      creationData.projectName,
      '--description',
      creationData.projectDescription,
      '--org',
      creationData.organization,
      // iOS language is only supported for plugin templates
      if (isPlugin) '--ios-language=${creationData.iosLanguage}',
      // Android language is supported for app and plugin templates
      if (!isPluginFfi) '--android-language=${creationData.androidLanguage}',
      '-t',
      creationData.template,
      if (isApp) '--empty',
      if (isApp || isPlugin) ...[
        '--platforms',
        creationData.targetPlatforms.join(','),
      ],
      creationData.outputDirectory,
    ]);
  }

  String _optionOrPrompt({
    required String argName,
    required String Function() promptForArg,
  }) => argResults?.option(argName) ?? promptForArg();

  bool _flagOrPrompt({
    required String argName,
    required bool Function() promptForArg,
  }) {
    final wasParsed = argResults?.wasParsed(argName) ?? false;
    if (wasParsed) {
      return argResults?.flag(argName) ?? false;
    }
    return promptForArg();
  }

  Future<_FlutterProjectCreationData> _promptForProjectCreationData() async {
    final projectName = _optionOrPrompt(
      argName: _projectNameCommandOption.name,
      promptForArg: _promptForProjectName,
    );

    final projectDescription = _optionOrPrompt(
      argName: _projectDescriptionCommandOption.name,
      promptForArg: _promptForProjectDescription,
    );

    final organization = _optionOrPrompt(
      argName: _organizationCommandOption.name,
      promptForArg: _promptForOrganization,
    );

    final template = _optionOrPrompt(
      argName: _templateCommandOption.name,
      promptForArg: _promptForTemplate,
    );
    final isApp = template == 'app';
    final isPlugin = template == 'plugin';

    // iOS language is only supported for plugin templates
    final iosLanguage = isPlugin
        ? _optionOrPrompt(
            argName: _iosLanguageCommandOption.name,
            promptForArg: _promptForIosLanguage,
          )
        : _iosLanguageCommandOption.defaultsTo;

    final androidLanguage = _optionOrPrompt(
      argName: _androidLanguageCommandOption.name,
      promptForArg: _promptForAndroidLanguage,
    );

    final List<String>? parsedTargetPlatforms;
    final List<String> targetPlatforms;
    if (isApp || isPlugin) {
      parsedTargetPlatforms = argResults?.multiOption(
        _targetPlatformsCommandMultiOption.name,
      );
      targetPlatforms = (parsedTargetPlatforms ?? []).isEmpty
          ? _promptForTargetPlatforms()
          : parsedTargetPlatforms!;
    } else {
      targetPlatforms = [];
    }

    final outputDirectory = _optionOrPrompt(
      argName: _outputDirectoryCommandOption.name,
      promptForArg: () => _promptForOutputDirectory(projectName),
    );

    final overwrite = _flagOrPrompt(
      argName: _overwriteExistingDirectoryCommandFlag.name,
      promptForArg: _promptForOverwriteExistingDirectory,
    );

    final bool useStarterBrick;
    if (isApp) {
      useStarterBrick = _flagOrPrompt(
        argName: _useStarterBrickCommandFlag.name,
        promptForArg: _promptForUseStarterBrick,
      );
    } else {
      useStarterBrick = false;
    }

    final devName = useStarterBrick
        ? _optionOrPrompt(
            argName: _developerNameCommandOption.name,
            promptForArg: _promptForDeveloperName,
          )
        : _developerNameCommandOption.defaultsTo;

    final initGitRepo = _flagOrPrompt(
      argName: _initializeGitRepoCommandFlag.name,
      promptForArg: _promptForInitializeGitRepo,
    );

    return (
      projectName: projectName,
      projectDescription: projectDescription,
      organization: organization,
      devName: devName,
      iosLanguage: iosLanguage,
      androidLanguage: androidLanguage,
      template: template,
      targetPlatforms: targetPlatforms,
      outputDirectory: outputDirectory,
      overwriteExistingDirectory: overwrite,
      useStarterBrick: useStarterBrick,
      initGitRepo: initGitRepo,
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

  String _promptForDeveloperName() => _logger.prompt(
    _developerNameCommandOption.prompt,
    defaultValue: _developerNameCommandOption.defaultsTo,
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

  List<String> _promptForTargetPlatforms() => _logger.chooseAny(
    _targetPlatformsCommandMultiOption.prompt,
    choices: _targetPlatformsCommandMultiOption.choices!,
    defaultValues: _targetPlatformsCommandMultiOption.defaultsTo,
  );

  String _promptForOutputDirectory(String projectName) => _logger.prompt(
    _outputDirectoryCommandOption.prompt,
    defaultValue: projectName,
  );

  bool _promptForOverwriteExistingDirectory() => _logger.confirm(
    _overwriteExistingDirectoryCommandFlag.prompt,
    defaultValue: _overwriteExistingDirectoryCommandFlag.defaultsTo,
  );

  bool _promptForUseStarterBrick() => _logger.confirm(
    _useStarterBrickCommandFlag.prompt,
    defaultValue: _useStarterBrickCommandFlag.defaultsTo,
  );

  bool _promptForInitializeGitRepo() => _logger.confirm(
    _initializeGitRepoCommandFlag.prompt,
    defaultValue: _initializeGitRepoCommandFlag.defaultsTo,
  );
}

/// Builds the non-interactive variable arguments passed to the starter brick.
List<String> buildStarterBrickMakeArguments({
  required String projectName,
  required String projectDescription,
  required String organization,
  required String developerName,
}) => [
  'make',
  'flutter_starter_brick',
  '--on-conflict',
  'overwrite',
  '--proj_name',
  projectName,
  '--proj_desc',
  projectDescription,
  '--org_name',
  organization,
  '--dev_name',
  developerName,
];

/// Builds the next steps printed after a starter app is generated.
String buildStarterNextSteps(String outputDirectory) =>
    'Next steps:'
    '\ncd $outputDirectory'
    '\nflutter run --dart-define-from-file=env/development.json';
