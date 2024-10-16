import 'package:{{proj_name}}/ui/widgets/core_widgets/base_dropdown_button.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/base_titled_widget.dart';
import 'package:flutter/material.dart';

/// A customizable dropdown button with a title.
///
/// This widget combines a title and a dropdown button, allowing for
/// a more structured UI element. It supports various customization
/// options for the title and dropdown behavior.
class BaseTitledDropdownButton<T> extends StatelessWidget {
  const BaseTitledDropdownButton({
    required this.items,
    required this.itemBuilder,
    super.key,
    this.titleText,
    this.titleWidget,
    this.titleStyle,
    this.value,
    this.onChanged,
    this.hintText,
    this.hintTextStyle,
    this.width,
    this.height,
    this.hintMaxLines,
    this.hintOverflow,
    this.isExpanded,
    this.titleWidgetSectionsSpacing,
    this.validator,
    this.autoValidateMode,
  });

  /// The text to display as the title.
  final String? titleText;

  /// A custom widget to display as the title.
  final Widget? titleWidget;

  /// The style to apply to the title text.
  final TextStyle? titleStyle;

  /// The currently selected value.
  final T? value;

  /// The list of items to display in the dropdown.
  final List<T> items;

  /// A builder function to create the dropdown items.
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Callback function triggered when the selected value changes.
  final void Function(T? newValue)? onChanged;

  /// The hint text to display when no value is selected.
  final String? hintText;

  /// The style to apply to the hint text.
  final TextStyle? hintTextStyle;

  /// The width of the dropdown button.
  final double? width;

  /// The height of the dropdown button.
  final double? height;

  /// The maximum number of lines for the hint text.
  final int? hintMaxLines;

  /// The overflow behavior for the hint text.
  final TextOverflow? hintOverflow;

  /// Whether the dropdown should expand to fill available space.
  final bool? isExpanded;

  /// The spacing between the title widget and its sections.
  final double? titleWidgetSectionsSpacing;

  /// A validation function for the dropdown value.
  final String? Function(T?)? validator;

  /// The mode for automatic validation.
  final AutovalidateMode? autoValidateMode;

  @override
  Widget build(BuildContext context) => BaseTitledWidget(
        titleText: titleText,
        titleWidget: titleWidget,
        titleStyle: titleStyle,
        titlesChildSectionsSpacing: titleWidgetSectionsSpacing,
        child: BaseDropdownButton(
          items: items,
          itemBuilder: itemBuilder,
          onChanged: onChanged,
          value: value,
          width: width,
          height: height,
          hintMaxLines: hintMaxLines,
          hintOverflow: hintOverflow,
          hintText: hintText,
          hintTextStyle: hintTextStyle,
          isExpanded: isExpanded,
          validator: validator,
          autoValidateMode: autoValidateMode,
        ),
      );
}
