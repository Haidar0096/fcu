import 'package:flutter/widgets.dart';

import 'spacing.dart';

/// Builds directional gaps from the fixed spacing scale.
abstract final class Spacing {
  static Widget vertical(SpacingSize size) => SizedBox(height: size.value);

  static Widget horizontal(SpacingSize size) => SizedBox(width: size.value);
}
