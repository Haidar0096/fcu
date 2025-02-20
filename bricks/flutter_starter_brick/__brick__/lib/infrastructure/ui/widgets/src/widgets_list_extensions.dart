import 'package:flutter/material.dart';

extension WidgetsIterableExtensions<T extends Widget> on Iterable<T> {
  /// Returns the list of widgets with each widget wrapped in a [Padding] widget
  /// with the given [padding].
  List<Widget> withPadding(EdgeInsetsGeometry padding) =>
      map((e) => Padding(padding: padding, child: e)).toList();

  /// Returns the list of widgets with each widget wrapped in a [Flexible]
  /// widget.
  List<Widget> wrappedWithFlexible() => map((e) => Flexible(child: e)).toList();
}

extension WidgetsListExtensions<T extends Widget> on List<T> {
  /// Returns the list of widgets with each widget wrapped in a [Padding] widget
  /// with the given [padding].
  List<Widget> withPadding(EdgeInsetsGeometry padding) =>
      map((e) => Padding(padding: padding, child: e)).toList();

  /// Returns the list of widgets with each widget wrapped in a [Flexible]
  /// widget.
  List<Widget> wrappedWithFlexible() => map((e) => Flexible(child: e)).toList();

  /// Returns the list of widgets with [Divider]s added between the widgets.
  /// - [applyDividerBeforeFirstChild]: if true, adds a [Divider] before the
  /// first widget.
  /// - [applyDividerAfterLastChild]: if true, adds a [Divider] after the last
  /// widget.
  /// - [divider]: optional divider to apply. If null, a default [Divider] will
  /// be used.
  List<Widget> withDividers({
    bool applyDividerBeforeFirstChild = true,
    bool applyDividerAfterLastChild = true,
    Widget? divider,
  }) {
    if (isEmpty) return [];
    final effectiveDivider = divider ?? const Divider();
    final result = <Widget>[];
    if (applyDividerBeforeFirstChild) {
      result.add(effectiveDivider);
    }
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i != length - 1 || applyDividerAfterLastChild) {
        result.add(effectiveDivider);
      }
    }
    return result;
  }
}
