class ThemeDefaults {
  static const double borderWidth = 1.3;
  static const double buttonHeight = 50;
  static const double buttonWidth = 100;
  static const double buttonMaxWidth = 400;

  // Border radius values for consistent design system
  // Using a geometric scale that provides good visual hierarchy
  static const double borderRadiusXSmall = 2;
  static const double borderRadiusSmall = 8;
  static const double borderRadiusExtraLarge = 20;

  // Semantic border radius values for specific use cases
  static const double buttonBorderRadius = borderRadiusSmall; // 8
  static const double cardBorderRadius = 12; // Direct value since borderRadiusMedium was unused
  static const double bottomSheetBorderRadius = borderRadiusExtraLarge; // 20

  // Icon button defaults
  static const double iconSize = 24;
  static const double iconButtonSize = 48;

  // Screen content padding defaults
  static const double screenContentHorizontalPadding = 24;

  // Opacity values
  static const int disabledAlpha = 102; // ~0.4 opacity for custom widgets
  static const double buttonDisabledOverlayAlpha = 0.12; // Disabled/overlay opacity for buttons
  static const double materialDisabledOpacity = 0.38; // Material Design standard for disabled states
  static const double textFieldEnabledBorderOpacity = 0.2; // Subtle border for enabled text fields

  // Text size defaults
  static const double buttonTextSize = 16; // Standard button text size
  static const double dropdownTextSize = 18; // Dropdown menu text size

  // Component-specific defaults
  static const double scrollbarThickness = 10; // Scrollbar thumb thickness
  static const double scrollbarThumbOpacity = 0.8; // Scrollbar thumb opacity for subtle appearance
  static const double checkboxBorderWidth = 1.5; // Checkbox border width (slightly thicker for visibility)
}
