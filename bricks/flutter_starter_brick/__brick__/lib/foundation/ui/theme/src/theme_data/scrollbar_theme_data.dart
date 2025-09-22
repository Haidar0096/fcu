import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/defaults.dart';

ScrollbarThemeData scrollbarThemeData(ColorScheme colorScheme) =>
    ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(
        colorScheme.primary.withValues(alpha: 0.8),
      ),
      thickness: const WidgetStatePropertyAll(ThemeDefaults.scrollbarThickness),
      radius: const Radius.circular(ThemeDefaults.borderRadiusExtraLarge),
    );
