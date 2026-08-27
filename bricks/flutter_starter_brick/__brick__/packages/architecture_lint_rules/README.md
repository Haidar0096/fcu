# Architecture Lint Rules

`architecture_lint_rules` is the warning-level analyzer plugin shipped inside every Flutter CLI Utils starter app. It enforces the starter's module boundaries, state-management rules, UI conventions, and security guardrails.

The package requires Dart 3.11 or later. Its `pubspec.lock` is intentionally committed so generated apps carry the tested plugin dependency graph.

## Wiring

The generated `analysis_options.yaml` loads the app-local copy by path. Analyzer plugins must use a local `path:` source; the package is not fetched from Git at analysis time.

```yaml
plugins:
  architecture_lint_rules:
    path: packages/architecture_lint_rules
```

Restart the Dart analysis server after changing plugin configuration.

## Project switches

All 26 rules are warning rules and are enabled by default. The official analyzer-plugin `diagnostics` map can disable any rule for one project. For example:

```yaml
plugins:
  architecture_lint_rules:
    path: packages/architecture_lint_rules
    diagnostics:
      no_framework_colors_in_ui: false
```

Use the diagnostic id from the rules list below. `false` disables the rule. The analyzer also accepts an explicit severity such as `warning` or `error` in this map.

## Vendor-wrapper setting

`vendor_imports_stay_in_wrappers` starts with the starter defaults shown below. A project can replace an individual package's allowed locations with a file, a folder, or a list. Locations are relative to `lib/`; an empty list forbids the import everywhere.

```yaml
architecture_lint_rules:
  vendor_import_wrappers:
    dio: foundation/networking
    http:
      - foundation/networking
      - features/downloads/src/download_http.dart
    flutter_svg: resources/src/images.dart
    provider: []
```

The built-in defaults are:

- `dio` and `http`: `foundation/networking`
- `f_logs`, `logger`, `logging`, `loggy`, `talker`, and `talker_flutter`: `foundation/logging`
- `flutter_svg`: `resources/src/images.dart`
- `dart:io`: files whose names end in `_io.dart`
- `provider`, `riverpod`, `flutter_riverpod`, `hooks_riverpod`, and `riverpod_annotation`: nowhere

## Rules

Every diagnostic below has `WARNING` severity.

- `no_feature_cross_imports`: a feature cannot import another feature.
- `no_src_imports`: code enters another module through its barrel, with only the documented composition-root exemptions.
- `resources_cannot_import`: resources cannot import project code.
- `foundation_import_restrictions`: foundation imports only foundation and resources project code.
- `features_import_restrictions`: features import only features, foundation, resources, and fake data project code.
- `router_import_restrictions`: router imports only router, features, foundation, resources, and dependency injection project code.
- `app_import_restrictions`: app imports only app, dependency injection, foundation, resources, and router project code.
- `dependency_injection_import_restrictions`: dependency injection imports only its composition dependencies.
- `fake_data_import_restrictions`: fake data imports only fake data, features, foundation, and resources project code.
- `main_common_import_restrictions`: `main_common.dart` imports only app, dependency injection, foundation, and resources project code.
- `main_environment_files_import_restrictions`: `main_<environment>.dart` imports only foundation and `main_common.dart` project code.
- `vendor_imports_stay_in_wrappers`: configured vendor and SDK imports stay in their owned wrappers.
- `no_locator_reads_in_bloc`: a Bloc or Cubit cannot read GetIt or a locator.
- `no_flutter_ui_in_bloc`: a Bloc or Cubit cannot import Flutter UI, name `BuildContext`, or call navigation APIs.
- `guard_post_await_bloc_emits`: a Bloc or Cubit with an asynchronous gap carries a close-guard mixin and uses `emitIfNotClosed` after `await`.
- `no_backend_url_literals`: backend URL literals stay in `EnvironmentVariables`.
- `no_route_path_literals`: route path literals stay in the `RoutePath` family.
- `no_dto_in_ui_or_bloc_state`: widgets and Bloc state cannot name a `*Dto` type.
- `no_transport_imports_in_ui`: UI files cannot import API, networking, transport, or `NetworkFailure` code.
- `no_framework_colors_in_ui`: UI cannot use `Colors.*`, except `Colors.transparent`.
- `no_snackbar_outside_banner`: `SnackBar` and `ScaffoldMessenger` stay in shared banner code.
- `no_flutter_form`: Flutter's `Form` widget is replaced by the project form helper.
- `require_root_screen_widget`: a screen's outermost build widget is `RootScreenWidget`.
- `no_hardcoded_ui_strings`: direct `Text` strings and named label strings come from localization.
- `require_scoped_ignores`: `ignore_for_file` is forbidden and a line ignore includes ` -- ` followed by a reason.
- `no_secret_literals`: Dart source cannot contain literals shaped like real keys, tokens, private keys, or high-entropy values assigned to secret-named fields.

Rules intentionally match only the named syntax and location. Ambiguous code stays quiet.

## Narrow suppressions

Project configuration is preferred when a rule does not fit a project. A one-line exception names the diagnostic with the plugin prefix `architecture_lint_rules/` (the analyzer ignores a plugin diagnostic only under its prefixed name) and carries a reason so `require_scoped_ignores` remains satisfied:

```dart
// ignore: architecture_lint_rules/no_feature_cross_imports -- Temporary bridge while the shared model moves.
import 'package:sample/features/profile/profile.dart';
```

File-wide ignores are rejected.

## Development

Run the package checks from the copy inside a generated app or from the brick source:

```bash
cd packages/architecture_lint_rules
dart pub get
dart analyze
dart test
```

The test suite covers all 11 module-boundary rules and all 15 starter guardrails. The guardrail suite includes a firing and quiet case per rule, a vendor-setting case, and a diagnostics off-switch case.

References:

- [Dart analyzer plugins](https://dart.dev/tools/analyzer-plugins)
- [analysis_server_plugin](https://pub.dev/packages/analysis_server_plugin)
