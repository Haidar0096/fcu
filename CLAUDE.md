# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

⚠️ **Version 4.0.0 Update**: Major architecture overhaul - migrated from `infrastructure/` to `foundation/` structure with cleaner organization and improved patterns.

## Project Overview

Flutter CLI Utils (`flutter_cli_utils`) is a command-line tool that generates production-ready Flutter starter projects using the Mason brick system. The tool provides a `fcu` command with project creation and self-update capabilities.

### Key Components
1. **CLI Tool**: Command-line interface for project generation
2. **Starter Brick**: Mason brick template providing a complete Flutter app architecture

## Architecture Overview

### CLI Architecture

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
│           ├── command_args.dart       # Command argument definitions
│           ├── new_project_command.dart # Project creation command
│           └── update_command.dart     # Self-update command
├── bricks/
│   └── flutter_starter_brick/          # Main project template
├── scripts/
│   └── activate.sh                     # Local development activation
└── test/                               # Tests (currently empty)
```

### Generated App Architecture

The starter brick creates a Flutter app with this structure:

```
lib/
├── main_development.dart               # Dev environment entry
├── main_staging.dart                   # Staging environment entry
├── main_production.dart                # Production environment entry
├── main_common.dart                    # Shared initialization
├── dependency_injection/               # DI configuration
│   ├── src/
│   │   ├── injection.dart             # Injectable setup
│   │   ├── register_module.dart       # Manual registrations
│   │   └── service_provider.dart      # DI abstraction
│   └── dependency_injection.dart      # Public exports
├── foundation/                         # Core reusable modules
│   ├── blocs/                         # Base cubits and utilities
│   ├── environments/                   # Environment configuration
│   ├── environment_variables/         # Environment-specific variables
│   ├── extensions/                    # Dart extension methods
│   ├── formatters/                    # Data formatters
│   ├── l10n/                          # Localization infrastructure
│   ├── logging/                       # AppLogger, ErrorLogger, EventLogger
│   ├── models/                        # Shared DTOs and UI models
│   ├── networking/                    # HTTP client, Result types
│   ├── ui/                            # Themes, widgets, animations
│   └── validators/                    # Form validators
├── features/                          # Feature modules
│   ├── splash_screen/                 # Splash with initialization
│   ├── random_jokes/                  # Example feature with API
│   └── error/                         # Global error screen
├── router/                            # Navigation setup
└── resources/                         # Assets, translations
```

## Key Concepts and Patterns

### 1. Result Type Pattern

All async operations use a functional `Result<Failure, Success>` type:

```dart
sealed class Result<F, S> {
  const Result();
  
  factory Result.success(S s) = Success<F, S>;
  factory Result.failure(F f) = Failure<F, S>;
  
  T when<T>({
    required T Function(F failure) failure,
    required T Function(S success) success,
  });
}
```

**Usage**: No exceptions are thrown. All errors are wrapped in Result types.

### 2. Network Error Handling

```dart
// Infrastructure defines abstract failures
sealed class NetworkFailure {
  final int? statusCode;
  final ApiErrorDTO? apiErrorDTO;
}

// Concrete types
final class NetworkError extends NetworkFailure {}
final class ServerError extends NetworkFailure {}
final class TimeoutError extends NetworkFailure {}
final class CancelError extends NetworkFailure {}
final class UnknownError extends NetworkFailure {}
```

### 3. Module Pattern

Every module uses a consistent structure:
- `src/` folder for private implementation
- Barrel file for public exports
- Only export what's actually needed by other modules

### 4. UI Error Display Pattern

Domain failures are wrapped in UI classes for presentation:

```dart
class UiNetworkFailure implements DisplayableUiModel {
  UiNetworkFailure(this.failure);
  final NetworkFailure failure;

  @override
  String getDisplayText(BuildContext context) => switch (failure) {
    NetworkError() => context.appLocalizations.networkErrorMessage,
    ServerError() => context.appLocalizations.serverErrorMessage,
    TimeoutError() => context.appLocalizations.timeoutErrorMessage,
    CancelError() => context.appLocalizations.cancelErrorMessage,
    UnknownError() => context.appLocalizations.unknownErrorMessage,
  };
}
```

### 5. Feature Structure Pattern

Each feature follows this structure:

```
feature_name/
├── feature_name.dart                   # Public barrel export
└── src/
    ├── apis/                          # API clients
    │   └── feature_api.dart
    ├── blocs/                         # State management
    │   └── feature_cubit/
    │       ├── feature_cubit.dart
    │       └── feature_state.dart
    ├── models/
    │   ├── dtos/                      # Network DTOs
    │   ├── mappers/                   # DTO -> UI mappers
    │   └── ui_models/                 # UI models
    └── ui/                            # Screens and widgets
        └── feature_screen.dart
