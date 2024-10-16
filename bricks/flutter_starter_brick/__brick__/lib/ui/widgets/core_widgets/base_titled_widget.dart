import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:flutter/material.dart';

/// A widget that displays a title, an optional subtitle, and a child widget.
class BaseTitledWidget extends StatelessWidget {
  /// Creates a [BaseTitledWidget].
  ///
  /// Either [titleText] or [titleWidget] must be provided, but not both.
  /// Similarly, only one of [subtitleText] or [subtitleWidget] can be provided.
  const BaseTitledWidget({
    required this.child,
    super.key,
    this.titleText,
    this.titleWidget,
    this.subtitleText,
    this.subtitleWidget,
    this.titleStyle,
    this.titlesChildSectionsSpacing,
    this.titleSubtitleSpacing,
  })  : assert(
          titleText != null || titleWidget != null,
          'Either titleText or titleWidget must be provided',
        ),
        assert(
          titleText == null || titleWidget == null,
          'Only one of titleText or titleWidget can be provided',
        ),
        assert(
          subtitleText == null || subtitleWidget == null,
          'Only one of subtitleText or subtitleWidget can be provided',
        );

  /// The text to be displayed as the title.
  final String? titleText;

  /// A custom widget to be used as the title.
  final Widget? titleWidget;

  /// The text to be displayed as the subtitle.
  final String? subtitleText;

  /// A custom widget to be used as the subtitle.
  final Widget? subtitleWidget;

  /// The style to be applied to the title text.
  final TextStyle? titleStyle;

  /// The spacing between the titles section and the child section.
  final double? titlesChildSectionsSpacing;

  /// The main content of the widget.
  final Widget child;

  /// The spacing between the title and the subtitle.
  final double? titleSubtitleSpacing;

  /// Default spacing between the titles section and the child section.
  static const double _defaultTitlesChildSectionsSpacing = 30;

  /// Default spacing between the title and the subtitle.
  static const double _defaultTitleSubtitleSpacing = 5;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTitle(context),
          if (subtitleText != null || subtitleWidget != null)
            SizedBox(
              height: titleSubtitleSpacing ?? _defaultTitleSubtitleSpacing,
            ),
          _buildSubtitle(context),
          SizedBox(
            height: titlesChildSectionsSpacing ??
                _defaultTitlesChildSectionsSpacing,
          ),
          Flexible(child: child),
        ],
      );

  Widget _buildTitle(BuildContext context) =>
      titleWidget ??
      (titleText != null
          ? Flexible(
              child: Text(
                titleText!,
                style: titleStyle ??
                    context.appTextTheme.body3.copyWith(
                      fontSize: 30,
                      color: AppColorsTheme.purple,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : const SizedBox.shrink());

  Widget _buildSubtitle(BuildContext context) =>
      subtitleWidget ??
      (subtitleText != null
          ? Flexible(
              child: Text(
                subtitleText!,
                style: context.appTextTheme.body3.copyWith(
                  fontSize: 24,
                  color: AppColorsTheme.purple,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : const SizedBox.shrink());
}
