import 'dart:async';

import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/base_card.dart';
import 'package:flutter/material.dart';

/// A widget that executes a callback after a period of
/// inactivity (no user touching this widget's area on the screen) and displays
/// a countdown popup before executing it.
class InactivityTimeoutWidget extends StatefulWidget {
  const InactivityTimeoutWidget({
    required this.child,
    super.key,
    Duration? timeout,
    this.keepCheckingForInactivityAfterUserInteraction = true,
    this.keepCheckingForInactivityAfterExecutingCallback = true,
    this.popupColor,
    this.showPopup = false,
    this.popupDisplayThreshold = 0.2,
    this.callback,
    this.popupTextBuilder,
  }) : timeout = timeout ?? const Duration(seconds: 120);

  /// The child widget representing the content of the screen.
  final Widget child;

  /// The duration after which the screen will automatically close.
  final Duration timeout;

  /// - If true, then the user interaction with the screen will reset the
  /// process of checking for inactivity.
  /// - If false, the widget will only check for inactivity once, i.e., once
  /// the user interacts with the screen, the widget will not check for
  /// inactivity again.
  final bool keepCheckingForInactivityAfterUserInteraction;

  /// - If true, then after executing the callback, the widget will continue
  /// checking for inactivity.
  /// - If false, the widget will only execute the callback once, i.e., once
  /// the callback is executed, the widget will not check for inactivity again.
  final bool keepCheckingForInactivityAfterExecutingCallback;

  /// The color of the time-remaining-to-close popup.
  final Color? popupColor;

  /// If set to false, the time-remaining-to-close popup will not be displayed.
  final bool showPopup;

  /// The callback to be called when [timeout] time has passed without
  /// interaction from the user.
  /// - If [keepCheckingForInactivityAfterUserInteraction] is true, then this
  /// callback will be executed
  /// every [timeout] time if no activity is detected.
  /// - If [keepCheckingForInactivityAfterUserInteraction] is false, then this
  /// callback will be executed
  /// only once when no activity is detected, and will not be executed again.
  /// - If [keepCheckingForInactivityAfterExecutingCallback] is true, then the
  /// widget will continue
  /// checking for inactivity after executing this callback.
  /// - If [keepCheckingForInactivityAfterExecutingCallback] is false, then the
  /// widget will stop
  /// checking for inactivity after executing this callback.
  /// - Note that setting [keepCheckingForInactivityAfterExecutingCallback] and
  /// [keepCheckingForInactivityAfterUserInteraction] to opposite values can
  /// result in unexpected behavior (not a bug), where one effect might cancel
  /// the other, so make sure they are set according to your use case.
  final Future<void> Function(BuildContext context)? callback;

  /// The percentage of time remaining after which the popup will be displayed.
  /// Range of values is from 0 to 1.
  ///
  /// ## Example
  /// if the value of this parameter is 0.2, then the popup will be displayed
  /// when the time left to close the screen reaches 20% of the total time. If
  /// the total time is 10 seconds, then the popup will be displayed when there
  /// are 2 seconds left.
  final double popupDisplayThreshold;

  /// Optional builder function to build the text to be displayed in the popup.
  final String Function(BuildContext context, Duration remainingTime)?
      popupTextBuilder;

  @override
  State<InactivityTimeoutWidget> createState() =>
      _InactivityTimeoutWidgetState();
}

class _InactivityTimeoutWidgetState extends State<InactivityTimeoutWidget> {
  late Duration _remainingTime;
  late bool _popupVisible;
  Timer? _timer;

  Duration get _timeout => widget.timeout;

  double get _popupDisplayThreshold {
    if (widget.popupDisplayThreshold < 0) {
      return 0;
    }
    if (widget.popupDisplayThreshold > 1) {
      return 1;
    }
    return widget.popupDisplayThreshold;
  }

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _defaultPopupText =>
      '${_remainingTime.inSeconds} seconds remaining until inactivity is '
      'detected.';

  @override
  Widget build(BuildContext context) {
    final popupText = widget.popupTextBuilder?.call(context, _remainingTime) ??
        _defaultPopupText;

    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: AnimatedCrossFade(
              crossFadeState: widget.showPopup && _popupVisible
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
              layoutBuilder: (
                Widget topChild,
                Key topChildKey,
                Widget bottomChild,
                Key bottomChildKey,
              ) =>
                  Stack(
                children: <Widget>[
                  Positioned(key: bottomChildKey, child: bottomChild),
                  Positioned(key: topChildKey, child: topChild),
                ],
              ),
              firstChild: BaseCard(
                cardColor: widget.popupColor ?? AppColorsTheme.lightPurple,
                child: Text(
                  popupText,
                  style: context.appTextTheme.body3
                      .copyWith(color: AppColorsTheme.purple),
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ),
        ),
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) {
              if (widget.keepCheckingForInactivityAfterUserInteraction) {
                _resetTimer();
              } else {
                _stopTimer();
              }
            },
          ),
        ),
      ],
    );
  }

  void _stopTimer() => setState(
        () {
          _timer?.cancel();
          _popupVisible = false;
        },
      );

  void _resetTimer() => setState(
        () {
          // cancel the previous timer if it exists
          _timer?.cancel();

          _remainingTime = _timeout;
          _popupVisible = false;

          const oneSecond = Duration(seconds: 1);

          _timer = Timer.periodic(
            oneSecond,
            (timer) async {
              if (_remainingTime.inSeconds <= 0) {
                timer.cancel();
                await widget.callback?.call(context);
                if (widget.keepCheckingForInactivityAfterExecutingCallback) {
                  _resetTimer();
                }
                // no need to stop the timer here because it has already been
                // stopped above
              } else {
                setState(
                  () {
                    _remainingTime -= oneSecond;
                    final remainingTimePercentage =
                        _remainingTime.inSeconds / _timeout.inSeconds;
                    if (remainingTimePercentage <= _popupDisplayThreshold) {
                      _popupVisible = true;
                    } else {
                      _popupVisible = false;
                    }
                  },
                );
              }
            },
          );
        },
      );
}
