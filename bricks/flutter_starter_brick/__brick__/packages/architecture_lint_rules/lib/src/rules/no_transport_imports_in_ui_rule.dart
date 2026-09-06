/// Stops API and transport imports at the Bloc boundary.
///
/// The rule guards WIDGET files. `foundation/ui/models/` is a UI MODEL home,
/// not a widget folder: a UI model is the display-side twin of a transport
/// type, built at the Bloc boundary, so it must name the transport type it
/// converts from and is excluded from this rule.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:architecture_lint_rules/src/rules/rule_utils.dart';

bool _isUiFilePath(String filePath) {
  final normalized = filePath.replaceAll('\\', '/');
  final markerIndex = normalized.lastIndexOf('/lib/');
  String? relativePath;
  if (markerIndex >= 0) {
    relativePath = normalized.substring(markerIndex + '/lib/'.length);
  } else if (normalized.startsWith('lib/')) {
    relativePath = normalized.substring(4);
  }
  if (relativePath == null) return false;
  final segments = relativePath.split('/');
  if (segments.length >= 2 &&
      segments[0] == 'foundation' &&
      segments[1] == 'ui') {
    // `foundation/ui/models/` holds UI models, not widgets. A UI model is
    // created at the Bloc boundary from the transport type it displays, so it
    // names that type by design.
    if (segments.length >= 3 && segments[2] == 'models') return false;
    return true;
  }
  if (segments.isEmpty || segments.first != 'features') return false;
  for (var index = 1; index + 1 < segments.length; index++) {
    if ((segments[index] == 'src' || segments[index] == 'shared') &&
        segments[index + 1] == 'ui') {
      return true;
    }
  }
  return false;
}

class NoTransportImportsInUiRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'no_transport_imports_in_ui',
    'UI files must not import API, transport, or NetworkFailure code.',
    correctionMessage: 'Expose UI-shaped state from the Bloc instead.',
    severity: DiagnosticSeverity.WARNING,
  );

  NoTransportImportsInUiRule()
    : super(
        name: 'no_transport_imports_in_ui',
        description: 'Keeps transport vocabulary out of presentation files.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addImportDirective(this, _TransportImportVisitor(this, context));
  }
}

class _TransportImportVisitor extends SimpleAstVisitor<void> {
  _TransportImportVisitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitImportDirective(ImportDirective node) {
    final path = currentFilePath(context);
    if (path == null || !_isUiFilePath(path)) return;
    final uri = node.uri.stringValue?.replaceAll('\\', '/').toLowerCase();
    if (uri == null) return;
    if (uri.contains('/apis/') ||
        uri.contains('/networking/') ||
        uri.contains('/transport/') ||
        uri.contains('network_failure')) {
      rule.reportAtNode(node);
    }
  }
}
