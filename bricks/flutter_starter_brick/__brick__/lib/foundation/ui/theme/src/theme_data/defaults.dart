abstract final class ThemeDefaults {
  static const double borderWidth = 1.3;
  static const double buttonHeight = 50;
  static const double buttonWidth = 100;
  static const double buttonMaxWidth = 400;

  // Border radius values for consistent design system
  // Using a geometric scale that provides good visual hierarchy
  static const double borderRadiusXSmall = 2;
  static const double borderRadiusSmall = 8;
  static const double borderRadiusMedium = 12;
  static const double borderRadiusExtraLarge = 20;

  // Semantic border radius values for specific use cases
  static const double buttonBorderRadius = borderRadiusSmall; // 8
  static const double cardBorderRadius = borderRadiusMedium; // 12
  static const double bottomSheetBorderRadius = borderRadiusExtraLarge; // 20

  // Icon button defaults
  static const double iconSize = 24;
  static const double smallIconSize = 20;
  static const double iconButtonSize = 48;
  static const double smallIconButtonSize = 40;

  // The one screen-edge gutter, applied on every edge.
  static const double screenContentPadding = 24;

  // Opacity values
  static const double buttonDisabledOverlayAlpha =
      0.12; // Disabled/overlay opacity for buttons
  static const double materialDisabledOpacity =
      0.38; // Material Design standard for disabled states
  static const double textFieldEnabledBorderOpacity =
      0.2; // Subtle border for enabled text fields
  static const double textSelectionOpacity =
      0.4; // Text selection highlight opacity
  static const double scrimOpacity = 0.32; // Modal scrim/overlay opacity
  static const double borderAlpha = 0.3; // For subtle borders
  static const double shadowAlpha = 0.08; // For subtle box shadows

  // Text size defaults
  static const double titleTextSize = 24; // Screen and section titles
  static const double linkTextSize = 16; // Link text
  static const double bodyTextSize = 14; // Body, field input and error text
  static const double smallTextSize = 12; // Hints, labels and small links
  static const double buttonTextSize = 16; // Standard button text size
  static const double dropdownTextSize = 18; // Dropdown menu text size
  static const double bodyTextHeight = 1.5; // Line height for flowing body text

  // Component-specific defaults
  static const double scrollbarThickness = 10; // Scrollbar thumb thickness
  static const double scrollbarThumbOpacity =
      0.8; // Scrollbar thumb opacity for subtle appearance
  static const double checkboxBorderWidth =
      1.5; // Checkbox border width (slightly thicker for visibility)
}
