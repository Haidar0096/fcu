/// Lint rule: main_&lt;environment&gt;.dart can only import foundation/ and
/// main_common.dart.
///
/// Environment entry points should remain minimal and only set up the environment
/// before delegating to main_common.dart. They should not directly depend on
/// app, features, router, or dependency injection.
///
/// Applies to every `main_<environment>.dart` a project declares — never to
/// `main_common.dart`, which has its own rule.
///
/// Examples:
/// ```dart
/// // ❌ BAD: Main file importing app
/// // main_development.dart
/// import 'package:myapp/app/app.dart';
///
/// // ✅ GOOD: Main file importing foundation and main_common
/// import 'package:myapp/foundation/environments/environment.dart';
/// import 'package:myapp/main_common.dart';
/// ```
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Rule enforcing main environment files import restrictions.
class MainEnvironmentFilesImportRestrictionsRule extends AnalysisRule {
  /// Diagnostic code for this rule.
  static const LintCode code = LintCode(
    'main_environment_files_import_restrictions',
    'main_<environment>.dart can only import foundation/ (for Environment) and main_common.dart.',
    // WARNING, not the LintCode default of INFO: every rule here is
    // registered with `registerWarningRule`, and an architecture breach is a
    // build-stopping fault, not a suggestion. At INFO `dart analyze` exits 0
    // and the gate passes with the breach in place.
    severity: DiagnosticSeverity.WARNING,
  );

  /// Creates an instance of [MainEnvironmentFilesImportRestrictionsRule].
  MainEnvironmentFilesImportRestrictionsRule()
    : super(
        name: 'main_environment_files_import_restrictions',
        description:
            'Prevents main environment files from importing disallowed modules.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _MainEnvironmentFilesImportRestrictionsVisitor(
      this,
      context,
    );
    registry.addImportDirective(this, visitor);
  }
}

/// Visitor implementation for [MainEnvironmentFilesImportRestrictionsRule].
class _MainEnvironmentFilesImportRestrictionsVisitor
    extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _MainEnvironmentFilesImportRestrictionsVisitor(this.rule, this.context);

  @override
  void visitImportDirective(ImportDirective node) {
    final uri = node.uri.stringValue;
    if (uri == null) return;

    // Get the source file path
    final currentUnit = context.currentUnit;
    if (currentUnit == null) return;
    final filePath = currentUnit.file.path;

    // Check if this is a main environment file: any main_<environment>.dart
    // sitting DIRECTLY under lib/, whatever environments the project defines —
    // never main_common.dart, which has its own rule. The direct-child check
    // matters: a shared widget named main_button.dart is not an entry point.
    final isMainEnvironmentFile =
        RegExp(r'/lib/main_[^/]+\.dart$').hasMatch(filePath) &&
        !filePath.endsWith('/lib/main_common.dart');

    if (!isMainEnvironmentFile) return;

    // Only check package: imports (skip dart: and relative imports)
    if (!uri.startsWith('package:')) return;

    // Extract package name and path from import
    final packageMatch = RegExp(r'package:([^/]+)/(.+)').firstMatch(uri);
    if (packageMatch == null) return;

    final importPackage = packageMatch.group(1)!;
    final importPath = packageMatch.group(2)!;

    // Get current package name from the library identifier
    final libraryElement = context.libraryElement;
    if (libraryElement == null) return;

    // Extract package name from library identifier (e.g., "package:myapp/...")
    final identifier = libraryElement.identifier;
    final currentPackageMatch = RegExp(
      r'package:([^/]+)/',
    ).firstMatch(identifier);
    if (currentPackageMatch == null) return;

    final currentPackage = currentPackageMatch.group(1)!;

    // Only check imports from the same package (skip external packages)
    if (importPackage != currentPackage) return;

    // These files can only import from foundation/ or main_common.dart
    final isImportingFromFoundation = importPath.startsWith('foundation/');
    final isImportingMainCommon = importPath == 'main_common.dart';

    // If importing from same package but NOT from allowed files, report error
    if (!isImportingFromFoundation && !isImportingMainCommon) {
      rule.reportAtNode(node);
    }
  }
}
