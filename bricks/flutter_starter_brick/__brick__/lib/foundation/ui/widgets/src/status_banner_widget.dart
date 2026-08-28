import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/l10n/l10n.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

/// The app's ONE banner view, in every status it can take.
///
/// It is not a second banner beside the sliding one: the transient banner
/// road (`context.showErrorBanner` and its siblings) renders THIS widget
/// inside its overlay — see `sliding_banner.dart`. Rendering it directly, as
/// a feature does for a failure that has to stay on the screen instead of
/// sliding away, is the same widget used the other legal way.
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

  /// Optional dismiss callback - shows an X button at the trailing edge
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = _getBannerColors(context);
    final icon = _getBannerIcon();

    final banner = Container(
      margin: EdgeInsets.symmetric(
        horizontal: SpacingSize.spacing4.value,
        vertical: SpacingSize.spacing8.value,
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
            blurRadius: SpacingSize.spacing8.value,
            offset: Offset(0, StatusBannerWidgetDefaults.shadowOffsetY),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(SpacingSize.spacing16.value),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (type == StatusBannerType.loading)
                      SizedBox(
                        width: StatusBannerWidgetDefaults.iconSize,
                        height: StatusBannerWidgetDefaults.iconSize,
                        child: CircularProgressIndicator(
                          strokeWidth:
                              StatusBannerWidgetDefaults.spinnerStrokeWidth,
                          color: colors.iconColor,
                        ),
                      )
                    else
                      Icon(
                        icon,
                        color: colors.iconColor,
                        size: StatusBannerWidgetDefaults.iconSize,
                      ),
                    Spacing.horizontal(SpacingSize.spacing16),
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
                      Spacing.horizontal(SpacingSize.spacing24),
                  ],
                ),
                // Action button for interactive banners
                if (onAction != null) ...[
                  Spacing.vertical(SpacingSize.spacing16),
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
          // Dismiss button. Directional, so it stays on the trailing edge in
          // a right-to-left language instead of jumping across the banner.
          if (onDismiss != null)
            PositionedDirectional(
              top: 0,
              end: SpacingSize.spacing8.value,
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
                      padding: EdgeInsets.all(SpacingSize.spacing4.value),
                      child: Icon(
                        Icons.close,
                        size: StatusBannerWidgetDefaults.dismissIconSize,
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
