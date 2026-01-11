# IAI.local.md - Shared Project Context

## File Structure & Usage Guide

**IMPORTANT:** This file contains SHARED context that benefits ALL AI instances working on this project. Instance-specific detailed tracking goes in separate session files.

### About This File

This file serves as the SHARED MEMORY across all AI instances in this project. It contains:

- Project patterns and insights discovered by ANY instance
- External resources that helped
- Common challenges and corrections
- Architectural decisions
- Instance registry (who's working on what)

### How to Use This System

**When starting new work:**

1. Check existing instances below
2. Determine your instance ID (auto-increment: Instance 1, Instance 2, etc.)
3. Add your instance section here with metadata
4. Create detailed session file: `iai_scratchpad/session_tracking/instance-[N]-[task-name].md`
5. Copy from `~/.iai/template.session.md`
6. Link to your session file from your instance section

**During work:**

- Update SHARED context here (patterns, insights, corrections that help others)
- Update YOUR session file with detailed tracking (timeline, implementation log, etc.)
- Read other instances' shared contributions
- NEVER modify other instances' sections

**Session file naming:**

- Format: `instance-[N]-[brief-task-description].md`
- Example: `instance-1-serverpod-interview-prep.md`
- Example: `instance-2-implement-login-feature.md`

### Multi-Instance Rules

- Each instance has its own section below with metadata + link to session file
- Shared discoveries go in "Shared Project Context" section
- Instance-specific work goes in session files
- Instances can read each other's shared contributions
- Instances cannot modify each other's sections

---

## Shared Project Context

### Project Patterns Discovered

**Architecture Lint Rules Plugin:**
Located at `packages/architecture_lint_rules/`. Dart Analyzer Plugin (uses `analysis_server_plugin` API, Dart 3.10+) that enforces Flutter architecture boundaries in FCU-generated projects.

**7 Rules Implemented:**

| Rule Name | What It Enforces | Exception |
|-----------|------------------|-----------|
| `no_feature_cross_imports` | Features cannot import other features | Can import from `shared/` within same parent feature |
| `no_src_imports` | Must use barrel files, not direct /src/ imports | `dependency_injection/` CAN import any /src/ |
| `resources_cannot_import` | resources/ folder cannot import project code | None |
| `foundation_import_restrictions` | foundation/ can only import resources/ and other foundation/ | None |
| `features_import_restrictions` | features/ can only import foundation/, resources/, fake_data/, features/ | None |
| `router_import_restrictions` | router/ can import features/, foundation/, resources/, dependency_injection/, router/ | None |
| `main_environment_files_import_restrictions` | main_*.dart can only import foundation/, main_common.dart | None |

**Critical: dependency_injection Exception:**
The `no_src_imports` rule has a special exception - `dependency_injection/` CAN import from any /src/ folder. This is architecturally correct because DI needs to know about internal implementations for registration.

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

**Bug Fix (2025-11-26): Nested src/ folders**
The `no_src_imports` rule had a bug with nested `/src/` folders (e.g., `features/x/src/blocs/y/src/`). Greedy regex `*` matched to the LAST `/src/` instead of the first. Fixed by using non-greedy `*?` in the regex patterns.

**Bug Fix (2025-12-04): Nested features not detected**
The `no_feature_cross_imports` rule only extracted the first segment after `features/`, causing nested features like `features/health_issues/listing_screen/` and `features/health_issues/add_screen/` to both match as just `health_issues` (not detected as different features). Fixed regex to extract full feature path: `lib/features/([^/]+(?:/[^/]+)*?)(?:/src/|/[^/]+\.dart|$)`. Also added exception to allow imports from `shared/` folder within same parent feature.

**Bug Fix (2025-12-04): Incorrect message in features_import_restrictions**
The rule message said "features/ can only import from foundation/ and resources/" but actually allowed 4 folders. Fixed to: "features/ can only import from foundation/, resources/, fake_data/, or features/." Caught by adding explicit message validation to tests.

### External Resources Used

- Dart Analyzer Plugin API docs - Reference for `analysis_server_plugin` package
- Note: Official docs have incorrect/outdated API references (see API differences above)

### Common Challenges & Corrections

#### Correction: Template Sync Process

- **What was wrong:** When syncing local files with global templates, I edited in place instead of using the proper cp-backup-merge workflow
- **User's correction:** "I wanted you to use the cp command in order to get the template, and then fill it. So first you backup the current IAI.local.md into iai-scratchfile-temp, and then use cp command to copy the template into this project and replace IAI.local.md, and then you move the data from the backup into IAI.local.md"
- **Lesson learned:** Always use cp workflow: 1) Backup existing file, 2) cp template to replace it, 3) Fill data from backup. This ensures template structure is always fresh and complete.
- **Should update skills:** YES

### Testing Best Practices

**Testing analysis_server_plugin Rules:**
- Use `analyzer_testing` package v0.1.7+ (supports analysis_server_plugin API)
- Requires upgrading: `analysis_server_plugin: ^0.3.4`, `analyzer: ^9.0.0`
- Test pattern: `AnalysisRuleTest` base class with `rule` field set in setUp
- Use `newFile()` to create test files at specific paths
- Use `assertDiagnosticsInFile(path, [diagnostics])` for path-specific rules
- **Always add message validation** with `messageContainsAll` parameter - catches message bugs!
- Example: `lint(0, 41, messageContainsAll: ['Expected message text'])`

