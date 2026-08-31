import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/animations/animations.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

/// State that handles the validation of a widget.
/// - V is the type of the values that can be validated.
/// - W is the type of the stateful widget that will use this mixin.
mixin ValidateableStateMixin<W extends StatefulWidget, V>
    on TickerProviderStateMixin<W> {
  /// An animation controller that can be used to animate the widget
  /// between valid/invalid states when a validation error occurs.
  @protected
  late final AnimationController animationController;

  /// The current validation error message. If there is no validation error,
  /// it will be null.
  @protected
  String? errorMessage;

  /// Whether the widget currently has a validation error.
  @protected
  bool get hasError => errorMessage != null;

  /// Whether validation has been triggered at least once.
  /// Used to determine if auto-validation should occur on value changes.
  @protected
  bool hasValidatedOnce = false;

  /// The validator to be used to validate the values of the widget.
  @protected
  String? Function(V?)? get validator;

  /// The current value that would be validated if the widget is validated
  /// now.
  @protected
  V? get currentValue;

  /// Whether to show the error message in the default error widgets.
  @protected
  bool get showErrorMessage;

  /// List of default animated widgets to show in case there is an error.
  /// This list will be shown if [showErrorMessage] is true.
  /// So it is safe to put it in a column with the validated widget.
  @protected
  List<Widget> get errorWidgets => [
    if (showErrorMessage) ...[
      SizeTransition(
        sizeFactor: animationController,
        child: Spacing.vertical(SpacingSize.spacing4),
      ),
      SizeTransition(
        sizeFactor: animationController,
        child: AnimatedOpacity(
          duration: animationController.duration!,
          opacity: hasError ? 1 : 0,
          child: Text(
            errorMessage ?? '',
            style: context.typography?.errorText.copyWith(
              color: context.themeData.colorScheme.error,
            ),
            maxLines: ValidateableStateMixinDefaults.errorMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ],
  ];

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: AnimationDefaults.animationDuration,
      reverseDuration: AnimationDefaults.animationDuration,
    );
    animationController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  /// A function that validates the state of the widget and returns true
  /// if it is valid, or false otherwise.
  bool validate() {
    hasValidatedOnce = true;
    final validatorFunction = validator;
    if (validatorFunction == null) {
      if (errorMessage != null) {
        setState(() {
          errorMessage = null;
        });
      }
      animationController.reverse();
      return true;
    }

    final validationMessage = validatorFunction(currentValue);

    // Only update state if the error message has changed
    if (errorMessage != validationMessage) {
      setState(() {
        errorMessage = validationMessage;
      });
    }

    if (hasError) {
      animationController.forward();
    } else {
      animationController.reverse();
    }

    return !hasError;
  }

  /// Internal validation method that only runs if validation has been
  /// triggered at least once.
  @protected
  void autoValidate() {
    if (hasValidatedOnce) {
      validate();
    }
  }
}

abstract final class ValidateableStateMixinDefaults {
  static const int errorMaxLines = 2;
}
