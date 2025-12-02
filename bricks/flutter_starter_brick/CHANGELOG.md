# 0.1.0+1

- Initial release.

# 4.1.0
- Enhanced SplashScreen navigation and removed unused router constants
- Added CancelToken support to DioHttpClient and HttpClient; removed obsolete architecture lint rule tests
- Improved regex for module path extraction in NoSrcImportsRule for better nested src/ folder handling

# 0.3.0

- Exported the base_request_handler file from the api folder.

# 0.4.0

- Updated a dependency in the starter brick.

# 0.4.1

- Fixed a typo in README of the starter brick

# 0.4.2

- Upgraded mason version.

# 1.0.0-preview.1

- First stable release!
- Refactored the whole architecture of the starter flutter app to make it more modular and easier to maintain and scale.

# 1.0.0-preview.2

- Added mermaid diagram to the README file to visualize the project structure.

# 1.0.0-preview.3

- Moved the router folder to the lib folder.
- Improved the BaseScreenWidget.

# 1.0.0-preview.4

- Several improvements to the flutter started brick.
- Updated the example of the fcu command in README

# 2.0.0
- Implemented second iteration of the opinionated architecture of the generated flutter app.

# 3.0.0
- Implemented third iteration of the opinionated architecture of the generated flutter app.
- In this iteration, there aren't a lot of changes from the second iteration, just restructured
some files and folders.

# 3.1.0
- Added a command to add new_feature_brick in the generated directory.
- Updated docs.
- Fixed new_feature_brick special chars not being escaped properly.

# 3.2.0
- Restructured some files.
- Updated some package dependencies.

# 3.2.1
- Fixed wrong version of bloc package.

# 3.2.2
- Fixed a wrong import.

# 4.0.0
- Complete architecture overhaul

# 4.0.1
- Added freezed generated files (*.freezed.dart) to .gitignore
- Added claude_scratchpad/ folder to .gitignore for Claude development tracking
- Added /android/.kotlin/ folder to .gitignore for Android Kotlin metadata

# 4.0.2
- Improved random jokes screen UI layout with button docked at bottom
- Fixed layout overflow issues with long jokes using SingleChildScrollView
- Simplified error state handling with cleaner conditional rendering
- Added flutter_launcher_icons package to dev dependencies for app icon generation

# 4.0.3
- Moved ValidateableStateMixin from foundation/ui/widgets to foundation/ui/mixins for better module organization
- Refactored spacing system with complete 4-unit steps (4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64)
- Renamed all spacing values to numeric pattern (spacing4, spacing8, spacing16, spacing24, spacing32, spacing40, spacing48, spacing64)
- Simplified spacing usage by removing wrapper classes - use SizedBox directly with SpacingSize.spacingX.value
- Fixed brick template variable name (project_name → proj_name) causing import generation issues

# 4.0.4
- Removed version history section from README for cleaner documentation

# 4.0.5
- Dependency updates and minor code cleanup and refactoring. No architectural changes.

# 4.0.6
- Added architecture lint rules analyzer plugin for enforcing architecture boundaries
- Configured generated projects to use the plugin automatically via git reference