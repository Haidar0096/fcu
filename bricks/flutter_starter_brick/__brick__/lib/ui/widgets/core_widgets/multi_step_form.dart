import 'dart:collection';

import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:{{proj_name}}/l10n/l10n.dart';
import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/filled_button.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/shallow_button.dart';
import 'package:flutter/material.dart' hide FilledButton;

const Duration _crossFadeDuration = Duration(milliseconds: 300);
const double _defaultButtonWidth = double.infinity;
const double _defaultFormActionButtonsSpacing = 20;

/// A function that builds a widget for a step based on the given step value.
typedef StepWidgetBuilder<T> = Widget Function(
  BuildContext context,
  T stepValue,
);

/// Represents the data of a step, i.e. a widget and an optional value of type
/// [T].
final class StepData<T> {
  const StepData({
    required this.stepWidgetBuilder,
    required this.value,
  });

  final StepWidgetBuilder<T> stepWidgetBuilder;
  final T value;

  @override
  String toString() => 'StepData{widget: $stepWidgetBuilder, value: $value}';
}

/// A function that evaluates if an action should be done based on the given
/// step value.
typedef SingleStepActionEvaluator<T> = bool Function(T stepValue);

/// A function to be called to perform an action based on the given step value.
typedef SingleStepAction<T> = void Function(T stepValue);

/// A function that evaluates if an action should be done based on the given
/// values of two steps.
typedef TwoConsecutiveStepsActionEvaluator<T> = bool Function({
  required T currentStepValue,
  required T nextStepValue,
});

/// A function to be called to perform an action based on the given two
/// consecutive steps values.
typedef TwoConsecutiveStepsAction<T> = void Function({
  required T currentStepValue,
  required T nextStepValue,
});

bool _defaultIsButtonEnabled(_) => true;

/// A widget that represents a form with multiple steps to be completed.
///
/// This widget manages the navigation between steps, where each step is
/// represented by a [StepData] object containing a widget and an optional
/// value of type [T]. The value can be an enum representing the step or
/// simply an integer representing the step's index.
class MultiStepForm<T> extends StatefulWidget {
  MultiStepForm({
    required List<StepData<T>> steps,
    super.key,
    this.shouldChangeStep,
    this.onStepChanged,
    this.onFormSubmitted,
    this.onFormCancelled,
    this.initialStepIndex,
    this.submitButtonLabel,
    this.backButtonEnabled = _defaultIsButtonEnabled,
    this.nextButtonEnabled = _defaultIsButtonEnabled,
    this.backButtonBoxConstraints,
    this.cancelButtonBoxConstraints,
    this.nextButtonBoxConstraints,
    this.submitButtonBoxConstraints,
    this.formActionButtonsSpacing,
    this.contentButtonsSpacing,
  })  : assert(
          steps.isNotEmpty,
          'The steps list must not be empty.',
        ),
        assert(
          initialStepIndex == null ||
              (initialStepIndex >= 0 && initialStepIndex < steps.length),
          'The initial step index must be a valid index of the steps list.',
        ),
        steps = UnmodifiableListView(steps);

  /// The list of steps to be displayed in the form.
  final UnmodifiableListView<StepData<T>> steps;

  /// Called before changing the step to evaluate if the step change should be
  /// done. If this callback returns false, the step change will be cancelled.
  final TwoConsecutiveStepsActionEvaluator<T>? shouldChangeStep;

  /// Callback to be called after the current step changes and changing
  /// animation is completed.
  final void Function()? onStepChanged;

  /// Callback to be called when the form is submitted.
  final void Function()? onFormSubmitted;

  /// Callback to be called when the form is cancelled.
  final void Function()? onFormCancelled;

  /// The initial step index to display.
  final int? initialStepIndex;

  /// The label for the submit button.
  final String? submitButtonLabel;

  /// Whether the back button should be enabled based on the current step data.
  final SingleStepActionEvaluator<T> backButtonEnabled;

  /// Whether the next button should be enabled based on the current step data.
  final SingleStepActionEvaluator<T> nextButtonEnabled;

  /// Box constraints for the back button.
  final BoxConstraints? backButtonBoxConstraints;

  /// Box constraints for the cancel button.
  final BoxConstraints? cancelButtonBoxConstraints;

  /// Box constraints for the next button.
  final BoxConstraints? nextButtonBoxConstraints;

  /// Box constraints for the submit button.
  final BoxConstraints? submitButtonBoxConstraints;

  /// The spacing between the action buttons.
  final double? formActionButtonsSpacing;

  /// The spacing between the content (steps' widgets) and the action buttons.
  final double? contentButtonsSpacing;

  @override
  State<MultiStepForm<T>> createState() => _MultiStepFormState<T>();
}

class _MultiStepFormState<T> extends State<MultiStepForm<T>> {
  late int _currentStepIndex;

  late final cs.CarouselSliderController _carouselController;

  bool _isSwitching = false;

