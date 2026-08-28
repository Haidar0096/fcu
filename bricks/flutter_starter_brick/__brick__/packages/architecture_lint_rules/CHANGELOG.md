# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - TBD

### Added
- `app_import_restrictions` rule: app/ may import dependency_injection/, foundation/, resources/, router/
- `dependency_injection_import_restrictions` rule: dependency_injection/ may import fake_data/, features/, foundation/, resources/, router/
- `fake_data_import_restrictions` rule: fake_data/ may import features/, foundation/, resources/

### Changed
- Replaced the two per-environment/common main rules with `main_import_restrictions` for the single `lib/main.dart` entry point.
- `no_backend_url_literals` now rejects backend URL literals everywhere in Dart, including `EnvironmentVariables`.
- `no_src_imports` now sanctions all three composition roots (dependency_injection/, router/, the fake_data/ registry), and no longer skips files that live outside a `src/` folder — barrels and `main.dart` are checked too
- `foundation_import_restrictions` and `resources_cannot_import` now use allow-lists scoped to the project's own package, instead of a deny-list of five folder names that both under-reported (fake_data/, `main.dart`) and could fire on a third-party package

## [1.0.0] - 2025-01-19

### Added
- Initial release of architecture lint rules as Dart analyzer plugin
- `no_feature_cross_imports` rule: Prevents features from importing other features
- `resources_cannot_import` rule: Ensures resources folder remains a leaf in architecture
- `foundation_import_restrictions` rule: Restricts foundation to only import resources
- `features_import_restrictions` rule: Limits features to foundation, resources, and fake_data imports
- `router_import_restrictions` rule: Controls router dependencies
- `main_environment_files_import_restrictions` rule: Restricts main entry point imports
- Comprehensive test coverage for all rules
- Detailed documentation with examples

### Changed
- Migrated from `custom_lint_builder` to `analysis_server_plugin` (Dart 3.10+ feature)
- All rules registered as warnings (enabled by default) for strict architecture enforcement

### Technical
- Requires Dart SDK >= 3.10.0
- Uses `analysis_server_plugin: ^0.3.0`
- Implements two-class pattern (AnalysisRule + SimpleAstVisitor) per rule
- Supports standard Dart ignore comments for suppression

[1.0.0]: https://github.com/Haidar0096/fcu/releases/tag/architecture_lint_rules-v1.0.0
