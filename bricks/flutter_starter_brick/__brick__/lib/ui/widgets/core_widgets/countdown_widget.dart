import 'dart:async';

import 'package:flutter/material.dart';

/// A widget that manages a countdown timer, and provides callbacks
/// on tick and on end of countdown.
class CountDownWidget extends StatefulWidget {
  const CountDownWidget({
    required this.countdownDuration,
    super.key,
    this.onCountdownEnd,
    this.onCountdownTick,
    this.tickInterval,
    this.child,
  });

  /// The duration of the countdown.
  final Duration countdownDuration;

  /// The callback to be called when the countdown ends.
  final void Function(BuildContext context)? onCountdownEnd;

  /// The callback to be called on each tick of the countdown.
  final void Function(
    BuildContext context,
    Duration remainingTime,
  )? onCountdownTick;

  /// The interval at which the countdown should tick.
  final Duration? tickInterval;

  /// The child widget, displayed as is.
  final Widget? child;

  @override
  State<CountDownWidget> createState() => _CountDownWidgetState();
}

class _CountDownWidgetState extends State<CountDownWidget> {
  late final Timer _countdownTimer;
  late Duration _remainingTime;
  late final Duration _tickInterval;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.countdownDuration;
    _tickInterval = widget.tickInterval ?? const Duration(seconds: 1);
    _countdownTimer = Timer.periodic(
      _tickInterval,
      (timer) {
        _remainingTime -= _tickInterval;
        if (_remainingTime <= Duration.zero) {
          widget.onCountdownEnd?.call(context);
          timer.cancel();
        } else {
          widget.onCountdownTick?.call(context, _remainingTime);
        }
      },
    );
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child ?? const SizedBox.shrink();
}
