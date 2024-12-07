import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

/// A base class for Blocs that provides utility methods.
abstract class BaseBloc<Event, State> extends Bloc<Event, State> {
  BaseBloc(super.initialState);

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
