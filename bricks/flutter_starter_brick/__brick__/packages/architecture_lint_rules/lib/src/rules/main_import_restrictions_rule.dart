/// Lint rule: main.dart can only import app/, dependency_injection/,
/// foundation/, and resources/ project code.
///
/// The single main does the whole boot and hands over to the app layer; it
/// never reaches a feature or the router itself.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Rule enforcing main.dart import restrictions.
class MainImportRestrictionsRule extends AnalysisRule {
  /// Diagnostic code for this rule.
  static const LintCode code = LintCode(
    'main_import_restrictions',
    'main.dart can only import from app/, dependency_injection/, foundation/, or resources/.',
    severity: DiagnosticSeverity.WARNING,
  );

  /// Creates an instance of [MainImportRestrictionsRule].
  MainImportRestrictionsRule()
    : super(
        name: 'main_import_restrictions',
        description: 'Prevents main.dart from importing disallowed modules.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addImportDirective(
      this,
      _MainImportRestrictionsVisitor(this, context),
    );
  }
}

class _MainImportRestrictionsVisitor extends SimpleAstVisitor<void> {
  _MainImportRestrictionsVisitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitImportDirective(ImportDirective node) {
    final uri = node.uri.stringValue;
    if (uri == null) return;

    final currentUnit = context.currentUnit;
    if (currentUnit == null) return;
    if (!currentUnit.file.path.endsWith('/lib/main.dart')) return;
    if (!uri.startsWith('package:')) return;

    final packageMatch = RegExp(r'package:([^/]+)/(.+)').firstMatch(uri);
    if (packageMatch == null) return;

    final libraryElement = context.libraryElement;
    if (libraryElement == null) return;
    final currentPackageMatch = RegExp(
      r'package:([^/]+)/',
    ).firstMatch(libraryElement.identifier);
    if (currentPackageMatch == null) return;
    if (packageMatch.group(1) != currentPackageMatch.group(1)) return;

    final importPath = packageMatch.group(2)!;
    const allowedFolders = [
      'app/',
      'dependency_injection/',
      'foundation/',
      'resources/',
    ];
    if (!allowedFolders.any(importPath.startsWith)) {
      rule.reportAtNode(node);
    }
  }
}
