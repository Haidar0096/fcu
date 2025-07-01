import 'package:{{proj_name}}/infrastructure/ui/theme/theme.dart';
import 'package:{{proj_name}}/infrastructure/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.width,
    this.height,
  });

  final String text;

  final VoidCallback? onPressed;

  bool get _enabled => onPressed != null;

  /// The width of the button.
  final double? width;

  /// The height of the button.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.themeData.colorScheme;
    return CustomElevatedButton(
      text: text,
      width: width,
      height: height,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.12);
          }
          return Colors.transparent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.38);
          }
          return colorScheme.primary;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return null;
          return colorScheme.primary.withValues(alpha: 0.12);
        }),
        shape: WidgetStateProperty.resolveWith((states) {
          final borderSide = BorderSide(
            color:
                states.contains(WidgetState.disabled)
                    ? colorScheme.onSurface.withValues(alpha: 0.12)
                    : colorScheme.primary,
            width: ThemeDefaults.borderWidth,
          );
          return RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ThemeDefaults.buttonBorderRadius,
            ),
            side: borderSide,
          );
        }),
      ),
      onPressed: onPressed,
    );
  }
}
