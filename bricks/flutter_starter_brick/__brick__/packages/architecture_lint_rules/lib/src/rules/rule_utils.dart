library;

import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/dart/ast/ast.dart';

String? currentFilePath(RuleContext context) => context.currentUnit?.file.path;

String className(ClassDeclaration declaration) =>
    declaration.namePart.typeName.lexeme;

ClassDeclaration? enclosingClass(AstNode node) =>
    ancestorOfType<ClassDeclaration>(node);

T? ancestorOfType<T extends AstNode>(AstNode node) {
  AstNode? current = node.parent;
  while (current != null) {
    if (current is T) return current;
    current = current.parent;
  }
  return null;
}

bool isBlocClass(ClassDeclaration declaration) {
  final name = className(declaration);
  return name.endsWith('Bloc') || name.endsWith('Cubit');
}

bool isInsideBloc(AstNode node) {
  final declaration = enclosingClass(node);
  return declaration != null && isBlocClass(declaration);
}

bool unitContainsBloc(RuleContext context) => context
    .definingUnit
    .unit
    .declarations
    .whereType<ClassDeclaration>()
    .any(isBlocClass);

bool isUiFile(RuleContext context) {
  final path = currentFilePath(context);
  return path != null &&
      (path.contains('/src/ui/') || path.contains('/foundation/ui/'));
}

bool isScreenFile(RuleContext context) {
  final path = currentFilePath(context);
  return path != null &&
      path.contains('/src/ui/') &&
      path.endsWith('_screen.dart');
}

String constructorTypeName(InstanceCreationExpression node) =>
    node.constructorName.type.name.lexeme;

bool isInsideNamedClass(AstNode node, String name) {
  final declaration = enclosingClass(node);
  return declaration != null && className(declaration) == name;
}

bool importsPackage(RuleContext context, String packageName) =>
    context.definingUnit.unit.directives.whereType<ImportDirective>().any(
      (directive) =>
          directive.uri.stringValue?.startsWith('package:$packageName/') ??
          false,
    );
