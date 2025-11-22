# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
