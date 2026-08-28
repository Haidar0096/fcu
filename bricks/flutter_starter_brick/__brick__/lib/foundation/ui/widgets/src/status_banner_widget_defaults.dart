import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';

import 'spacing.dart';

/// Design values owned by the status banner.
abstract final class StatusBannerWidgetDefaults {
  /// The banner's glyph, a touch under the shared small icon so it sits
  /// inside the message's own line rather than towering over it.
  static const double iconSize = ThemeDefaults.smallIconSize - 2;

  /// The spinner's stroke at [iconSize] — any thicker and the ring closes up.
  static const double spinnerStrokeWidth = 2;

  /// Keeps the dismiss glyph below the shared small-icon size.
  static double get dismissIconSize =>
      ThemeDefaults.smallIconSize - SpacingSize.spacing4.value;

  /// Half the smallest spacing step, so the shadow reads as a lift rather
  /// than a second edge under the banner.
  static double get shadowOffsetY => SpacingSize.spacing4.value / 2;
}