```

### 6. Dependency Injection

Uses abstract ServiceProvider pattern over GetIt:

```dart
// Abstract interface
abstract interface class ServiceProvider {
  void register<T extends Object>(T service, {String? name});
  T get<T extends Object>({String? name});
  Future<void> reset();
}

// Annotations for Injectable
typedef Service = Injectable;
typedef SingletonService = Singleton;
typedef LazySingletonService = LazySingleton;
```

### 7. Environment System

Three environments with sealed classes:

```dart
sealed class Environment {
  const Environment();
}

final class DevelopmentEnvironment extends Environment {}
final class StagingEnvironment extends Environment {}
final class ProductionEnvironment extends Environment {}
```

Each environment has its own:
- Entry point (`main_[environment].dart`)
- Configuration values
- API endpoints
- DI registrations

### 8. Navigation

Type-safe routing with go_router:

```dart
@TypedGoRoute<HomeRoute>(
  path: '/home',
  routes: [
    TypedGoRoute<DetailsRoute>(
      path: 'details/:id',
    ),
  ],
)
class HomeRoute extends GoRouteData {
  @override
  Page<void> buildPage(context, state) => MaterialPage(
    child: BlocProvider(
      create: (_) => getIt<HomeCubit>(),
      child: const HomeScreen(),
    ),
  );
}
```

**Features**:
- Platform-specific page transitions (iOS/Android/Web)
- Generated routes using `go_router_builder`
- Global navigator key accessible via `rootNavigatorKey`
- Deep linking support out of the box

## Common Development Commands

### Build and Development
```bash
# Activate CLI locally for development
sh -e scripts/activate.sh /path/to/project

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
# Run all tests (Note: test directory is currently empty)
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
sh -e scripts/activate.sh /path/to/project
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

### Create APK Script
Location: `bricks/flutter_starter_brick/__brick__/scripts/create_apk.sh`

Builds APKs for all environments and architectures:
```bash
./scripts/create_apk.sh /output/directory
```

Generates 9 APKs (3 environments × 3 architectures):
- `app_name-dev-1.0.0+1-arm.apk`
- `app_name-dev-1.0.0+1-arm64.apk`
- `app_name-dev-1.0.0+1-x64.apk`
- (same pattern for staging and prod)

**Version Management**: Scripts read version info from a `versions` file:
```
android_version_name=1.0.0
android_build_number=1
ios_version_name=1.0.0
ios_build_number=1
```

### Upload to TestFlight Script
Location: `bricks/flutter_starter_brick/__brick__/scripts/upload_to_test_flight/upload_to_testflight.sh`

Uploads iOS builds to TestFlight using API key authentication.

**Requirements**: Two files in the same directory:
- `api_key_name`: Contains the API key name
- `issuer_id`: Contains the issuer ID

## Important Implementation Details

### 1. Hardcoded Path Issue
**File**: `lib/src/commands/new_project_command.dart`
**Lines**: 334-335
**Issue**: Contains hardcoded path to brick location
**TODO**: Must be removed before publishing to pub.dev

```dart
// Current (development):
'--path',  // TODO remove this and the next line before publishing
'/Users/haidarmehsen/dev/projects/flutter/projects/flutter_cli_utils/bricks/flutter_starter_brick'

// Should be (for release):
// Remove the --path flag and path entirely, let mason fetch from BrickHub
```

### 2. App Configuration
Generated apps are configured with:
- **Orientation**: Locked to portrait mode
- **Full screen**: System UI overlays hidden
- **Storage**: HydratedBloc for persistent state
- **Error handling**: Global error logger
- **Linting**: very_good_analysis package

### 3. Logging Pattern

The generated app uses three specialized loggers:
- **AppLogger**: Debug console logging (only in debug mode)
- **ErrorLogger**: Production error reporting (Sentry, Crashlytics, etc.)
- **EventLogger**: Analytics tracking

**Key Rules**:
- Network errors are logged ONLY in DioHttpClient
- Cubits only log critical business errors (not network failures)
- Never log in UI components
- Always use both AppLogger and ErrorLogger for critical errors

### 4. Mason Variable System
The brick uses these variables:
- `{{dev_name}}`: Developer name (used in TODO comments)
- `{{proj_name}}`: Project name (with modifiers: `.snakeCase()`, `.pascalCase()`)
- `{{org_name}}`: Organization identifier (e.g., com.example)
- `{{proj_desc}}`: Project description

