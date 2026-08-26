# 4.4.0
- Three review rounds of fixes across the starter brick and the fcu generator:
  - Hardcoded UI values moved out of the widgets into companion defaults files: `splash_screen_defaults.dart`, `joke_card_defaults.dart`, `critical_error_screen_defaults.dart`, `alert_dialog_defaults.dart`, `status_banner_widget_defaults.dart`
  - l10n module rebuilt: `LocalizationCubit` moved under `foundation/l10n/src/blocs/`, a `Language` type added, and the old `l10n.dart` helper replaced by an `AppLocalizations` `BuildContext` extension
  - `ThemeCubit` moved to `foundation/ui/theme/src/blocs/theme_cubit/`
  - `GlobalLoader` moved out of `foundation/ui/services/` into its own `foundation/ui/global_loader/` module; the focus helper moved to `foundation/ui/focus/` as a `BuildContext` extension; `foundation/ui/services/` removed
  - Snackbar helpers removed from `foundation/ui/widgets/`
  - `RequestDataSanitizer` removed from `foundation/networking/`, replaced by `SensitiveDataSanitizer` in `foundation/logging/`
  - fcu generator: `CommandArgs` split into `CommandArg`, `CommandFlag`, `CommandOption` and `CommandMultiOption`
- Logging system in generated apps:
  - The report road: `ErrorLogger` composes an `ErrorReportDto`, `SensitiveDataSanitizer` strips it, `BackendReportSender` sends it behind the `ReportSender` interface, and `ParkedReportStore` holds a report on the device until it can be sent
  - `ScreenTrailObserver`, a `NavigatorObserver` registered on the router's `observers`, records a route's declared compile-time name constant into `FlowBuffer` on push, replace and pop. It records the declared name and never the live address, and a route declaring no name records nothing. The three shipped routes now declare names (`splash_screen`, `critical_error_screen`, `random_jokes`), so a generated app records its screen trail from its first run
  - Every report carries the sending app's short name (`EnvironmentVariables.appShortName`, one value across every environment) and a level (`ErrorReportLevel.info` or `ErrorReportLevel.error`, defaulting to `error`)
  - Reporting is silent in a debug build and nowhere else: `kDebugMode` is the only signal. The environment picks the server, never whether a report goes out. Parked reports are not drained while reporting is silent
  - `SensitiveDataSanitizer.sanitizeText` returns the text untouched when the deny-list is empty, instead of redacting the whole message
  - `reportReceiverPath` ships empty in both environments and is asked for at project setup, never invented
- Rebuilt architecture lint package (`packages/architecture_lint_rules`):
  - Upgraded to `analysis_server_plugin ^0.3.20` and `analyzer ^14.1.0`; the Dart SDK floor moved to `^3.11.0`, because below it the plugin isolate fails to resolve and no rule runs at all
  - Every rule now declares `DiagnosticSeverity.WARNING`, so `dart analyze` exits non-zero on an architecture breach instead of passing at the `LintCode` default of INFO. The rules fire and are fatal
  - Four new rules: `app_import_restrictions`, `dependency_injection_import_restrictions`, `fake_data_import_restrictions`, `main_common_import_restrictions` — eleven rules in total
  - `no_src_imports`: the `fake_data/` exemption is now the single registry file `lib/fake_data/src/fake_data_registry.dart` rather than the whole folder, and files outside a `src/` folder are checked too
  - `foundation_import_restrictions` and `resources_cannot_import` now use allow-lists scoped to the project's own package instead of a deny-list of folder names
  - `main_environment_files_import_restrictions` matches every `main_<environment>.dart` a project defines instead of three hardcoded names
  - `packages/architecture_lint_rules/pubspec.lock` is now tracked, so every generated app resolving the plugin through its `git:` source resolves the same versions
- The generated project's checks workflow gained an `Analyze (architecture rules)` step running `dart analyze`: on the pinned toolchain `flutter analyze` surfaces no analyzer-plugin diagnostic, so the architecture rules are gated by `dart analyze`

# 4.3.0
- Added CI/CD GitHub Actions workflows for Android and iOS deployment
- Added README documentation for CI/CD workflows
- Added ExportOptions.plist for iOS CI builds
- Added common config setup workflow for shared CI configuration
- Refactored AppMetaDataCubit - extracted AppMetaDataRepository for cleaner separation
- Added IAI.local.md to .gitignore in generated projects
- Updated dependencies: go_router, dio, json_annotation, very_good_analysis, build_runner, go_router_builder, json_serializable
- Added shared_preferences and uuid packages

# 4.2.0
- Removed staging environment (main_staging.dart, StagingEnvironmentVariables, Environment.staging)
- Removed fastlane configuration (using direct API scripts instead)
- Added web build scripts (scripts/build_web/)
- Updated release scripts with dev/prod flavor support
- Simplified README.md structure with link to RELEASE.md
- Added RELEASE.md with comprehensive release workflow documentation
- Fixed create_android_builds to build 6 APKs (dev+prod) instead of 9
- Updated upload_to_playstore.py to use 'completed' status for auto-rollout

