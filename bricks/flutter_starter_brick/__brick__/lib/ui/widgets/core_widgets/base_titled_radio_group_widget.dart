import 'package:{{proj_name}}/ui/widgets/core_widgets/base_radio_button.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/base_titled_widget.dart';
import 'package:flutter/material.dart';

/// A widget that displays a titled group of radio buttons.
///
/// Combines a title with a group of radio buttons for easy selection.
@immutable
class BaseTitledRadioGroupWidget<T> extends StatelessWidget {
  /// Creates a [BaseTitledRadioGroupWidget].
  ///
  /// The [radioButtons] parameter must not be null.
  const BaseTitledRadioGroupWidget({
    required this.radioButtons,
    super.key,
    this.titleText,
    this.titleStyle,
    this.titleWidget,
    this.titleWidgetSectionsSpacing,
  });

  /// The list of radio buttons to display.
  final List<BaseRadioButton<T>> radioButtons;

  /// The text to display as the title.
  final String? titleText;

  /// The style to apply to the title text.
  final TextStyle? titleStyle;

  /// A custom widget to display as the title.
  final Widget? titleWidget;

  /// The spacing between the title and the radio buttons.
  final double? titleWidgetSectionsSpacing;

  @override
  Widget build(BuildContext context) => BaseTitledWidget(
        titleText: titleText,
        titleStyle: titleStyle,
        titleWidget: titleWidget,
        titlesChildSectionsSpacing: titleWidgetSectionsSpacing,
        child: Wrap(
          runSpacing: 5,
          children: radioButtons,
        ),
      );
}
