import 'package:flutter_cli_utils/src/commands/new_project_command.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:test/test.dart';

void main() {
  test('--dev-name is accepted by fcu create', () {
    final command = NewProjectCommand(logger: Logger());

    final arguments = command.argParser.parse(['--dev-name', 'Jane Doe']);

    expect(arguments.option('dev-name'), 'Jane Doe');
  });

  test('developer name is forwarded to mason as --dev_name', () {
    final arguments = buildStarterBrickMakeArguments(
      projectName: 'sample_app',
      projectDescription: 'Sample app',
      organization: 'dev.example',
      developerName: 'Jane Doe',
    );

    final optionIndex = arguments.indexOf('--dev_name');
    expect(optionIndex, isNonNegative);
    expect(arguments[optionIndex + 1], 'Jane Doe');
  });

  test('starter next steps pass the development environment file', () {
    expect(
      buildStarterNextSteps('sample_app'),
      contains('flutter run --dart-define-from-file=env/development.json'),
    );
  });
}
