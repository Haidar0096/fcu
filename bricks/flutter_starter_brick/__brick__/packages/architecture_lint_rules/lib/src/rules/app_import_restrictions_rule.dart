/// Lint rule: app/ can only import dependency_injection/, foundation/,
/// resources/, and router/.
///
/// The app layer composes the root widgets. It reaches the router and the
/// composition root, but never a feature directly.
///
/// Examples:
/// ```dart
/// // ❌ BAD: App importing a feature
/// // lib/app/src/root_app_widget.dart
/// import 'package:myapp/features/home/home.dart';
///
/// // ✅ GOOD: App importing the router
/// import 'package:myapp/router/router.dart';
/// ```
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Rule enforcing app import restrictions.
class AppImportRestrictionsRule extends AnalysisRule {
  /// Diagnostic code for this rule.
  static const LintCode code = LintCode(
    'app_import_restrictions',
    'app/ can only import from dependency_injection/, foundation/, resources/, router/, or app/.',
    // WARNING, not the LintCode default of INFO: every rule here is
    // registered with `registerWarningRule`, and an architecture breach is a
    // build-stopping fault, not a suggestion. At INFO `dart analyze` exits 0
    // and the gate passes with the breach in place.
    severity: DiagnosticSeverity.WARNING,
  );

  /// Creates an instance of [AppImportRestrictionsRule].
  AppImportRestrictionsRule()
    : super(
        name: 'app_import_restrictions',
        description: 'Prevents app from importing disallowed layers.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _AppImportRestrictionsVisitor(this, context);
    registry.addImportDirective(this, visitor);
  }
}

/// Visitor implementation for [AppImportRestrictionsRule].
class _AppImportRestrictionsVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _AppImportRestrictionsVisitor(this.rule, this.context);

  @override
  void visitImportDirective(ImportDirective node) {
    final uri = node.uri.stringValue;
    if (uri == null) return;

    // Get the source file path
    final currentUnit = context.currentUnit;
    if (currentUnit == null) return;
    final filePath = currentUnit.file.path;

    // Only check files in app/ folder
    if (!filePath.contains('lib/app/')) return;

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

    // app/ can ONLY import dependency_injection/, foundation/, resources/,
    // router/, or itself
    const allowedFolders = [
      'app/',
      'dependency_injection/',
      'foundation/',
      'resources/',
      'router/',
    ];

    // If importing from same package but NOT from allowed folders, report error
    if (!allowedFolders.any(importPath.startsWith)) {
      rule.reportAtNode(node);
    }
  }
}
