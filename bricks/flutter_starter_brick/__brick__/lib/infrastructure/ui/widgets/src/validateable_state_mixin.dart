import 'package:{{proj_name}}/infrastructure/ui/animations/animations.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/theme.dart';
import 'package:flutter/material.dart';

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
        child: SizedBox(height: hasError ? 5 : 0),
      ),
      SizeTransition(
        sizeFactor: animationController,
        child: AnimatedOpacity(
          duration: animationController.duration!,
          opacity: hasError ? 1 : 0,
          child: Text(
            errorMessage ?? '',
            style: context.typography?.error.copyWith(fontSize: 14),
            maxLines: 2,
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
    final validatorFunction = validator;
    if (validatorFunction == null) return true;

    final validationMessage = validatorFunction(currentValue);

    errorMessage = validationMessage;
    if (hasError) {
      animationController.forward();
    } else {
      animationController.reverse();
    }

    return !hasError;
  }
}
