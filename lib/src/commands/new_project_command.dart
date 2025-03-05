import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_cli_utils/src/commands/command_args.dart';
import 'package:mason_logger/mason_logger.dart';

typedef _FlutterProjectCreationData =
    ({
      String projectName,
      String projectDescription,
      String organization,
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
/// *Usage:* `flutter_cli_utils new_project`
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
    // Prompt for project details for the args that were not provided
    // in the command line
    final creationData = await _promptForProjectCreationData();

    // Check the output directory
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

    // Check if the dry run flag is set
    final dryRun = argResults?.wasParsed(_dryRunCommandFlag.name) ?? false;
    if (dryRun) {
      _logDryRunDetails(creationData);
      return ExitCode.success.code;
    }

    // Run the Flutter create command
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

      // Check whether the user wants to use the starter brick
      if (creationData.useStarterBrick) {
        await _runStarterBrick(creationData);
      }

      // Initialize a git repository in the project directory
      if (creationData.initGitRepo) {
        await _initGitRepo(creationData);
      }

      return ExitCode.success.code;
    } catch (error) {
      _logger.err('$error');
      return ExitCode.software.code;
    }
  }

  Future<void> _initGitRepo(_FlutterProjectCreationData creationData) async {
    _progress = _logger.progress(
      'Initializing git repository and creating first'
      ' commit...',
    );

    // Add .config.dart files to .gitignore
    // Add .g.dart files to .gitignore
    final gitIgnoreLines = [
      '\n# Generated files',
      '**/dependency_injection.config.dart',
      '**/**.g.dart',
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

    // Run git init command
    final gitInitResult = await Process.run('git', [
      'init',
    ], workingDirectory: creationData.outputDirectory);
    if (gitInitResult.exitCode != 0) {
      throw Exception(
        'Failed to initialize git repository:\n${gitInitResult.stderr}',
      );
    }

    // Run git add command
    final gitAddResult = await Process.run('git', [
      'add',
      '.',
    ], workingDirectory: creationData.outputDirectory);
    if (gitAddResult.exitCode != 0) {
      throw Exception(
        'Failed to add files to git repository:\n${gitAddResult.stderr}',
      );
    }

    // Run git commit command
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
    // Run `mason init` command
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

    // Run `mason add` command
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

    // Run `mason get` command
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

    // Run `mason make` command
    _progress = _logger.progress('Running `mason make`...');
    final masonMakeResult = await Process.start(
      'mason',
      [
        'make',
        'flutter_starter_brick',
        '--on-conflict',
        'overwrite',
        '--proj_name',
        creationData.projectName,
        '--proj_desc',
        creationData.projectDescription,
        '--org_name',
        creationData.organization,
      ],
      workingDirectory: creationData.outputDirectory,
      mode: ProcessStartMode.inheritStdio,
    );
    _progress?.complete();
    if ((await masonMakeResult.exitCode) != 0) {
      throw Exception(
        'Failed to run `mason make flutter_starter_brick` in project:\n'
        '${masonMakeResult.stderr}',
      );
    }

    // Add new_feature_brick
    final masonAddNewFeatureBrickResult = await Process.run('mason', [
      'add',
      'new_feature_brick',
      '--path',
      './bricks/new_feature_brick/',
    ], workingDirectory: creationData.outputDirectory);
    if (masonAddNewFeatureBrickResult.exitCode != 0) {
      throw Exception(
        'Failed to run `mason add new_feature_brick` in project:\n'
        '${masonAddNewFeatureBrickResult.stderr}',
      );
    }
  }

  void _logDryRunDetails(_FlutterProjectCreationData creationData) =>
      _logger.info(
        'Running this command will create a new Flutter project with the '
        'following details:'
        '\n- Project Name: ${creationData.projectName}'
        '\n- Project Description: ${creationData.projectDescription}'
        '\n- Organization: ${creationData.organization}'
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
      if (!isPluginFfi) ...[
        '--ios-language=${creationData.iosLanguage}',
        '--android-language=${creationData.androidLanguage}',
      ],
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

  String _optionOrPrompt(String argName, String Function() promptForArg) =>
      argResults?.option(argName) ?? promptForArg();

  bool _flagOrPrompt(String argName, bool Function() promptForArg) {
    final wasParsed = argResults?.wasParsed(argName) ?? false;
    if (wasParsed) {
      return argResults?.flag(argName) ?? false;
    }
    return promptForArg();
  }

  Future<_FlutterProjectCreationData> _promptForProjectCreationData() async {
    final projectName = _optionOrPrompt(
      _projectNameCommandOption.name,
      _promptForProjectName,
    );

    final projectDescription = _optionOrPrompt(
      _projectDescriptionCommandOption.name,
      _promptForProjectDescription,
    );

    final organization = _optionOrPrompt(
      _organizationCommandOption.name,
      _promptForOrganization,
    );

    final iosLanguage = _optionOrPrompt(
      _iosLanguageCommandOption.name,
      _promptForIosLanguage,
    );

    final androidLanguage = _optionOrPrompt(
      _androidLanguageCommandOption.name,
      _promptForAndroidLanguage,
    );

    final template = _optionOrPrompt(
      _templateCommandOption.name,
      _promptForTemplate,
    );
    final isApp = template == 'app';
    final isPlugin = template == 'plugin';

    final List<String>? parsedTargetPlatforms;
    final List<String> targetPlatforms;
    if (isApp || isPlugin) {
      parsedTargetPlatforms = argResults?.multiOption(
        _targetPlatformsCommandMultiOption.name,
      );
      targetPlatforms =
          (parsedTargetPlatforms ?? []).isEmpty
              ? _promptForTargetPlatforms()
              : parsedTargetPlatforms!;
    } else {
      targetPlatforms = [];
    }

    final outputDirectory = _optionOrPrompt(
      _outputDirectoryCommandOption.name,
      () => _promptForOutputDirectory(projectName),
    );

    final overwrite = _flagOrPrompt(
      _overwriteExistingDirectoryCommandFlag.name,
      _promptForOverwriteExistingDirectory,
    );

    final bool useStarterBrick;
    if (isApp) {
      useStarterBrick = _flagOrPrompt(
        _useStarterBrickCommandFlag.name,
        _promptForUseStarterBrick,
      );
    } else {
      useStarterBrick = false;
    }

    final bool initGitRepo = _flagOrPrompt(
      _initializeGitRepoCommandFlag.name,
      _promptForInitializeGitRepo,
    );

    return (
      projectName: projectName,
      projectDescription: projectDescription,
      organization: organization,
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