  @override
  void initState() {
    super.initState();
    _currentStepIndex = widget.initialStepIndex ?? 0;
    _carouselController = cs.CarouselSliderController();
  }

  @override
  Widget build(BuildContext context) => cs.CarouselSlider.builder(
        itemCount: widget.steps.length,
        itemBuilder: (context, index, realIndex) {
          final stepData = _stepDataAt(index);
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: stepData.stepWidgetBuilder(
                      context,
                      stepData.value,
                    ),
                  ),
                  SizedBox(height: widget.contentButtonsSpacing),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: _buildBackOrCancelButton(),
                        ),
                        SizedBox(
                          width: widget.formActionButtonsSpacing ??
                              _defaultFormActionButtonsSpacing,
                        ),
                        Flexible(
                          child: _buildNextOrSubmitButton(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        carouselController: _carouselController,
        disableGesture: true,
        options: cs.CarouselOptions(
          height: double.infinity,
          viewportFraction: 1,
          enableInfiniteScroll: false,
          initialPage: _currentStepIndex,
          scrollPhysics: const NeverScrollableScrollPhysics(),
          disableCenter: true,
        ),
      );

  StepData<T> _stepDataAt(int index) => widget.steps[index];

  bool _isCancelButtonEnabled(int stepIndex) => widget.onFormCancelled != null;

  bool _isBackButtonEnabled(int stepIndex) =>
      widget.backButtonEnabled(_stepDataAt(stepIndex).value);

  bool _isNextButtonEnabled(int stepIndex) =>
      widget.nextButtonEnabled(_stepDataAt(stepIndex).value);

  bool _isSubmitButtonEnabled(int stepIndex) => widget.onFormSubmitted != null;

  Widget _buildBackOrCancelButton() => AnimatedCrossFade(
        firstChild: ConstrainedBox(
          constraints:
              widget.cancelButtonBoxConstraints ?? const BoxConstraints(),
          child: ShallowButton(
            color: AppColorsTheme.purple,
            text: context.appLocalizations.cancel,
            width: _defaultButtonWidth,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            onPressed: _isCancelButtonEnabled(_currentStepIndex)
                ? widget.onFormCancelled
                : null,
          ),
        ),
        secondChild: ConstrainedBox(
          constraints:
              widget.backButtonBoxConstraints ?? const BoxConstraints(),
          child: ShallowButton(
            color: AppColorsTheme.purple,
            text: context.appLocalizations.back,
            width: _defaultButtonWidth,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            onPressed: _isBackButtonEnabled(_currentStepIndex)
                ? _goToPreviousStep
                : null,
          ),
        ),
        crossFadeState: _currentStepIndex == 0
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        duration: _crossFadeDuration,
      );

  Widget _buildNextOrSubmitButton() => AnimatedCrossFade(
        firstChild: ConstrainedBox(
          constraints:
              widget.submitButtonBoxConstraints ?? const BoxConstraints(),
          child: FilledButton(
            backgroundColor: AppColorsTheme.purple,
            text: widget.submitButtonLabel ?? context.appLocalizations.submit,
            width: _defaultButtonWidth,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            onPressed: _isSubmitButtonEnabled(_currentStepIndex)
                ? widget.onFormSubmitted
                : null,
          ),
        ),
        secondChild: ConstrainedBox(
          constraints:
              widget.nextButtonBoxConstraints ?? const BoxConstraints(),
          child: FilledButton(
            backgroundColor: AppColorsTheme.purple,
            text: context.appLocalizations.next,
            width: _defaultButtonWidth,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            onPressed:
                _isNextButtonEnabled(_currentStepIndex) ? _goToNextStep : null,
          ),
        ),
        crossFadeState: _currentStepIndex == widget.steps.length - 1
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        duration: _crossFadeDuration,
      );

  void _goToNextStep() {
    if (_isSwitching) return;

    final shouldChangeStep = widget.shouldChangeStep?.call(
          currentStepValue: _stepDataAt(_currentStepIndex).value,
          nextStepValue: _stepDataAt(_currentStepIndex + 1).value,
        ) ??
        true;
    if (!shouldChangeStep) return;

    setState(
      () {
        _currentStepIndex++;
        _isSwitching = true;
        _carouselController.nextPage().then((_) {
          widget.onStepChanged?.call();
          return _isSwitching = false;
        });
      },
    );
  }

  void _goToPreviousStep() {
    if (_isSwitching) return;

    final shouldChangeStep = widget.shouldChangeStep?.call(
          currentStepValue: _stepDataAt(_currentStepIndex).value,
          nextStepValue: _stepDataAt(_currentStepIndex - 1).value,
        ) ??
        true;
    if (!shouldChangeStep) return;

    setState(
      () {
        _currentStepIndex--;
        _isSwitching = true;
        _carouselController.previousPage().then((_) {
          widget.onStepChanged?.call();
          _isSwitching = false;
        });
      },
    );
  }
}
