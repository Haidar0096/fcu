# 4.6.0
Released 2026-08-28. The starter app was checked page by page against the mobile skill and changed wherever it strayed; the three sample features gained nothing and lost nothing. fcu CLI unchanged (4.4.1).
- Post-generation hook: removes Flutter's placeholder test, wires the Android backup exclusions (`data_extraction_rules.xml`, `backup_rules.xml`) and the web URL strategy, runs `dart fix`/`dart format` after generation and a second `build_runner` pass, so a generated app is a no-op for `dart format`, `build_runner` and `gen-l10n`. The TODO reminder at the end is gone; TODO markers no longer ship in `lib/`.
- The splash is a startup cover over the router, no longer a route; the app starts on the jokes screen behind it. The critical-error message rides hidden navigation data, never the address.
- Environment values are read before the crash guard, so a missing required value stops the app at start naming the key.
- Error reports carry the shared wire fields (`app`, `level`, `message`, `stack`, `correlationId`, `occurredAt`, `flow` of `{name, occurredAt}`), UTC dates, the `X-Correlation-Id` header, and the shared starter list of redacted field names; the report sender rides its own no-report HTTP client, so an upload failure cannot report itself.
- Dependencies: the locator hides GetIt behind an owned `ServiceRegistry`; the app-metadata repository owns `android_id`, `device_info_plus`, `package_info_plus`, `uuid` and returns `Result`s; the transport wrapper owns Dio construction. Hydrated storage moved to the application-support folder.
- Conventions: state classes carry the `State` suffix; every boolean and multi-parameter signature is named and required; the jokes feature lives under `features/random_jokes/random_jokes_screen/` and keeps the last good joke while loading or failed; the spacing scale is 4/8/16/24/32 with a shared `Spacing` widget; theme colors are named in one place; `.fvmrc` is the one Flutter version home, read by CI.
- The base URL in `env/*.json` ends with `/` and API paths are relative.

# 4.5.0
Released 2026-08-28 together with fcu CLI 4.4.1 (the brick and CLI versions stay independent).
- Replaced the per-environment Dart entry points with one `lib/main.dart` and committed `env/development.json` and `env/production.json` build settings. Run, build, CI, release, lint, and structure checks now use `--dart-define-from-file`; required missing values stop startup with the key named.
- fcu CLI 4.4.1: `fcu create` now prints `flutter run --dart-define-from-file=env/development.json` as the next step for a generated starter app.

# 4.4.1
Released 2026-08-28 together with fcu CLI 4.4.0 (the new `--dev-name` option is a minor bump; the brick and CLI versions stay independent).
- Corrected the 4.4.0 architecture-lint claim: the rules were declared through a `git:` plugin source, but the analyzer did not load that source, so generated apps did not enforce them.
- Moved `architecture_lint_rules` into the brick at `packages/architecture_lint_rules` and wired each generated app to its own copy with `path:`. The tracked package lockfile ships with the copy.
- Added 15 warning-level guardrails for vendor wrappers, Bloc boundaries and close guards, URLs and routes, DTO and transport leaks, UI conventions, suppression hygiene, and secret-shaped literals. Every rule can be disabled in plugin diagnostics, and vendor wrappers are configurable.
- Added `tool/check_structure_io.dart` and a dedicated checks-workflow step to validate the generated app's folder and file-name layout.
- Added `fcu create --dev-name`, sanitized the developer name used by template TODOs, removed the retired build-runner conflict flag, updated `json_annotation` to `^4.12.0`, and ignored iOS and macOS Podfile locks in newly initialized repositories.
- Review fixes on top of the above: the pre-generation hook no longer fails when the output directory has no `lib/` yet (a fresh `mason make --output-dir` works); `no_locator_reads_in_bloc` also catches the `GetIt.I<T>()` and `getIt<T>()` call shapes; `no_secret_literals` recognizes every PEM private-key header (`-----BEGIN RSA PRIVATE KEY-----` included); the structure gate also checks an empty `fake_data/` home, an event file under a cubit, a `widgets/` folder where `ui/` is required, the kind folders inside a feature `shared/`, the `_mobile`/`_web`/`shared` platform-split group, a generated file without its declaring file, and the required root app widget; the package README shows the prefixed ignore form (`// ignore: architecture_lint_rules/<rule> -- reason`), which is the only form the analyzer honors for a plugin diagnostic; the generated `analysis_options.yaml` header names `dart analyze` as the command that runs the plugin.

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
