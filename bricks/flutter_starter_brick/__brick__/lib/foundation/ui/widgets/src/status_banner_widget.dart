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
    this.onDismiss,
    super.key,
  });

  final StatusBannerType type;
  final String message;
  final VoidCallback? onAction;
  final String? actionText;

  /// Optional dismiss callback - shows an X button in top-right corner
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = _getBannerColors(context);
    final icon = _getBannerIcon();

    final banner = Container(
      margin: EdgeInsets.symmetric(
        horizontal: SpacingSize.xxSmall.value,
        vertical: SpacingSize.xSmall.value,
      ),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(ThemeDefaults.cardBorderRadius),
        border: Border.all(color: colors.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.themeData.colorScheme.onSurface.withValues(
              alpha: ThemeDefaults.shadowAlpha,
            ),
            blurRadius: SpacingSize.xSmall.value,
            offset: Offset(0, SpacingSize.xxSmall.value / 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(SpacingSize.small.value),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main content row
                Row(
                  children: [
                    // Icon or loading indicator
                    if (type == StatusBannerType.loading)
                      SizedBox(
                        width: ThemeDefaults.smallIconSize - 2,
                        height: ThemeDefaults.smallIconSize - 2,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.iconColor,
                        ),
                      )
                    else
                      Icon(
                        icon,
                        color: colors.iconColor,
                        size: ThemeDefaults.smallIconSize - 2,
                      ),
                    const Spacing.horizontal(SpacingSize.small),
                    // Message text
                    Expanded(
                      child: Text(
                        message,
                        style: context.typography?.mediumBodyText.copyWith(
                          color: colors.textColor,
                        ),
                      ),
                    ),
                    // Add padding if dismiss button is shown to prevent overlap
                    if (onDismiss != null)
                      SizedBox(width: SpacingSize.medium.value),
                  ],
                ),
                // Action button for interactive banners
                if (onAction != null) ...[
                  const Spacing.vertical(SpacingSize.small),
                  SizedBox(
                    width: double.infinity,
                    child: MainButton(
                      text:
                          (actionText ?? context.appLocalizations.retry)
                              .toUpperCase(),
                      onPressed: onAction,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Dismiss button
          if (onDismiss != null)
            Positioned(
              top: 0,
              right: SpacingSize.xSmall.value,
              bottom: 0,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onDismiss,
                    borderRadius: BorderRadius.circular(
                      ThemeDefaults.cardBorderRadius,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(SpacingSize.xxSmall.value),
                      child: Icon(
                        Icons.close,
                        size: SpacingSize.small.value,
                        color: colors.textColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    // Constrain the maximum width to prevent the banner from
    // stretching too wide on large screens
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: ThemeDefaults.buttonMaxWidth,
        ),
        child: banner,
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
          borderColor: colorScheme.primary.withValues(
            alpha: ThemeDefaults.borderAlpha,
          ),
          iconColor: colorScheme.primary,
          textColor: colorScheme.onPrimaryContainer,
        );
      case StatusBannerType.success:
        return _BannerColors(
          backgroundColor: colorScheme.primaryContainer,
          borderColor: colorScheme.primary.withValues(
            alpha: ThemeDefaults.borderAlpha,
          ),
          iconColor: colorScheme.primary,
          textColor: colorScheme.onPrimaryContainer,
        );
      case StatusBannerType.error:
        return _BannerColors(
          backgroundColor: colorScheme.errorContainer,
          borderColor: colorScheme.error.withValues(
            alpha: ThemeDefaults.borderAlpha,
          ),
          iconColor: colorScheme.error,
          textColor: colorScheme.onErrorContainer,
        );
      case StatusBannerType.warning:
        return _BannerColors(
          backgroundColor: colorScheme.tertiaryContainer,
          borderColor: colorScheme.tertiary.withValues(
            alpha: ThemeDefaults.borderAlpha,
          ),
          iconColor: colorScheme.tertiary,
          textColor: colorScheme.onTertiaryContainer,
        );
      case StatusBannerType.info:
        return _BannerColors(
          backgroundColor: colorScheme.surfaceContainerHighest,
          borderColor: colorScheme.outline.withValues(
            alpha: ThemeDefaults.borderAlpha,
          ),
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
enum StatusBannerType { loading, success, error, warning, info }

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
