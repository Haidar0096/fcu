import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Extended version of [HydratedCubit] that provides some additional
/// functionality.
mixin HydratedCubitUtils<State> on HydratedCubit<State> {
  /// Emits a new [state] if the [HydratedCubit] is not closed.
  /// Does nothing if the [HydratedCubit] is closed.
  @protected
  void emitIfNotClosed(State state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
