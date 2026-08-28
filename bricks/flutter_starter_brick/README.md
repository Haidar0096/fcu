# flutter_starter_brick

[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

A production-ready Flutter project starter template with clean architecture, comprehensive
foundation modules, and best practices built-in.

## Features

### Architecture & Structure
- [✓] **Clean Architecture**: Feature-based modular structure with clear separation of concerns
- [✓] **Foundation Layer**: Reusable core modules (networking, UI, logging, etc.)
- [✓] **Module Pattern**: Consistent src + barrel file pattern for encapsulation
- [✓] **Multiple Environments**: Development and production configurations

### Development Experience
- [✓] **Type Safety**: Sealed classes, Result types, exhaustive pattern matching
- [✓] **State Management**: BLoC pattern with Cubit, Hydrated BLoC, race condition prevention
- [✓] **Dependency Injection**: Abstract service provider pattern with GetIt
- [✓] **Error Handling**: Result type pattern, no exceptions, user-friendly messages
- [✓] **Logging System**: Structured logging with separation between debug, error, and analytics

### Networking & Data
- [✓] **HTTP Client**: Type-safe, Result-based, with proper error handling
- [✓] **DTO Pattern**: Clean separation between API contracts and UI models
- [✓] **Error Recovery**: Network failure handling with retry capabilities

### UI & User Experience
- [✓] **Rich UI Components**: 15+ customizable widgets following Material 3
- [✓] **Theming System**: Light/dark themes with persistent preferences
- [✓] **Internationalization**: Multi-language support with ARB files
- [✓] **Responsive Design**: Adaptive layouts for different screen sizes
- [✓] **Animations**: Pre-built animation utilities and extensions

### Developer Tools
- [✓] **IAI System Setup**: Pre-configured `.iai/` skeleton with project-specific rules; universal Flutter rules ship via the global `mobile` skill
- [✓] **Build Scripts**: APK generation for all architectures and environments
- [✓] **TestFlight Upload**: Automated iOS distribution script
- [✓] **GitHub Actions**: PR checks (format, analyze, test, build) plus Play Store and TestFlight deploy workflows
- [✓] **Architecture Plugin**: 26 warning rules ship inside every app and load through `path: packages/architecture_lint_rules`
- [✓] **Structure Gate**: `dart run tool/check_structure_io.dart` checks the real folder and file-name layout

## Project Structure

The generated project follows a clean, modular architecture:

```
lib/
├── app/                      # Application root widget
├── dependency_injection/     # Service registration
├── features/                 # Feature modules
│   ├── splash_screen/          # Splash with initialization
│   ├── random_jokes/           # Example feature
│   └── critical_error_screen/  # Unrecoverable-error screen
├── foundation/              # Core reusable modules
│   ├── blocs/              # Base cubits and utilities
│   ├── environments/       # Environment configuration
│   ├── l10n/              # Localization
│   ├── logging/           # AppLogger, ErrorLogger
│   ├── networking/        # HTTP client, Result types
│   ├── ui/                # Themes, widgets, animations
│   └── validators/        # Form validators
├── resources/              # Assets, fonts, translations
├── router/                 # Type-safe navigation
├── main_development.dart   # Development entry point
├── main_production.dart    # Production entry point
└── main_common.dart        # Shared initialization
```

## Key Patterns

- **Result Type**: All async operations return `Result<Failure, Success>` - no exceptions
- **DTO Pattern**: Clean separation between API DTOs and UI models
- **Module Pattern**: Every module uses src/ for private implementation, barrel file for public API
- **Sealed Classes**: Exhaustive pattern matching for states and errors
- **Logger Pattern**: Centralized logging in HTTP client layer, no duplication

## Getting Started

1. Generate your project using the Flutter CLI Utils tool
2. Run `flutter pub get` to install dependencies
3. Run `flutter gen-l10n` to generate the localizations
4. Run `dart run build_runner build` for code generation
5. Choose your environment and run: `flutter run -t lib/main_development.dart`

## Documentation

Every generated project includes a pre-configured `.iai/` skeleton with `.iai/docs/project_rules.md` — a memory doc the IAI boot dump shows in every chat — documenting the app-specific bits:
- App-specific configuration (orientation, persistence, error handling)
- Starter feature list (splash, random jokes, critical error)
- Code generation dependency choices
- Localization setup
- Animation extensions
- Common task workflows (modifying error handling, etc.)

Universal Flutter/Dart architecture and patterns are provided by the global `mobile` skill in the IAI agent system, with the Flutter mechanics under `mobile/flutter/`.

## Support Me

It is really hard and time-consuming to maintain and update open-source projects, so if you like my
work and would like to support me, consider buying me a coffee, it will be a **GREAT MOTIVATION**
for me to keep doing this work.

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/haidarmehsen)
