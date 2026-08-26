import 'package:flutter/material.dart';

extension FocusBuildContextExtension on BuildContext {
  /// Unfocuses the currently focused widget.
  void unfocus() => FocusManager.instance.primaryFocus?.unfocus();
}
