import 'package:flutter/material.dart';

ScrollbarThemeData scrollbarThemeData(ColorScheme colorScheme) =>
    ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(
        colorScheme.primary.withValues(alpha: 0.8),
      ),
      thickness: const WidgetStatePropertyAll(10),
      radius: const Radius.circular(20),
    );
