import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
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
    final theme = context.themeData.outlinedButtonTheme.style;
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: width != null ? Size(width!, 0) : null,
        maximumSize: width != null ? Size(width!, double.infinity) : null,
        foregroundColor: onPressed != null
            ? context.themeData.colorScheme.primary
            : theme?.foregroundColor?.resolve({WidgetState.disabled}),
        textStyle: theme?.textStyle?.resolve({}),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );

    if (height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }

    return button;
  }
}
