import 'package:flutter/material.dart';

/// Predefined spacing sizes for consistent UI spacing
enum SpacingSize {
  /// 4.0
  xxSmall(4),

  /// 8.0
  xSmall(8),

  /// 16.0
  small(16),

  /// 24.0
  medium(24),

  /// 32.0
  large(32),

  /// 40.0
  xLarge(40),

  /// 48.0
  xxLarge(48),

  /// 64.0
  xxxLarge(64);

  const SpacingSize(this.value);

  final double value;
}

/// A widget that provides consistent vertical or horizontal spacing
class Spacing extends StatelessWidget {
  const Spacing.vertical(this.size, {super.key}) : _isVertical = true;

  const Spacing.horizontal(this.size, {super.key}) : _isVertical = false;

  final SpacingSize size;
  final bool _isVertical;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: _isVertical ? size.value : null,
    width: _isVertical ? null : size.value,
  );
}

/// Convenience widgets for common spacing sizes
class VerticalSpacing {
  static const xxSmall = Spacing.vertical(SpacingSize.xxSmall);
  static const xSmall = Spacing.vertical(SpacingSize.xSmall);
  static const small = Spacing.vertical(SpacingSize.small);
  static const medium = Spacing.vertical(SpacingSize.medium);
  static const large = Spacing.vertical(SpacingSize.large);
  static const xLarge = Spacing.vertical(SpacingSize.xLarge);
  static const xxLarge = Spacing.vertical(SpacingSize.xxLarge);
  static const xxxLarge = Spacing.vertical(SpacingSize.xxxLarge);
}

class HorizontalSpacing {
  static const xxSmall = Spacing.horizontal(SpacingSize.xxSmall);
  static const xSmall = Spacing.horizontal(SpacingSize.xSmall);
  static const small = Spacing.horizontal(SpacingSize.small);
  static const medium = Spacing.horizontal(SpacingSize.medium);
  static const large = Spacing.horizontal(SpacingSize.large);
  static const xLarge = Spacing.horizontal(SpacingSize.xLarge);
  static const xxLarge = Spacing.horizontal(SpacingSize.xxLarge);
  static const xxxLarge = Spacing.horizontal(SpacingSize.xxxLarge);
}
