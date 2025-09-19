import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

/// A base class for Blocs that provides utility methods.
mixin BlocUtils<Event, State> on Bloc<Event, State> {
  /// Emits the [state] if the bloc is not closed. Otherwise, does nothing.
  ///
  /// This method is useful for safely emitting states in situations where
  /// the bloc might have been closed.
  @protected
  void emitIfNotClosed(Emitter<State> emit, State state) {
    if (!isClosed) {
      emit(state);
    }
  }
}

/// Creates a debounce transformer for events.
///
/// This transformer will delay event processing by [duration] and
/// only process the last event after the duration of inactivity.
///
/// Example: With Duration(milliseconds: 300), if user types "hello":
/// - Types "h" → starts 300ms timer
/// - Types "e" at 100ms → resets timer
/// - Types "l" at 200ms → resets timer
/// - Stops typing → after 300ms of inactivity, processes "hel"
///
/// Useful for search inputs, auto-save, and other scenarios where
/// you want to wait for user to stop repeating an action before processing.
@protected
EventTransformer<E> debounce<E>(Duration duration) =>
    (events, mapper) => events.debounceTime(duration).flatMap(mapper);

/// Creates a throttle transformer that strictly limits event frequency.
///
/// This transformer ensures events are processed only when BOTH
/// conditions are met:
/// 1. At least [duration] has passed since the last processed event
/// 2. The previous event has finished processing
///
/// Example: With Duration(seconds: 1), if user rapidly clicks 5 times:
/// - Click 1 (0ms) → Processed immediately (takes 1.5s to complete)
/// - Click 2 (200ms) → Dropped (neither condition met)
/// - Click 3 (500ms) → Dropped (neither condition met)
/// - Click 4 (1100ms) → Dropped (time passed but Click 1 still processing)
/// - Click 5 (1600ms) → Processed (both conditions now met)
///
/// This provides the strictest throttling, ensuring true sequential
/// processing with guaranteed minimum time gaps between operations.
///
/// Useful for preventing spam clicks on buttons, rate-limiting API calls,
/// and ensuring sequential processing of user actions.
@protected
EventTransformer<E> throttle<E>(Duration duration) => (events, mapper) {
  DateTime? lastEventTime;
  var isProcessing = false;
  StreamSubscription<E>? activeSubscription;

  return events.transform(
    StreamTransformer<E, E>.fromHandlers(
      handleData: (event, sink) {
        final now = DateTime.now();
        final canProcess =
            (lastEventTime == null ||
                now.difference(lastEventTime!) >= duration) &&
            !isProcessing;

        if (canProcess) {
          lastEventTime = now;
          isProcessing = true;

          // Handle synchronous errors
          Stream<E> mappedStream;
          try {
            mappedStream = mapper(event);
          } catch (e, s) {
            isProcessing = false;
            sink.addError(e, s);
            return;
          }

          // Subscribe to the mapped stream
          activeSubscription = mappedStream.listen(
            sink.add,
            onError: (Object e, StackTrace s) {
              sink.addError(e, s);
            },
            onDone: () {
              isProcessing = false;
              activeSubscription = null;
            },
            cancelOnError: false,
          );
        }
        // If can't process, event is silently dropped
      },
      handleDone: (sink) {
        activeSubscription?.cancel();
        sink.close();
      },
    ),
  );
};
