# Flutter CLI Utils — Project Rules

Project-specific rules and reference for `flutter_cli_utils`. Universal Flutter/Dart rules and architecture come from the global mobile skill (`~/.iai/skills/mobile/`, Flutter mechanics under `mobile/flutter/`) — only the CLI-tool-specific bits live here.

## Project Overview

Flutter CLI Utils (`flutter_cli_utils`) is a command-line tool that generates production-ready Flutter starter projects using the Mason brick system. The tool provides a `fcu` command with project creation and self-update capabilities.

### Key Components
1. **CLI Tool**: Command-line interface for project generation
2. **Starter Brick**: Mason brick template providing a complete Flutter app architecture

## CLI Architecture

```
flutter_cli_utils/
├── bin/
│   └── flutter_cli_utils.dart          # Entry point
├── lib/
│   ├── flutter_cli_utils.dart          # Public API
│   └── src/
│       ├── command_runner.dart         # CLI runner with completion support
│       ├── version.dart                # Generated version info
│       └── commands/
│           ├── command_arg.dart        # Sealed command-argument family
│           ├── command_option.dart     # Option argument
│           ├── command_multi_option.dart # Multi-option argument
│           ├── command_flag.dart       # Flag argument
│           ├── new_project_command.dart # Project creation command
│           └── update_command.dart     # Self-update command
├── bricks/
│   └── flutter_starter_brick/          # Main project template
├── scripts/
│   └── activate.sh                     # Local development activation
└── test/                               # CLI tests, mirroring lib/ paths
```

## Common Development Commands

### Build and Development
```bash
# Activate CLI locally for development
bash scripts/activate.sh

# Build version info (required after updating pubspec.yaml version)
dart run build_runner build --delete-conflicting-outputs

# Lint and analyze code
dart analyze

# Format code
dart format .

# Build executable
dart compile exe bin/flutter_cli_utils.dart -o fcu

# Run CLI directly without building
dart run bin/flutter_cli_utils.dart [command] [options]
```

### Testing
```bash
# Run all tests
dart test

# Test brick generation locally
cd bricks/flutter_starter_brick
mason make flutter_starter_brick --proj_name test_app --org_name com.test --dev_name developer --proj_desc "Test App"
```

### Mason Brick Commands
```bash
# Bundle brick for distribution
cd bricks/flutter_starter_brick
mason bundle -t universal

# Clear mason cache if brick issues occur
mason cache clear

# Add brick locally for testing
mason add flutter_starter_brick --path bricks/flutter_starter_brick
```

## CLI Commands Reference

### Create Command
```bash
# Interactive mode
fcu create

# With all options
fcu create \
  --name "my_app" \
  --desc "My Flutter App" \
  --org "com.example" \
  --ios-lang swift \
  --android-lang kotlin \
  --template app \
  --target-platforms "android,ios,web" \
  --output-directory "./my_app" \
  --use-starter-brick \
  --initialize-git-repo
```

### Update Command
```bash
fcu update
```

### Global Options
- `--version` / `-v`: Show version
- `--verbose`: Enable verbose logging
- `--help` / `-h`: Show help

## Development Workflows

### Working on the CLI

1. **Setup Development Environment**
```bash
bash scripts/activate.sh
```

2. **Test Changes**
```bash
# Run directly
dart run bin/flutter_cli_utils.dart create --help

# Build executable
dart compile exe bin/flutter_cli_utils.dart -o fcu
```

3. **Update Version**
- Update `pubspec.yaml` version
- Run `dart run build_runner build` to update `version.dart`

### Working on the Starter Brick

1. **Test Brick Generation**
```bash
cd bricks/flutter_starter_brick
mason make flutter_starter_brick \
  --proj_name test_app \
  --org_name com.test
```

2. **Update Brick Bundle**
```bash
mason bundle -t universal
```