### 5. Post-Generation Hook
The starter brick includes a `post_gen.dart` hook that automatically:
- Adds 25+ dependencies (flutter_bloc, get_it, dio, go_router, etc.)
- Adds dev dependencies (very_good_analysis, build_runner, mockito, etc.)
- Adds internet permission to Android manifest
- Runs `flutter clean` and `flutter pub get`
- Executes `dart run build_runner build --delete-conflicting-outputs`
- Runs `flutter gen-l10n` for internationalization
- Applies `dart fix --apply` and `dart format .`

### 6. Code Generation Dependencies
Generated apps use:
- `json_serializable`: DTO serialization
- `go_router_builder`: Type-safe routing
- `flutter_gen`: Asset generation

### 7. Localization System
- Supports English out of the box (Arabic structure ready)
- ARB files in `resources/src/arb/`
- Uses `flutter_localizations` package
- Access via `context.appLocalizations.keyName`

## Generated App Coding Patterns

The following sections document patterns and best practices for working with apps generated by the Flutter Starter Brick. These patterns are built into the generated code and should be followed when extending the app.

### Typography Usage Patterns

Generated apps include a typography system that provides consistent text styling across the application.

**1. ALWAYS provide colors explicitly - typography defines ONLY fonts:**
```dart
// GOOD - Always specify color explicitly
Text(
  'Welcome',
  style: context.typography?.primaryTitle.copyWith(
    color: context.themeData.colorScheme.onSurface,
  ),
)
```

**2. Use copyWith when overriding dynamic or state-dependent properties:**
```dart
// GOOD - Color depends on widget state
Text(
  'Link',
  style: context.typography?.linkText.copyWith(
    color: isEnabled ? primary : disabled, // State-dependent
  ),
)

// GOOD - Single property override
Text(
  'Error: Invalid input',
  style: context.typography?.bodyText.copyWith(
    color: context.themeData.colorScheme.error, // Dynamic from theme
  ),
)
```

**3. Create new Typography style when reused with same static overrides:**
```dart
// If used in 2+ places with same static overrides, add to Typography:
TextStyle get bannerText => Fonts.montserratMedium.textStyle.copyWith(fontSize: 14);

// Then use it:
Text('Banner', style: context.typography?.bannerText)
```

**4. Inline TextStyle for truly unique one-off styles:**
```dart
// GOOD - Unique style, used once, 50%+ different properties
Text(
  'Limited Time: 50% OFF',
  style: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.promotional,
    decoration: TextDecoration.underline,
    letterSpacing: 2,
  ),
)
```

**Decision Framework:**

When you need a text style, ask:
1. **Does existing style match?** → Use it directly
2. **Need to override properties?**
   - Only dynamic/state-dependent properties? → Use copyWith ✅
   - Overriding 3+ static properties OR 50%+ of style? → Go to step 3
3. **Will this style be reused (2+ places)?**
   - Yes → Add new style to Typography class
   - No → Inline new TextStyle

**copyWith Guidelines:**

Use copyWith **ONLY when** overriding properties that are:
- **Dynamic/state-dependent**: Colors based on enabled/disabled state, values from widget state
- **Runtime values**: User input, API data, theme-dependent colors
- **Local context**: Values that Typography class cannot know about

