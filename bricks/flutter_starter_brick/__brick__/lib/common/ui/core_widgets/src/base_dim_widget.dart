import 'package:flutter/material.dart';
import 'package:{{proj_name}}/common/ui/theme/theme.dart';

/// A widget that applies a dimming effect to its child widget.
///
/// The [BaseDimWidget] overlays a color on its child, which can be toggled
/// using the [applyDim] property. The dimming color can be customized with
/// [dimColor] property. If not provided, a default color from the app's theme
/// is used.
class BaseDimWidget extends StatelessWidget {
  /// Creates a [BaseDimWidget].
  ///
  /// The [child] parameter must not be null.
  const BaseDimWidget({
    required this.child,
    super.key,
    this.applyDim = true,
    this.dimColor,
    this.opacity = _defaultScrimOpacity,
  });

  /// The default scrim opacity as per Material 3 guidelines.
  static const _defaultScrimOpacity = 0.32;

  /// The opacity of the dim effect.
  ///
  /// Defaults to 0.32 as per Material 3 guidelines.
  final double opacity;

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
    final effectiveDimColor =
        dimColor ?? context.themeData.colorScheme.scrim.withOpacity(opacity);
    return ColoredBox(
      color: applyDim ? effectiveDimColor : Colors.transparent,
      child: child,
    );
  }
}