# 4.1.4
- Minor formatting updates

# 4.1.3
- Downgraded json_serializable to ^6.11.1 to fix dependency conflict with flutter_test
- Added error throwing in post_gen.dart to fail fast on command errors

# 4.1.2
- Fixed unused variable warning in router.dart
- Updated dependencies (go_router, json_serializable, etc.) in post_gen.dart

# 4.1.1
- Updated upload scripts to support flavor-based builds for development and production.
- Updated HTTP client methods and added error message builder.
- Enhanced random joke fetching.
- Added test for three-level deep same module src imports.
- Enhanced NoFeatureCrossImportsRule to allow shared imports within the same parent feature.
- Added comprehensive test suite and fixed nested features detection.

# 4.1.0
- Enhanced SplashScreen navigation and removed unused router constants
- Added CancelToken support to DioHttpClient and HttpClient; removed obsolete architecture lint rule tests
- Improved regex for module path extraction in NoSrcImportsRule for better nested src/ folder handling

# 4.0.6
- Added architecture lint rules analyzer plugin for enforcing architecture boundaries
- Configured generated projects to use the plugin automatically via git reference

# 4.0.5
- Dependency updates and minor code cleanup and refactoring. No architectural changes.

# 4.0.4
- Removed version history section from README for cleaner documentation

# 4.0.3
- Moved ValidateableStateMixin from foundation/ui/widgets to foundation/ui/mixins for better module organization
- Refactored spacing system with complete 4-unit steps (4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64)
- Renamed all spacing values to numeric pattern (spacing4, spacing8, spacing16, spacing24, spacing32, spacing40, spacing48, spacing64)
- Simplified spacing usage by removing wrapper classes - use SizedBox directly with SpacingSize.spacingX.value
- Fixed brick template variable name (project_name → proj_name) causing import generation issues

# 4.0.2
- Improved random jokes screen UI layout with button docked at bottom
- Fixed layout overflow issues with long jokes using SingleChildScrollView
- Simplified error state handling with cleaner conditional rendering
- Added flutter_launcher_icons package to dev dependencies for app icon generation

# 4.0.1
- Added freezed generated files (*.freezed.dart) to .gitignore
- Added iai_scratchpad/ folder to .gitignore for AI development tracking
- Added /android/.kotlin/ folder to .gitignore for Android Kotlin metadata

# 4.0.0
- Complete architecture overhaul. Major refactoring of the starter brick architecture:

  **Architecture Changes**
  - **Migration**: `infrastructure/` → `foundation/` folder structure
  - **Module Pattern**: Consistent src + barrel file pattern throughout
  - **Simplified Widgets**: Removed complex/specific widgets, kept essentials
  - **Logger Optimization**: Removed duplicate logging, centralized in HTTP client
  - **Clean Separation**: Better organization of core vs app-specific code

  **Code Quality Improvements**
  - Removed all hardcoded values to defaults classes
  - Fixed all import inconsistencies
  - Eliminated unused dependencies (~24MB reduction)
  - Streamlined localization (110 → 16 essential keys)
  - Enhanced documentation with comprehensive IAI.md in generated projects

  **Development Experience**
  - Clearer module boundaries with explicit exports
  - Better error handling patterns
  - Improved state management patterns
  - More maintainable codebase structure

# 3.2.2
- Fixed a wrong import.

# 3.2.1
- Fixed wrong version of bloc package.

# 3.2.0
- Restructured some files.
- Updated some package dependencies.

# 3.1.0
- Added a command to add new_feature_brick in the generated directory.
- Updated docs.
- Fixed new_feature_brick special chars not being escaped properly.

# 3.0.0
- Implemented third iteration of the opinionated architecture of the generated flutter app.
- In this iteration, there aren't a lot of changes from the second iteration, just restructured
some files and folders.

# 2.0.0
- Implemented second iteration of the opinionated architecture of the generated flutter app.

# 1.0.0-preview.4
- Several improvements to the flutter started brick.
- Updated the example of the fcu command in README

# 1.0.0-preview.3
- Moved the router folder to the lib folder.
- Improved the BaseScreenWidget.

# 1.0.0-preview.2
- Added mermaid diagram to the README file to visualize the project structure.

# 1.0.0-preview.1
- First stable release!
- Refactored the whole architecture of the starter flutter app to make it more modular and easier to maintain and scale.

# 0.4.2
- Upgraded mason version.

# 0.4.1
- Fixed a typo in README of the starter brick

# 0.4.0
- Updated a dependency in the starter brick.

# 0.3.0
- Exported the base_request_handler file from the api folder.

# 0.1.0+1
- Initial release.
