import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/l10n/l10n.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

/// Generic status banner widget for displaying consistent status messages
/// across the application.
///
/// Supports different types: loading, success, error with appropriate colors,
/// icons, and optional action buttons. Can be used for any feature that needs
/// to display status feedback to users.
class StatusBannerWidget extends StatelessWidget {
  const StatusBannerWidget({
    required this.type,
    required this.message,
    this.onAction,
    this.actionText,
    super.key,
  });

  final StatusBannerType type;
  final String message;
  final VoidCallback? onAction;
  final String? actionText;

  @override
  Widget build(BuildContext context) {
    final colors = _getBannerColors(context);
    final icon = _getBannerIcon();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: StatusBannerDefaults.horizontalMargin,
        vertical: StatusBannerDefaults.verticalMargin,
      ),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(ThemeDefaults.cardBorderRadius),
        border: Border.all(color: colors.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.themeData.colorScheme.onSurface.withValues(
              alpha: StatusBannerDefaults.shadowOpacity,
            ),
            blurRadius: StatusBannerDefaults.shadowBlurRadius,
            offset: const Offset(0, StatusBannerDefaults.shadowOffsetY),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(StatusBannerDefaults.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content row
            Row(
              children: [
                // Icon or loading indicator
                if (type == StatusBannerType.loading)
                  SizedBox(
                    width: StatusBannerDefaults.iconSize,
                    height: StatusBannerDefaults.iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: StatusBannerDefaults.loadingStrokeWidth,
                      color: colors.iconColor,
                    ),
                  )
                else
                  Icon(
                    icon,
                    color: colors.iconColor,
                    size: StatusBannerDefaults.iconSize,
                  ),
                const Spacing.horizontal(SpacingSize.small),
                // Message text
                Expanded(
                  child: Text(
                    message,
                    style: context.typography?.body6.copyWith(
                      color: colors.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            // Action button for interactive banners
            if (onAction != null) ...[
              const Spacing.vertical(SpacingSize.small),
              SizedBox(
                width: double.infinity,
                child: MainButton(
                  text: (actionText ?? context.appLocalizations.retry)
                      .toUpperCase(),
                  onPressed: onAction,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Gets the appropriate colors for the banner type.
  _BannerColors _getBannerColors(BuildContext context) {
    final colorScheme = context.themeData.colorScheme;

    switch (type) {
      case StatusBannerType.loading:
        return _BannerColors(
          backgroundColor: colorScheme.primaryContainer,
          borderColor: colorScheme.primary.withValues(alpha: StatusBannerDefaults.borderOpacity),
          iconColor: colorScheme.primary,
          textColor: colorScheme.onPrimaryContainer,
        );
      case StatusBannerType.success:
        return _BannerColors(
          backgroundColor: colorScheme.primaryContainer,
          borderColor: colorScheme.primary.withValues(alpha: StatusBannerDefaults.borderOpacity),
          iconColor: colorScheme.primary,
          textColor: colorScheme.onPrimaryContainer,
        );
      case StatusBannerType.error:
        return _BannerColors(
          backgroundColor: colorScheme.errorContainer,
          borderColor: colorScheme.error.withValues(alpha: StatusBannerDefaults.borderOpacity),
          iconColor: colorScheme.error,
          textColor: colorScheme.onErrorContainer,
        );
      case StatusBannerType.warning:
        return _BannerColors(
          backgroundColor: colorScheme.tertiaryContainer,
          borderColor: colorScheme.tertiary.withValues(alpha: StatusBannerDefaults.borderOpacity),
          iconColor: colorScheme.tertiary,
          textColor: colorScheme.onTertiaryContainer,
        );
      case StatusBannerType.info:
        return _BannerColors(
          backgroundColor: colorScheme.surfaceContainerHighest,
          borderColor: colorScheme.outline.withValues(alpha: StatusBannerDefaults.borderOpacity),
          iconColor: colorScheme.onSurface,
          textColor: colorScheme.onSurface,
        );
    }
  }

  /// Gets the appropriate icon for the banner type.
  IconData _getBannerIcon() {
    switch (type) {
      case StatusBannerType.loading:
        return Icons.info_outline; // Won't be used, loading shows spinner
      case StatusBannerType.success:
        return Icons.check_circle_outline;
      case StatusBannerType.error:
        return Icons.error_outline;
      case StatusBannerType.warning:
        return Icons.warning_outlined;
      case StatusBannerType.info:
        return Icons.info_outline;
    }
  }
}

/// Types of status banners with different visual treatments.
enum StatusBannerType {
  loading,
  success,
  error,
  warning,
  info,
}

/// Internal class to hold banner color configuration.
class _BannerColors {
  const _BannerColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
}

class StatusBannerDefaults {
  static const double horizontalMargin = 4;
  static const double verticalMargin = 8;
  static const double padding = 16;
  static const double iconSize = 18;
  static const double loadingStrokeWidth = 2;
  static const double shadowOpacity = 0.08;
  static const double shadowBlurRadius = 8;
  static const double shadowOffsetY = 2;
  static const double borderOpacity = 0.3;
}
