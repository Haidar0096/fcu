import 'dart:collection';

import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/l10n/l10n.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

const Duration _crossFadeDuration = Duration(milliseconds: 300);

class MultiStepWidgetDefaults {
  static const double contentButtonsSpacing = 40;
  static const double formActionButtonsSpacing = 16;
  static const double progressIndicatorSpacing = 8;
  static const double progressIndicatorPadding = 24;
  static const double bottomButtonsPadding = 24;
  static const double currentStepHeight = 6;
  static const double inactiveStepHeight = 4;
  static const Duration animationDuration = Duration(milliseconds: 500);
  static const Duration shimmerDuration = Duration(seconds: 2);
  static const double shimmerBegin = -1;
  static const double shimmerEnd = 2;
  static const double shimmerOpacity = 40;
  static const double shadowOpacity = 60;
  static const double inactiveOpacity = 50;
  static const double blurRadius = 4;
  static const double shimmerStopOffset = 0.5;
}

/// Represents the data of a step, i.e. a widget and an optional value of
/// type [T].
final class StepData<T> {
  StepData({
    required this.widget,
    required this.value,
  });

  final Widget widget;
  final T value;

  @override
  String toString() => 'StepData{widget: $widget, value: $value}';
}

/// A function that evaluates if an action should be done based on the given
/// step value.
typedef SingleStepActionEvaluator<T> = bool Function(T stepValue);

/// A function to be called to perform an action based on the given step value.
typedef SingleStepAction<T> = void Function(T stepValue);

/// A function that evaluates if an action should be done based on the given
/// values of two steps.
typedef TwoConsecutiveStepsActionEvaluator<T> =
    bool Function({
      required T currentStepValue,
      required T nextStepValue,
    });

/// A function to be called to perform an action based on the given two
/// consecutive steps values.
typedef TwoConsecutiveStepsAction<T> =
    void Function({
      required T currentStepValue,
      required T nextStepValue,
    });

bool _defaultIsButtonEnabled(_) => true;

/// A widget that represents content with multiple steps to be completed.
class MultiStepWidget<T> extends StatefulWidget {
  MultiStepWidget({
    required this.steps,
    super.key,
    this.shouldChangeStep,
    this.onStepChanged,
    this.onFormSubmitted,
    this.onFormCancelled,
    this.initialStepIndex,
    this.submitButtonLabel,
    this.firstStepCancelButtonLabel,
    this.showProgressIndicator = true,
    this.backButtonEnabled = _defaultIsButtonEnabled,
    this.cancelButtonEnabled = _defaultIsButtonEnabled,
    this.nextButtonEnabled = _defaultIsButtonEnabled,
    this.submitButtonEnabled = _defaultIsButtonEnabled,
    this.backButtonBoxConstraints,
    this.cancelButtonBoxConstraints,
    this.nextButtonBoxConstraints,
    this.submitButtonBoxConstraints,
    this.formActionButtonsSpacing,
    this.contentButtonsSpacing,
  }) : assert(
         steps.isNotEmpty,
         'The steps list must not be empty.',
       ),
       assert(
         initialStepIndex == null ||
             (initialStepIndex >= 0 && initialStepIndex < steps.length),
         'The initial step index must be a valid index of the steps list.',
       );
  final UnmodifiableListView<StepData<T>> steps;

  /// Called before changing the step to evaluate if the step change should be
  /// done. If this callback returns false, the step change will be cancelled.
  final TwoConsecutiveStepsActionEvaluator<T>? shouldChangeStep;

  /// Callback to be called after the current step changes and changing
  /// animation is completed.
  final void Function()? onStepChanged;

  final void Function()? onFormSubmitted;

  final void Function()? onFormCancelled;

  final int? initialStepIndex;

  final String? submitButtonLabel;

  /// Custom label for the cancel button on first step
  final String? firstStepCancelButtonLabel;

  /// Whether to show a progress indicator at the top
  final bool showProgressIndicator;

  /// Whether the back button should be enabled based on the current step
  /// data.
  final SingleStepActionEvaluator<T> backButtonEnabled;

