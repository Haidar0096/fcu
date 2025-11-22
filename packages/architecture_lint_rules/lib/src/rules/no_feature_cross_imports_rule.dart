/// Lint rule: Features cannot import from other features.
///
/// This rule enforces feature isolation by preventing cross-feature imports.
/// Shared code should be moved to the foundation/ layer instead.
///
/// Examples:
/// ```dart
/// // ❌ BAD: Feature importing another feature
/// // lib/features/authentication/auth_service.dart
/// import 'package:myapp/features/profile/profile.dart';
///
/// // ✅ GOOD: Feature importing foundation
/// import 'package:myapp/foundation/networking/http_client.dart';
/// ```
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Rule enforcing no cross-feature imports.
class NoFeatureCrossImportsRule extends AnalysisRule {
  /// Diagnostic code for this rule.
  static const LintCode code = LintCode(
    'no_feature_cross_imports',
    'Features cannot import from other features.',
    correctionMessage: 'Move shared code to foundation/ instead.',
  );

  /// Creates an instance of [NoFeatureCrossImportsRule].
  NoFeatureCrossImportsRule()
    : super(
        name: 'no_feature_cross_imports',
        description:
            'Prevents features from importing other features to maintain isolation.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _NoFeatureCrossImportsVisitor(this, context);
    registry.addImportDirective(this, visitor);
  }
}

/// Visitor implementation for [NoFeatureCrossImportsRule].
class _NoFeatureCrossImportsVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _NoFeatureCrossImportsVisitor(this.rule, this.context);

  @override
  void visitImportDirective(ImportDirective node) {
    final uri = node.uri.stringValue;
    if (uri == null) return;

    // Get the source file path
    final currentUnit = context.currentUnit;
    if (currentUnit == null) return;
    final filePath = currentUnit.file.path;

    // Check if current file is in a feature folder
    final featureMatch = RegExp(r'lib/features/([^/]+)/').firstMatch(filePath);
    if (featureMatch == null) return; // Not in a feature folder

    final currentFeature = featureMatch.group(1)!;

    // Check if importing from any features/ folder
    final importMatch = RegExp(
      r'package:.+?/features/([^/]+)/',
    ).firstMatch(uri);
    if (importMatch == null) return; // Not importing from features

    final importedFeature = importMatch.group(1)!;

    // Report if importing from a different feature
    if (currentFeature != importedFeature) {
      rule.reportAtNode(node);
    }
  }
}
