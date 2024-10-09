import 'dart:async';

/// Creates and returns a timer that fires periodically.
Timer createPeriodicTimer({
  required Duration period,
  required void Function(Timer timer) callback,
  bool fireImmediately = false,
}) {
  final timer = Timer.periodic(period, callback);
  if (fireImmediately) {
    callback(timer);
  }
  return timer;
}