**Do NOT use copyWith when:**
- Overriding **3+ static properties** (constant values like fontSize, fontWeight, height)
- Overriding **50%+ of the style properties** (means it's a different style)
- The same overrides are used in **2+ places** (extract to Typography instead)

**CRITICAL: Semantic Meaning Preservation**

When using `copyWith` on Typography fields, **NEVER** override these properties as they define the semantic identity of the style:
- ❌ **fontSize** - Changing size changes what the style represents
- ❌ **fontFamily** - Breaking the design system's font choice
- ❌ **fontWeight** - Changes the style fundamentally (regular vs bold vs semibold)
- ❌ **fontStyle** - Changes meaning (normal vs italic)

**Acceptable to override** (visual variations that preserve semantic meaning):
- ✅ **color** - Visual variation, doesn't change what it is
- ✅ **decoration** - Adding underline, strikethrough, etc.
- ✅ **letterSpacing** - Layout/spacing adjustment
- ✅ **height** - Line height adjustment
- ✅ **backgroundColor** - Background highlight
- ✅ Other visual/layout properties (shadows, wordSpacing, textBaseline, etc.)

**The Rule:** Only override `copyWith` properties that don't change the semantic identity of the Typography style. The 4 forbidden properties (fontSize, fontWeight, fontFamily, fontStyle) define WHAT the style represents. All other properties are visual variations.

**Typography System Architecture:**

**Fonts (resources/fonts.dart):**
- Enum defining all font files with family, weight, and style
- Extension `textStyle` getter that creates base TextStyle (no fontSize/color)
- Usage: `Fonts.montserratBold.textStyle.copyWith(fontSize: 24, color: red)`

**Typography (foundation/ui/theme/typography.dart):**
- ThemeExtension containing all app text styles as fields
- **IMPORTANT**: Typography provides ONLY font properties (family, weight, size, height)
- **Colors are NEVER included** - must be provided via `.copyWith(color: ...)` in UI code
- Static constants for theme component fonts (defaultButtonFont, defaultErrorFont, etc.)
- Styles named semantically (primaryTitle, bodyText, linkText, etc.)
- Each field has documentation specifying the font properties
- Add new styles as needed for reusable patterns (2+ places)
- Generated apps use **Montserrat** font family by default

### Theme and UI Component Usage

Generated apps include a comprehensive Material 3 theme system. Always leverage the existing theme and design system:

**Use the Material 3 Theme:**
```dart
// GOOD - Using theme colors
Container(
  color: context.themeData.colorScheme.primary,
)

// BAD - Hardcoding colors
Container(
  color: Colors.blue,
)
```

**Reuse Existing Components:**
- Check `foundation/ui/widgets/` for existing buttons, cards, dialogs, etc.
- Don't recreate components that already exist
- Use the app's standard button styles, input fields, and other widgets
- When similar functionality exists, extend or compose rather than duplicate

**Theme Constants Over Magic Numbers:**
```dart
// GOOD - Using theme spacing/sizing
Padding(
  padding: EdgeInsets.all(context.themeData.spacing.medium),
)

// BAD - Hardcoding dimensions
Padding(
  padding: EdgeInsets.all(16),
)
```

**Access Theme via Context:**
- Use `context.themeData` for Material theme access
- Use `context.colorScheme` for color scheme shortcuts
- Use `context.typography` for text styles
- Leverage ThemeCubit for theme state management when needed

**Consistency is Key:**
- Before creating any new UI component, search for similar existing components
- Follow the patterns established in similar features
- Maintain visual consistency across the app by reusing theme values

### Spacing System Usage

Generated apps include a predefined spacing system with 4px increments for consistent UI spacing.

**Our Spacing System** (`SpacingSize` enum in `foundation/ui/widgets/spacing.dart`):
```dart
spacing4   = 4px
spacing8   = 8px
spacing12  = 12px
spacing16  = 16px
spacing20  = 20px
spacing24  = 24px
spacing28  = 28px
spacing32  = 32px
spacing36  = 36px
spacing40  = 40px
spacing44  = 44px
spacing48  = 48px
spacing52  = 52px
spacing56  = 56px
spacing60  = 60px
spacing64  = 64px
```

**Usage Rules:**

1. **Always use `Spacing.vertical()` or `Spacing.horizontal()` widgets:**
   ```dart
   // GOOD - Using design system
   const Spacing.vertical(SpacingSize.spacing16)

   // BAD - Hardcoded spacing
   const SizedBox(height: 16)
   ```

2. **Use the closest available spacing value:**
   - The 4px increment system provides flexibility for most UI needs
   - Choose the spacing value that best fits your design requirements

3. **When to add new spacing values:**
   - **Only if** a specific value is used **20+ times** across the entire app
   - **Only if** the value doesn't fit the 4px increment pattern
   - **Only if** explicitly required for design consistency
   - Otherwise, use the closest available value

### Resources Folder Pattern

Generated apps include a resources folder that provides type-safe access to static assets and localization.

The resources folder is a leaf folder in the architecture - it doesn't import anything but can be imported by any other module.

It provides typed access to images, fonts, and localization resources through Dart enums and constants, preventing typos and making refactoring easier.

**Example usage:**
```dart
// Images - use typed enums instead of strings:
Image.asset(PngImages.appIcon.path)

// Typography - ALWAYS provide colors explicitly:
Text(
  'Welcome',
  style: context.typography?.primaryTitle.copyWith(
    color: context.themeData.colorScheme.onSurface,
  ),
)

// Localization - use context extension:
Text(context.appLocalizations.welcomeMessage)

// The Typography class automatically uses the correct fonts:
// - Titles use Fonts.defaultTitleFont (montserratBold, w700)
// - Body text uses Fonts.defaultBodyFont (montserratRegular, w400)
// - Errors use Fonts.defaultErrorFont (montserratItalic, w400, italic)
//
// IMPORTANT: Typography provides ONLY font properties, never colors.
// Always provide colors explicitly via .copyWith(color: ...)
```

## Common Development Tasks

### Adding a New CLI Command

1. Create command class in `lib/src/commands/`
2. Extend `Command<int>` from args package
3. Register in `FlutterCliUtilsCommandRunner`
4. Update exports in `commands.dart`

### Adding a New Feature to Starter Brick

1. Create feature structure under `__brick__/lib/features/`
2. Follow the established pattern (see random_jokes example)
3. Add routes to router configuration
4. Register dependencies in DI modules
5. Add localization strings to ARB files

### Modifying Error Handling

1. Add new failure type to `foundation/networking/models/`
2. Create corresponding UI wrapper in `foundation/models/ui_models/`
3. Add localized messages to ARB files
4. Update state classes to use new failure types

## Testing Guidelines

### CLI Testing
- Test command parsing and validation
- Mock external processes (flutter, mason)
- Verify error handling and exit codes

### Generated App Testing
- Unit tests for Cubits with mocked APIs
- Widget tests for UI components
- Integration tests for critical flows
- Use Result types in test assertions

## Best Practices

1. **Always use Result types** - Never throw exceptions
2. **Wrap domain errors** - Create UI wrappers for user-facing errors
3. **Follow feature structure** - Keep features self-contained
4. **Use sealed classes** - For exhaustive pattern matching
5. **Export minimal APIs** - Use barrel files with selective exports
6. **Localize all strings** - No hardcoded user-facing text
7. **Type-safe navigation** - Use go_router's type generation
8. **Abstract dependencies** - Hide third-party libraries behind interfaces
9. **Use BLoC utilities** - Leverage `CubitUtils` mixin for safe state emission
10. **Follow naming conventions** - Files: snake_case, Classes: PascalCase, Variables: camelCase

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

## Version 4.0.0 Changes

Major refactoring of the starter brick architecture:

### Architecture Changes
- **Migration**: `infrastructure/` → `foundation/` folder structure
- **Module Pattern**: Consistent src + barrel file pattern throughout
- **Simplified Widgets**: Removed complex/specific widgets, kept essentials
- **Logger Optimization**: Removed duplicate logging, centralized in HTTP client
- **Clean Separation**: Better organization of core vs app-specific code

### Code Quality Improvements
- Removed all hardcoded values to defaults classes
- Fixed all import inconsistencies
- Eliminated unused dependencies (~24MB reduction)
- Streamlined localization (110 → 16 essential keys)
- Enhanced documentation with comprehensive CLAUDE.md in generated projects

### Development Experience
- Clearer module boundaries with explicit exports
- Better error handling patterns
- Improved state management patterns
- More maintainable codebase structure

## Future Enhancements

1. Add comprehensive test coverage for CLI
2. Remove hardcoded brick path before pub.dev release
3. Add more CLI commands (analyze, test, build, etc.)
4. Create additional brick templates (minimal, module, package)
5. Add CI/CD templates to starter brick
6. Implement plugin system for extensibility
7. Add environment configuration templates (.env examples)
8. Create interactive feature generation wizard
9. Add performance monitoring setup
10. Include crash reporting integration

## Additional Resources


### BLoC Utils
The `CubitUtils` mixin provides safe state emission:
```dart
class MyCubit extends Cubit<MyState> with CubitUtils<MyState> {
  Future<void> loadData() async {
    emitIfNotClosed(LoadingState());
    // ... async work
    emitIfNotClosed(LoadedState(data));
  }
}
```

### Animation Extensions
Widgets can be easily animated:
```dart
// Single widget animations
MyWidget().fadeIn(duration: Duration(seconds: 1))
MyWidget().scaleIn()
MyWidget().slideInFromBottom()

// List animations with stagger
[widget1, widget2, widget3].staggeredFadeIn(
  duration: Duration(milliseconds: 300),
  delay: Duration(milliseconds: 100),
)
```

### Release Process
For detailed release instructions for both the brick and CLI tool, see [RELEASE.md](./RELEASE.md)

## Prerequisites and Dependencies

### System Requirements

- **Dart SDK**: 3.0.0 or higher
- **Flutter SDK**: Required for generated projects
- **Mason CLI**: Required for brick operations (`dart pub global activate mason_cli`)

### CLI Development Dependencies

- `args`: Command-line argument parsing
- `cli_completion`: Shell completion support
- `dcli`: Additional CLI utilities
- `mason`: Brick template system
- `build_runner`: Code generation (for version info)