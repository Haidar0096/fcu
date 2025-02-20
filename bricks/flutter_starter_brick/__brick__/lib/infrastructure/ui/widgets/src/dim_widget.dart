import 'package:{{proj_name}}/infrastructure/ui/theme/theme.dart';
import 'package:flutter/material.dart';

/// A widget that applies a dimming effect to its child widget.
///
/// The [DimWidget] overlays a color on its child, which can be toggled
/// using the [applyDim] property. The dimming color can be customized with
/// [dimColor] property. If not provided, a default color from the app's theme
/// is used.
class DimWidget extends StatelessWidget {
  /// Creates a [DimWidget].
  ///
  /// The [child] parameter must not be null.
  const DimWidget({
    required this.child,
    super.key,
    this.applyDim = true,
    this.dimColor,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// Whether to apply the dimming effect.
  ///
  /// If true, the [dimColor] or a default color will overlay the [child].
  /// If false, the [child] is displayed without dimming.
  final bool applyDim;

  /// The color to use for the dimming effect.
  ///
  /// If null, a default color from the app's theme will be used.
  final Color? dimColor;

  @override
  Widget build(BuildContext context) {
    final effectiveDimColor = dimColor ?? context.themeData.defaultScrim;
    return ColoredBox(
      color: applyDim ? effectiveDimColor : Colors.transparent,
      child: child,
    );
  }
}
