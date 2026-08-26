/// Lint rule: foundation/ can only import resources/ and other foundation subfolders.
///
/// The foundation layer provides core reusable modules and should not depend
/// on higher layers like features, app, router, or dependency injection.
///
/// Examples:
/// ```dart
/// // ❌ BAD: Foundation importing features
/// // lib/foundation/networking/http_client.dart
/// import 'package:myapp/features/auth/auth.dart';
///
/// // ✅ GOOD: Foundation importing resources
/// import 'package:myapp/resources/resources.dart';
/// ```
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Rule enforcing foundation import restrictions.
class FoundationImportRestrictionsRule extends AnalysisRule {
  /// Diagnostic code for this rule.
  static const LintCode code = LintCode(
    'foundation_import_restrictions',
    'foundation/ can only import from resources/ or other foundation subfolders.',
    // WARNING, not the LintCode default of INFO: every rule here is
    // registered with `registerWarningRule`, and an architecture breach is a
    // build-stopping fault, not a suggestion. At INFO `dart analyze` exits 0
    // and the gate passes with the breach in place.
    severity: DiagnosticSeverity.WARNING,
  );

  /// Creates an instance of [FoundationImportRestrictionsRule].
  FoundationImportRestrictionsRule()
    : super(
        name: 'foundation_import_restrictions',
        description: 'Prevents foundation from importing higher layers.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _FoundationImportRestrictionsVisitor(this, context);
    registry.addImportDirective(this, visitor);
  }
}

/// Visitor implementation for [FoundationImportRestrictionsRule].
class _FoundationImportRestrictionsVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _FoundationImportRestrictionsVisitor(this.rule, this.context);

  @override
  void visitImportDirective(ImportDirective node) {
    final uri = node.uri.stringValue;
    if (uri == null) return;

    // Get the source file path
    final currentUnit = context.currentUnit;
    if (currentUnit == null) return;
    final filePath = currentUnit.file.path;

    // Only check files in foundation/ folder
    if (!filePath.contains('lib/foundation/')) return;

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

    // Foundation can ONLY import from foundation/ or resources/
    final isImportingFromFoundation = importPath.startsWith('foundation/');
    final isImportingFromResources = importPath.startsWith('resources/');

    // If importing from same package but NOT from allowed folders, report error
    if (!isImportingFromFoundation && !isImportingFromResources) {
      rule.reportAtNode(node);
    }
  }
}
