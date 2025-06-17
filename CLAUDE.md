# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter CLI utilities project (`flutter_cli_utils`) that provides a command-line tool for creating Flutter projects with a comprehensive starter template. The CLI uses the Mason brick system to generate project templates.

## Key Commands

### Development Setup
```bash
# Activate CLI locally for development
sh -e scripts/activate.sh /path/to/project
```

### CLI Usage
```bash
# Check version
fcu --version

# Create new project (interactive)
fcu create

# Create with all options
fcu create --desc "My app" --org "com.company" --name "app_name" \
  --ios-lang swift --android-lang kotlin --template app \
  --target-platforms "android,ios" --output-directory "my_app" \
  --use-starter-brick --initialize-git-repo

# Update CLI
fcu update
```

### Testing the Starter Brick
When testing changes to the starter brick:
1. Run `fcu create --use-starter-brick` to create a test project
2. Navigate to the created project
3. Run Flutter commands to test the generated code

## Architecture

### CLI Structure
- **Entry point**: `bin/flutter_cli_utils.dart`
- **Command runner**: `lib/src/command_runner.dart` - Sets up CLI with completion support
- **Commands**: Located in `lib/src/commands/`
  - `new_project_command.dart`: Creates Flutter projects with optional starter brick
  - `update_command.dart`: Updates the CLI tool

### Starter Brick Architecture
The starter brick (`bricks/flutter_starter_brick/`) provides a production-ready Flutter app structure:

- **Feature-based structure**: Each feature in its own directory under `features/`
- **Clean architecture layers**:
  - `common/`: Shared widgets, networking, variables
  - `infrastructure/`: Core utilities (logging, environments, themes, validators)
  - `features/`: Feature modules (splash, home, error screens)
  - `router/`: App routing configuration
- **State management**: Uses BLoC pattern with Cubits
- **Multiple environments**: Development, staging, production configs
- **Dependency injection**: Pre-configured setup

## Important Notes

1. **Hardcoded Path**: The file `lib/src/commands/new_project_command.dart` contains a hardcoded path at line 335 that must be removed before publishing to pub.dev.

2. **Mason Integration**: The CLI uses Mason for template management. When the `--use-starter-brick` flag is used, it runs:
   - `mason add flutter_starter_brick --path <brick_path>`
   - `mason get`
   - `mason make flutter_starter_brick`

3. **No Tests**: The project currently has no tests implemented. When adding features, consider adding corresponding tests.

4. **Nested Feature Brick**: The starter brick includes a nested brick for generating new features. Users can run `mason make new_feature_brick` in their generated project to add new features following the established architecture.

5. **Scripts in Starter Brick**:
   - `scripts/create_all_apks.sh`: Builds APKs for all platforms
   - `scripts/upload_ipa_to_testflight.sh`: Uploads iOS builds to TestFlight

## Common Development Tasks

When modifying the CLI:
1. Update command logic in `lib/src/commands/`
2. Update version in `pubspec.yaml` and `lib/src/version.dart`
3. Test changes by running `scripts/activate.sh` and creating test projects

When modifying the starter brick:
1. Edit templates in `bricks/flutter_starter_brick/__brick__/`
2. Update brick configuration in `bricks/flutter_starter_brick/brick.yaml` if adding new variables
3. Test by creating a new project with the updated brick