import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

/// Extended version of [Cubit] that provides some additional functionality.
abstract class BaseCubit<State> extends Cubit<State> {
  BaseCubit(super.initialState);

  /// Emits a new [state] if the [Cubit] is not closed.
  /// Does nothing if the [Cubit] is closed.
  @protected
  void emitIfNotClosed(State state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
