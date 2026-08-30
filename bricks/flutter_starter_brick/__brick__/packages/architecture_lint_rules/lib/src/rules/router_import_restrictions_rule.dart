/// Lint rule: router/ can only import from router/, features/, foundation/,
/// resources/, and dependency_injection/.
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
    'router/ can only import from router/, features/, foundation/, resources/, and dependency_injection/.',
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

    final currentUri = context.libraryElement?.uri;
    if (currentUri == null || currentUri.scheme != 'package') return;
    final currentSegments = currentUri.pathSegments;
    if (currentSegments.length < 3 || currentSegments[1] != 'router') return;

    final parsedUri = Uri.tryParse(uri);
    if (parsedUri == null || parsedUri.scheme == 'dart') return;
    final importedUri = currentUri.resolveUri(parsedUri);
    if (importedUri.scheme != 'package') return;

    final importedSegments = importedUri.pathSegments;
    if (importedSegments.length < 2 ||
        importedSegments.first != currentSegments.first) {
      return;
    }

    const allowedFolders = {
      'dependency_injection',
      'features',
      'foundation',
      'resources',
      'router',
    };
    if (!allowedFolders.contains(importedSegments[1])) {
      rule.reportAtNode(node);
    }
  }
}
