/// Lint rule: features/ can only import from foundation/, resources/,
/// fake_data/, and features/.
///
/// Features should remain decoupled from router, app, and dependency injection.
/// They can depend on foundation (infrastructure), resources (assets/strings),
/// fake_data (the fake registry), and other features under the cross-import
/// rule.
///
/// Examples:
/// ```dart
/// // ❌ BAD: Feature importing router
/// // lib/features/home/src/home_screen.dart
/// import 'package:myapp/router/router.dart';
///
/// // ✅ GOOD: Feature importing foundation
/// import 'package:myapp/foundation/ui/widgets/button.dart';
/// ```
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Rule enforcing features import restrictions.
class FeaturesImportRestrictionsRule extends AnalysisRule {
  /// Diagnostic code for this rule.
  static const LintCode code = LintCode(
    'features_import_restrictions',
    'features/ can only import from foundation/, resources/, fake_data/, or features/.',
    // WARNING, not the LintCode default of INFO: every rule here is
    // registered with `registerWarningRule`, and an architecture breach is a
    // build-stopping fault, not a suggestion. At INFO `dart analyze` exits 0
    // and the gate passes with the breach in place.
    severity: DiagnosticSeverity.WARNING,
  );

  /// Creates an instance of [FeaturesImportRestrictionsRule].
  FeaturesImportRestrictionsRule()
    : super(
        name: 'features_import_restrictions',
        description: 'Prevents features from importing disallowed layers.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _FeaturesImportRestrictionsVisitor(this, context);
    registry.addImportDirective(this, visitor);
  }
}

/// Visitor implementation for [FeaturesImportRestrictionsRule].
class _FeaturesImportRestrictionsVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _FeaturesImportRestrictionsVisitor(this.rule, this.context);

  @override
  void visitImportDirective(ImportDirective node) {
    final uri = node.uri.stringValue;
    if (uri == null) return;

    // Get the source file path
    final currentUnit = context.currentUnit;
    if (currentUnit == null) return;
    final filePath = currentUnit.file.path;

    // Only check files in features/ folder
    if (!filePath.contains('lib/features/')) return;

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

    // Features can ONLY import from foundation/, resources/, fake_data/, or features/
    final isImportingFromFoundation = importPath.startsWith('foundation/');
    final isImportingFromResources = importPath.startsWith('resources/');
    final isImportingFromFakeData = importPath.startsWith('fake_data/');
    final isImportingFromFeatures = importPath.startsWith('features/');

    // If importing from same package but NOT from allowed folders, report error
    if (!isImportingFromFoundation &&
        !isImportingFromResources &&
        !isImportingFromFakeData &&
        !isImportingFromFeatures) {
      rule.reportAtNode(node);
    }
  }
}
