/// Lint rule: router/ can only import from features/, foundation/, resources/, and dependency_injection/.
///
/// The router orchestrates navigation and needs access to features, foundation,
/// and dependency injection, but should not depend on the app layer.
///
/// Examples:
/// ```dart
/// // ❌ BAD: Router importing app
/// // lib/router/router.dart
/// import 'package:myapp/app/app.dart';
///
/// // ✅ GOOD: Router importing features and foundation
/// import 'package:myapp/features/home/home.dart';
/// import 'package:myapp/foundation/ui/theme.dart';
/// ```
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Rule enforcing router import restrictions.
class RouterImportRestrictionsRule extends AnalysisRule {
  /// Diagnostic code for this rule.
  static const LintCode code = LintCode(
    'router_import_restrictions',
    'router/ can only import from features/, foundation/, resources/, and dependency_injection/.',
    // WARNING, not the LintCode default of INFO: every rule here is
    // registered with `registerWarningRule`, and an architecture breach is a
    // build-stopping fault, not a suggestion. At INFO `dart analyze` exits 0
    // and the gate passes with the breach in place.
    severity: DiagnosticSeverity.WARNING,
  );

  /// Creates an instance of [RouterImportRestrictionsRule].
  RouterImportRestrictionsRule()
    : super(
        name: 'router_import_restrictions',
        description: 'Prevents router from importing disallowed layers.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _RouterImportRestrictionsVisitor(this, context);
    registry.addImportDirective(this, visitor);
  }
}

/// Visitor implementation for [RouterImportRestrictionsRule].
class _RouterImportRestrictionsVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _RouterImportRestrictionsVisitor(this.rule, this.context);

  @override
  void visitImportDirective(ImportDirective node) {
    final uri = node.uri.stringValue;
    if (uri == null) return;

    // Get the source file path
    final currentUnit = context.currentUnit;
    if (currentUnit == null) return;
    final filePath = currentUnit.file.path;

    // Only check files in router/ folder
    if (!filePath.contains('lib/router/')) return;

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

    // Router can import from features/, foundation/, resources/, dependency_injection/, and router/
    final isImportingFromFeatures = importPath.startsWith('features/');
    final isImportingFromFoundation = importPath.startsWith('foundation/');
    final isImportingFromResources = importPath.startsWith('resources/');
    final isImportingFromDependencyInjection = importPath.startsWith(
      'dependency_injection/',
    );
    final isImportingFromRouter = importPath.startsWith('router/');

    // If importing from same package but NOT from allowed folders, report error
    if (!isImportingFromFeatures &&
        !isImportingFromFoundation &&
        !isImportingFromResources &&
        !isImportingFromDependencyInjection &&
        !isImportingFromRouter) {
      rule.reportAtNode(node);
    }
  }
}
