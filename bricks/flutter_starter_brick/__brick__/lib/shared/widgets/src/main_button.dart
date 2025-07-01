import 'package:{{proj_name}}/infrastructure/ui/theme/theme.dart';
import 'package:{{proj_name}}/infrastructure/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

class MainButton extends StatelessWidget {
  const MainButton({
    required this.text,
    required this.onPressed,
    this.height,
    this.width,
    super.key,
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
          return colorScheme.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.38);
          }
          return colorScheme.onPrimary;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return null;
          return colorScheme.onPrimary.withValues(alpha: 0.12);
        }),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ThemeDefaults.buttonBorderRadius,
            ),
            side: BorderSide.none,
          ),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
