import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

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
  }) : _logger = logger;

  @override
  String get description => 'Create a new Flutter project.';

  @override
  String get name => 'create_new_flutter_project';

  final Logger _logger;

  @override
  Future<int> run() async {
    // Prompt for project details
    final projectDescription = _promptForProjectDescription();
    final organization = _promptForOrganization();
    final projectName = _promptForProjectName();
    final iosLanguage = _promptForIosLanguage();
    final androidLanguage = _promptForAndroidLanguage();
    final template = _promptForTemplate();
    final empty = _promptForEmpty();
    final targetPlatforms = _promptForTargetPlatforms();
    final outputDirectory = _promptForOutputDirectory(projectName);

    // Run the Flutter create command
    _logger.info('Creating Flutter project...');
    try {
      await Process.run(
        'flutter',
        [
          'create',
          '--description',
          projectDescription,
          '--org',
          organization,
          '--project-name',
          projectName,
          '--ios-language=$iosLanguage',
          '--android-language=$androidLanguage',
          '-t',
          template,
          if (empty) '-e',
          '--platforms',
          targetPlatforms.join(','),
          outputDirectory,
        ],
      );
      final outputDir = Directory(outputDirectory);
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

  String _promptForProjectDescription() => _logger.prompt(
        'Enter a description for your project:',
        defaultValue: 'My New Starter Flutter App',
      );

  String _promptForOrganization() => _logger.prompt(
        'Enter the organization for your project:',
        defaultValue: 'com.my_company',
      );

  String _promptForProjectName() => _logger.prompt(
        'Enter the project name:',
        defaultValue: 'my_project_name',
      );

  String _promptForIosLanguage() => _logger.chooseOne(
        'Select the iOS language:',
        choices: ['swift', 'objc'],
      );

  String _promptForAndroidLanguage() => _logger.chooseOne(
        'Select the Android language:',
        choices: ['java', 'kotlin'],
      );

  String _promptForTemplate() => _logger.chooseOne(
        'Select the template:',
        choices: [
          'app',
          'module',
          'package',
          'plugin',
          'plugin_ffi',
          'skeleton',
        ],
      );

  bool _promptForEmpty() =>
      _logger.confirm('Would you like to create an empty project?');

  List<String> _promptForTargetPlatforms() {
    final allChoices = [
      'ios',
      'android',
      'windows',
      'linux',
      'macos',
      'web',
    ];
    return _logger.chooseAny(
      'Select the target platforms:',
      choices: allChoices,
      defaultValues: allChoices,
    );
  }

  String _promptForOutputDirectory(String projectName) => _logger.prompt(
        'Enter the output directory for your project:',
        defaultValue: projectName,
      );
}
