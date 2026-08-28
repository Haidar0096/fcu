import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

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
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = context.themeData.elevatedButtonTheme.style;
    return CustomElevatedButton(
      text: text,
      width: width,
      height: height,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return context.themeData.colorScheme.surfaceContainerHighest;
          }
          return context.themeData.colorScheme.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return theme?.foregroundColor?.resolve(states);
          }
          return context.themeData.colorScheme.onPrimary;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return null;
          return context.themeData.colorScheme.onPrimary.withValues(
            alpha: ThemeDefaults.overlayAlpha,
          );
        }),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ThemeDefaults.buttonBorderRadius,
            ),
            side: const BorderSide(
              color: Colors.transparent,
              width: ThemeDefaults.borderWidth,
            ),
          ),
        ),
        textStyle: theme?.textStyle,
      ),
      onPressed: onPressed,
    );
  }
}
