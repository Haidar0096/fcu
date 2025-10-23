import 'package:flutter/material.dart';

/// Predefined spacing sizes for consistent UI spacing (4-unit steps)
enum SpacingSize {
  /// 4.0
  xxSmall(4),

  /// 8.0
  xSmall(8),

  /// 12.0
  spacing12(12),

  /// 16.0
  small(16),

  /// 20.0
  spacing20(20),

  /// 24.0
  medium(24),

  /// 28.0
  spacing28(28),

  /// 32.0
  large(32),

  /// 36.0
  spacing36(36),

  /// 40.0
  xLarge(40),

  /// 44.0
  spacing44(44),

  /// 48.0
  xxLarge(48),

  /// 52.0
  spacing52(52),

  /// 56.0
  spacing56(56),

  /// 60.0
  spacing60(60),

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
  static const spacing12 = Spacing.vertical(SpacingSize.spacing12);
  static const small = Spacing.vertical(SpacingSize.small);
  static const spacing20 = Spacing.vertical(SpacingSize.spacing20);
  static const medium = Spacing.vertical(SpacingSize.medium);
  static const spacing28 = Spacing.vertical(SpacingSize.spacing28);
  static const large = Spacing.vertical(SpacingSize.large);
  static const spacing36 = Spacing.vertical(SpacingSize.spacing36);
  static const xLarge = Spacing.vertical(SpacingSize.xLarge);
  static const spacing44 = Spacing.vertical(SpacingSize.spacing44);
  static const xxLarge = Spacing.vertical(SpacingSize.xxLarge);
  static const spacing52 = Spacing.vertical(SpacingSize.spacing52);
  static const spacing56 = Spacing.vertical(SpacingSize.spacing56);
  static const spacing60 = Spacing.vertical(SpacingSize.spacing60);
  static const xxxLarge = Spacing.vertical(SpacingSize.xxxLarge);
}

class HorizontalSpacing {
  static const xxSmall = Spacing.horizontal(SpacingSize.xxSmall);
  static const xSmall = Spacing.horizontal(SpacingSize.xSmall);
  static const spacing12 = Spacing.horizontal(SpacingSize.spacing12);
  static const small = Spacing.horizontal(SpacingSize.small);
  static const spacing20 = Spacing.horizontal(SpacingSize.spacing20);
  static const medium = Spacing.horizontal(SpacingSize.medium);
  static const spacing28 = Spacing.horizontal(SpacingSize.spacing28);
  static const large = Spacing.horizontal(SpacingSize.large);
  static const spacing36 = Spacing.horizontal(SpacingSize.spacing36);
  static const xLarge = Spacing.horizontal(SpacingSize.xLarge);
  static const spacing44 = Spacing.horizontal(SpacingSize.spacing44);
  static const xxLarge = Spacing.horizontal(SpacingSize.xxLarge);
  static const spacing52 = Spacing.horizontal(SpacingSize.spacing52);
  static const spacing56 = Spacing.horizontal(SpacingSize.spacing56);
  static const spacing60 = Spacing.horizontal(SpacingSize.spacing60);
  static const xxxLarge = Spacing.horizontal(SpacingSize.xxxLarge);
}