  /// Whether the cancel button should be enabled based on the current step
  /// data.
  final SingleStepActionEvaluator<T> cancelButtonEnabled;

  /// Whether the next button should be enabled based on the current step
  /// data.
  final SingleStepActionEvaluator<T> nextButtonEnabled;

  /// Whether the submit button should be enabled based on the current step
  /// data.
  final SingleStepActionEvaluator<T> submitButtonEnabled;

  final BoxConstraints? backButtonBoxConstraints;

  final BoxConstraints? cancelButtonBoxConstraints;

  final BoxConstraints? nextButtonBoxConstraints;

  final BoxConstraints? submitButtonBoxConstraints;

  /// The spacing between the action buttons.
  final double? formActionButtonsSpacing;

  /// The spacing between the content (steps' widgets) and the action buttons.
  final double? contentButtonsSpacing;

  @override
  State<MultiStepWidget<T>> createState() => _MultiStepWidgetState<T>();
}

class _MultiStepWidgetState<T> extends State<MultiStepWidget<T>> {
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
  Widget build(BuildContext context) => Column(
    children: [
      if (widget.showProgressIndicator) ...[
        _buildProgressIndicator(),
        VerticalSpacing.medium,
      ],
      Expanded(
        child: Column(
          children: [
            Expanded(
              child: cs.CarouselSlider.builder(
                itemCount: widget.steps.length,
                itemBuilder: (context, index, realIndex) =>
                    SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: widget.contentButtonsSpacing ?? MultiStepWidgetDefaults.contentButtonsSpacing,
                      ),
                      child: Center(
                        child: widget.steps[index].widget,
                      ),
                    ),
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
              ),
            ),
            // Fixed buttons at the bottom
            Padding(
              padding: EdgeInsets.only(bottom: MultiStepWidgetDefaults.bottomButtonsPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: _buildBackOrCancelButton(),
                  ),
                  SizedBox(
                    width: widget.formActionButtonsSpacing ?? MultiStepWidgetDefaults.formActionButtonsSpacing,
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
    ],
  );

  Widget _buildProgressIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MultiStepWidgetDefaults.progressIndicatorPadding),
      child: Row(
        children: List.generate(
          widget.steps.length,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < widget.steps.length - 1 ? MultiStepWidgetDefaults.progressIndicatorSpacing : 0,
              ),
              child: _ProgressSegment(
                isActive: index <= _currentStepIndex,
                isCurrentStep: index == _currentStepIndex,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackOrCancelButton() => AnimatedCrossFade(
    firstChild: ConstrainedBox(
      constraints: widget.cancelButtonBoxConstraints ?? const BoxConstraints(),
      child: SecondaryButton(
        text:
            (widget.firstStepCancelButtonLabel ??
                    context.appLocalizations.cancel)
                .toUpperCase(),
        width: double.infinity,
        onPressed:
            widget.cancelButtonEnabled(widget.steps[_currentStepIndex].value)
            ? widget.onFormCancelled
            : null,
      ),
    ),
    secondChild: ConstrainedBox(
      constraints: widget.backButtonBoxConstraints ?? const BoxConstraints(),
      child: SecondaryButton(
        text: context.appLocalizations.back.toUpperCase(),
        width: double.infinity,
        onPressed:
            !widget.backButtonEnabled(widget.steps[_currentStepIndex].value)
            ? null
            : _goToPreviousStep,
      ),
    ),
    crossFadeState: _currentStepIndex == 0
        ? CrossFadeState.showFirst
        : CrossFadeState.showSecond,
    duration: _crossFadeDuration,
  );

  Widget _buildNextOrSubmitButton() => AnimatedCrossFade(
    firstChild: ConstrainedBox(
      constraints: widget.submitButtonBoxConstraints ?? const BoxConstraints(),
      child: MainButton(
        text: (widget.submitButtonLabel ?? context.appLocalizations.getStarted)
            .toUpperCase(),
        width: double.infinity,
        onPressed:
            widget.submitButtonEnabled(widget.steps[_currentStepIndex].value)
            ? widget.onFormSubmitted
            : null,
      ),
    ),
    secondChild: ConstrainedBox(
      constraints: widget.nextButtonBoxConstraints ?? const BoxConstraints(),
      child: MainButton(
        text: context.appLocalizations.next.toUpperCase(),
        width: double.infinity,
        onPressed:
            !widget.nextButtonEnabled(widget.steps[_currentStepIndex].value)
            ? null
            : _goToNextStep,
      ),
    ),
    crossFadeState: _currentStepIndex == widget.steps.length - 1
        ? CrossFadeState.showFirst
        : CrossFadeState.showSecond,
    duration: _crossFadeDuration,
  );

  void _goToNextStep() {
    if (_isSwitching) return;

    final shouldChangeStep =
        widget.shouldChangeStep?.call(
          currentStepValue: widget.steps[_currentStepIndex].value,
          nextStepValue: widget.steps[_currentStepIndex + 1].value,
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

    final shouldChangeStep =
        widget.shouldChangeStep?.call(
          currentStepValue: widget.steps[_currentStepIndex].value,
          nextStepValue: widget.steps[_currentStepIndex - 1].value,
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

/// Progress segment widget with animations
class _ProgressSegment extends StatefulWidget {
  const _ProgressSegment({
    required this.isActive,
    required this.isCurrentStep,
  });

  final bool isActive;
  final bool isCurrentStep;

  @override
  State<_ProgressSegment> createState() => _ProgressSegmentState();
}

class _ProgressSegmentState extends State<_ProgressSegment>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: MultiStepWidgetDefaults.shimmerDuration,
      vsync: this,
    );

    _shimmerAnimation =
        Tween<double>(
          begin: MultiStepWidgetDefaults.shimmerBegin,
          end: MultiStepWidgetDefaults.shimmerEnd,
        ).animate(
          CurvedAnimation(
            parent: _shimmerController,
            curve: Curves.easeInOut,
          ),
        );

    if (widget.isCurrentStep) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(_ProgressSegment oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrentStep && !oldWidget.isCurrentStep) {
      _shimmerController.repeat();
    } else if (!widget.isCurrentStep && oldWidget.isCurrentStep) {
      _shimmerController
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: MultiStepWidgetDefaults.animationDuration,
      curve: Curves.easeInOut,
      height: widget.isCurrentStep ? MultiStepWidgetDefaults.currentStepHeight : MultiStepWidgetDefaults.inactiveStepHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          widget.isCurrentStep
              ? ThemeDefaults.borderRadiusXSmall + 1
              : ThemeDefaults.borderRadiusXSmall,
        ),
        boxShadow: widget.isCurrentStep
            ? [
                BoxShadow(
                  color: context.themeData.colorScheme.primary.withAlpha(MultiStepWidgetDefaults.shadowOpacity.toInt()),
                  blurRadius: MultiStepWidgetDefaults.blurRadius,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Base progress bar
          AnimatedContainer(
            duration: MultiStepWidgetDefaults.animationDuration,
            decoration: BoxDecoration(
              color: widget.isActive
                  ? context.themeData.colorScheme.primary
                  : context.themeData.colorScheme.outline.withAlpha(MultiStepWidgetDefaults.inactiveOpacity.toInt()),
              borderRadius: BorderRadius.circular(
                widget.isCurrentStep
                    ? ThemeDefaults.borderRadiusXSmall + 1
                    : ThemeDefaults.borderRadiusXSmall,
              ),
            ),
          ),
          // Shimmer effect for current step
          if (widget.isCurrentStep && widget.isActive)
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      ThemeDefaults.borderRadiusXSmall + 1,
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withAlpha(MultiStepWidgetDefaults.shimmerOpacity.toInt()),
                        Colors.transparent,
                      ],
                      stops: [
                        (_shimmerAnimation.value - MultiStepWidgetDefaults.shimmerStopOffset).clamp(0.0, 1.0),
                        _shimmerAnimation.value.clamp(0.0, 1.0),
                        (_shimmerAnimation.value + MultiStepWidgetDefaults.shimmerStopOffset).clamp(0.0, 1.0),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