3. **Test Generated App**
```bash
cd generated_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Build Scripts

### Android Builds Script
Location: `bricks/flutter_starter_brick/__brick__/scripts/create_android_builds/create_android_builds.sh`

Builds APKs for all environments and architectures:
```bash
./scripts/create_android_builds/create_android_builds.sh /output/directory
```

The brick ships two environments, named in full — `development` and
`production`. The script builds one APK per environment per architecture (three
architectures), plus one production AAB. Artifacts carry the house pattern
`<app>-<environment>-<version>+<build>-<arch>.apk`.

**Version Management**: Scripts read version info from a `versions` file at the
project root. It holds an independent version name and build number per
platform, so a platform's build number can move without disturbing the others.

### Upload to TestFlight Script
Location: `bricks/flutter_starter_brick/__brick__/scripts/upload_to_test_flight/upload_to_testflight.sh`

Uploads iOS builds to TestFlight using API key authentication.

**Requirements**: Two files in the same directory:
- `api_key_name`: Contains the API key name
- `issuer_id`: Contains the issuer ID

## Important Implementation Details

### Mason Variable System
The brick uses these variables:
- `{{dev_name}}`: Developer name (used in TODO comments)
- `{{proj_name}}`: Project name (with modifiers: `.snakeCase()`, `.pascalCase()`)
- `{{org_name}}`: Organization identifier (e.g., com.example)
- `{{proj_desc}}`: Project description

### Post-Generation Hook
The starter brick includes a `post_gen.dart` hook that automatically:
- Adds 25+ dependencies (flutter_bloc, get_it, dio, go_router, etc.)
- Adds dev dependencies (very_good_analysis, build_runner, json_serializable, etc.)
- Adds internet permission to Android manifest
- Runs `flutter clean` and `flutter pub get`
- Executes `dart run build_runner build --delete-conflicting-outputs`
- Runs `flutter gen-l10n` for internationalization
- Applies `dart fix --apply` and `dart format .`

## Architecture Lint Rules Plugin

**Architecture Lint Rules Plugin:**
Located at `packages/architecture_lint_rules/`. Dart Analyzer Plugin (uses `analysis_server_plugin` API, Dart 3.10+) that enforces Flutter architecture boundaries in FCU-generated projects.

**Rules implemented** — the complete, current list with examples lives in `packages/architecture_lint_rules/README.md`. The core ones:

| Rule Name | What It Enforces | Exception |
|-----------|------------------|-----------|
| `no_feature_cross_imports` | Features cannot import other features | Can import from `shared/` within same parent feature |
| `no_src_imports` | Must use barrel files, not direct /src/ imports | `dependency_injection/`, `router/` and `fake_data/` CAN import any /src/ |
| `resources_cannot_import` | resources/ folder cannot import project code | None |
| `foundation_import_restrictions` | foundation/ can only import resources/ and other foundation/ | None |
| `features_import_restrictions` | features/ can only import foundation/, resources/, fake_data/, features/ | None |
| `router_import_restrictions` | router/ can import features/, foundation/, resources/, dependency_injection/, router/ | None |
| `main_environment_files_import_restrictions` | main_*.dart can only import foundation/, main_common.dart | None |

**Critical: the composition-root exception:**
The `no_src_imports` rule exempts the three composition roots — `dependency_injection/`, `router/` and `fake_data/` — which CAN import from any /src/ folder. This is architecturally correct: they compose the app, so they need to know about the internal implementations they wire together.

**Plugin Architecture Pattern:**

- Entry point: `lib/main.dart` with `final plugin = ArchitectureLintPlugin();`
- Each rule uses two-class pattern: `Rule extends AnalysisRule` + `_Visitor extends SimpleAstVisitor`
- Rules check `ImportDirective` nodes using visitors
- All rules registered via `registerWarningRule()` (enabled by default)

**API Differences from Official Docs (CRITICAL for future plugin work):**

- `context.currentUnit.file.path` - Get current file path
- `libraryElement.identifier` - Get library identifier for package name
- `context.resolvedLibrary` - DOESN'T EXIST (despite being in docs)
- `context.pubspec.name` - DOESN'T EXIST (despite being in docs)

**Package Name Extraction Pattern:**

```dart
final identifier = libraryElement.identifier;  // "package:myapp/lib/features/..."
final packageMatch = RegExp(r'package:([^/]+)/').firstMatch(identifier);
final currentPackage = packageMatch.group(1)!;
```

**External Resources:**

- Dart Analyzer Plugin API docs - Reference for `analysis_server_plugin` package
- Note: Official docs have incorrect/outdated API references (see API differences above)

**Bug-Fix History:**

**Bug Fix (2025-11-26): Nested src/ folders**
The `no_src_imports` rule had a bug with nested `/src/` folders (e.g., `features/x/src/blocs/y/src/`). Greedy regex `*` matched to the LAST `/src/` instead of the first. Fixed by using non-greedy `*?` in the regex patterns.

**Bug Fix (2025-12-04): Nested features not detected**
The `no_feature_cross_imports` rule only extracted the first segment after `features/`, causing nested features like `features/health_issues/listing_screen/` and `features/health_issues/add_screen/` to both match as just `health_issues` (not detected as different features). Fixed regex to extract full feature path: `lib/features/([^/]+(?:/[^/]+)*?)(?:/src/|/[^/]+\.dart|$)`. Also added exception to allow imports from `shared/` folder within same parent feature.

**Bug Fix (2025-12-04): Incorrect message in features_import_restrictions**
The rule message said "features/ can only import from foundation/ and resources/" but actually allowed 4 folders. Fixed to: "features/ can only import from foundation/, resources/, fake_data/, or features/." Caught by adding explicit message validation to tests.

**Plugin Distribution via Git Reference:**

Generated projects load the architecture lint plugin via git reference pointing to production branch:

```yaml
plugins:
  architecture_lint_rules:
    git:
      url: https://github.com/Haidar0096/fcu.git
      path: packages/architecture_lint_rules
      ref: production