**Critical Learning:**
Message validation isn't just nice-to-have - it catches real bugs! Instance 4 discovered an incorrect message in features_import_restrictions rule (missing allowed folders) ONLY because message validation was added.

### Key Architectural Decisions

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

### Future Tasks

- **Monorepo with Dart Workspaces:** Investigate making generated projects a monorepo structure, extracting common features into separate packages. See: https://dart.dev/tools/pub/workspaces

### Shared Dependencies & Constraints

**Plugin Limitations:**

- Plugin takes 10-30 seconds to load after IDE restart

**Testing:**

- Comprehensive tests using `analyzer_testing` package (28 tests covering all 7 rules)
- Test files located in `packages/architecture_lint_rules/test/`
- Run tests with `dart test`

**Current Production State (as of 2025-12-02):**

- Brick: 4.1.0 (on BrickHub)
- CLI: 4.1.0
- Production branch: ef202b6
- Development branch: ff6884a

---

## Active Instances

(none currently)

---

## Completed Instances (Archive)

### Instance 5 (COMPLETED)

**Metadata:**
- Instance ID: 5
- Started: 2025-12-24
- Status: completed
- Last Updated: 2025-12-25
- Task: HttpClient Refactoring - verb-based API (get, post, put, patch, delete, uploadFile, uploadBytes)
- Session File: `iai_scratchpad/session_tracking/instance-5-http-client-refactoring.md`

**Summary:**
Copied HttpClient refactoring from Solvit (Instance 17), adapted for FCU brick. Created extensions folder with string_extensions.dart (baseName), dio_error_message_builder.dart, replaced http_client.dart and dio_http_client.dart with verb-based API (7 methods), migrated jokes_api.dart to use get(), added path:^1.9.1 dependency.

---

### Instance 4 (COMPLETED)

**Metadata:**
- Instance ID: 4
- Started: 2025-12-04
- Status: completed
- Last Updated: 2025-12-04
- Task: Debug analyzer plugin issues and create comprehensive test suite
- Session File: `iai_scratchpad/session_tracking/instance-4-debug-analyzer-plugin.md`

**Summary:**
Fixed critical no_feature_cross_imports bug (nested features detection), created comprehensive test suite with 28 tests covering all 7 rules, upgraded dependencies (analyzer_testing 0.1.7+), added explicit message validation to all tests (which caught features_import_restrictions message bug), updated all documentation.

**Key Discoveries:**
- False statement in IAI.local.md about analyzer_testing not supporting analysis_server_plugin - it DOES (v0.1.7+)
- Nested features bug: regex only extracted first segment, now extracts full path
- Added shared/ folder exception for same parent features
- Message validation caught real bug in features_import_restrictions message

---

### Instance 3 (COMPLETED)

**Metadata:**

- Instance ID: 3
- Started: 2025-12-02
- Status: completed
- Last Updated: 2025-12-02
- Task: Release v4.1.0 - SplashScreen enhancements, CancelToken support, and lint rule improvements
- Session File: `iai_scratchpad/session_tracking/instance-3-release-v4.1.0.md`

**Summary:**
Successfully released v4.1.0 for both brick and CLI. Published brick to BrickHub, updated version numbers and changelog, merged to production (PR #16).

---

### Instance 1 (COMPLETED)

**Metadata:**

- Instance ID: 1
- Started: 2025-11-22
- Status: completed
- Last Updated: 2025-11-22
- Task: Release v4.0.6 - Architecture Lint Rules Plugin
- Session File: `iai_scratchpad/session_tracking/instance-1-release-v406-architecture-lint.md`

**Summary:**
Successfully created architecture_lint_rules plugin with 7 rules enforcing FCU architecture, published brick v4.0.6 to BrickHub, released CLI v4.0.6, merged to production (PR #15).

---

### Instance 2 (COMPLETED)

**Metadata:**

- Instance ID: 2
- Started: 2025-11-26
- Status: completed
- Last Updated: 2025-11-26
- Task: Template Sync - Add missing sections from global templates
- Session File: `iai_scratchpad/session_tracking/instance-2-template-sync.md`

**Summary:**
Synced local tracking files with updated global templates using proper cp-backup-merge workflow. Added "CRITICAL: How to Save Information" guidance and "Files Read This Session" table to session files. Documented correction about proper template sync process.

---

<!--
TEMPLATE FOR NEW INSTANCES:

Copy this when adding a new instance:

---

### Instance N

**Metadata:**
- Instance ID: N
- Started: [YYYY-MM-DD HH:MM]
- Status: [not_started/in_progress/blocked/completed]
- Last Updated: [YYYY-MM-DD HH:MM]
- Task: [Brief task description]
- Session File: `iai_scratchpad/session_tracking/instance-N-[task-name].md`

**Current Status:**
[1-2 sentence summary]

**Blocking Issues:**
[Any blockers]

---
-->