```

This was chosen over pub.dev publishing for easier iteration and immediate updates.

**Plugin Limitations:**

- MEASURED 2026-08-26, on the pinned toolchain (Flutter 3.44.9 / Dart 3.12.2):
  the plugin produces NO diagnostics through the `git:` wiring above. A freshly
  generated app carrying a deliberate `/src/` import and a deliberate feature
  cross-import answers `No issues found!` and `flutter analyze` exits 0. So a
  generated project's import rules are NOT gated by the analyzer today — they
  rest on review alone. Nobody has measured an IDE, so no claim is made about
  one, and no remedy is named here because the remedy is the user's call.

**Testing analysis_server_plugin Rules:**

- Use `analyzer_testing` package v0.1.7+ (supports analysis_server_plugin API)
- These are the package's CURRENT constraints, read off
  `packages/architecture_lint_rules/pubspec.yaml` — `analysis_server_plugin:
  ^0.3.4`, `analyzer: ^9.0.0` — not an upgrade target. They are what the
  package pins today; whether they move is the user's call, because moving
  them rewrites that package's lock file.
- Every rule has its own test file under `packages/architecture_lint_rules/test/`, covering both directions. Run with `dart test`.
- Tests verify both violations and allowed cases; each rule has a dedicated test file.
- Test pattern: `AnalysisRuleTest` base class with `rule` field set in setUp
- Use `newFile()` to create test files at specific paths
- Use `assertDiagnosticsInFile(path, [diagnostics])` for path-specific rules
- **Always add message validation** with `messageContainsAll` parameter - catches message bugs!
- Example: `lint(0, 41, messageContainsAll: ['Expected message text'])`

**Critical Learning:**
Message validation isn't just nice-to-have - it catches real bugs! An earlier audit discovered an incorrect message in features_import_restrictions rule (missing allowed folders) ONLY because message validation was added.

## Common Development Tasks

### Adding a New CLI Command

1. Create command class in `lib/src/commands/`
2. Extend `Command<int>` from args package
3. Register in `FlutterCliUtilsCommandRunner`
4. Update exports in `commands.dart`

## Testing Guidelines

### CLI Testing
- Test command parsing and validation
- Mock external processes (flutter, mason)
- Verify error handling and exit codes

> Architecture lint rules tests live with the plugin — see the **Architecture Lint Rules Plugin** section above.

## Troubleshooting

### Common Issues

1. **Mason brick not found**
   - Ensure brick path is correct
   - Run `mason cache clear` and retry

2. **Code generation fails**
   - Check `build.yaml` configuration
   - Run with `--delete-conflicting-outputs`

3. **DI registration errors**
   - Verify environment parameter matches
   - Check for duplicate registrations

4. **Localization not working**
   - Ensure ARB files are valid JSON
   - Run `flutter gen-l10n`

## Release Process

For detailed release instructions for both the brick and CLI tool, see [RELEASE.md](../../RELEASE.md).

## Prerequisites and Dependencies

### System Requirements

- **Dart SDK**: 3.10.0 or higher (`pubspec.yaml` declares `sdk: ^3.10.0`;
  the lint plugin package declares the same floor)
- **Flutter SDK**: Required for generated projects
- **Mason CLI**: Required for brick operations (`dart pub global activate mason_cli`)

### CLI Development Dependencies

Read from `pubspec.yaml`, which is their one home.

- `args`: Command-line argument parsing
- `cli_completion`: Shell completion support
- `mason_logger`: Console output, prompts and progress
- `pub_updater`: The self-update check

Dev dependencies: `build_runner` and `build_version` (they generate
`lib/src/version.dart`), `test`, and `very_good_analysis` (the lint baseline).

Mason itself is NOT a package dependency of this CLI: the tool shells out to the
`mason` executable, which is why it is listed under System Requirements above.
