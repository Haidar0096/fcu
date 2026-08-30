import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/src/apis/jokes_api.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/src/models/ui_models/ui_joke.dart';
import 'package:{{proj_name}}/foundation/blocs/bloc_utils/bloc_utils.dart';
import 'package:{{proj_name}}/foundation/ui/models/models.dart';

part 'jokes_state.dart';

/// Manages the state and logic for fetching random jokes
///
/// Conflict matrix: none — fetching a joke is the only action and the entry
/// guard below drops a second one. A matrix becomes needed the moment a second
/// action (a save, a share) can sit in an async gap beside the fetch.
class JokesCubit extends Cubit<JokesState> with CubitUtilsMixin<JokesState> {
  JokesCubit({required JokesApi jokesApi})
    : _jokesApi = jokesApi,
      super(const JokesInitialState());

  final JokesApi _jokesApi;

  Future<void> fetchJoke() async {
    if (state.isLoading) return;

    final lastGoodJoke = state.lastGoodJoke;
    emit(JokesLoadingState(lastGoodJoke: lastGoodJoke));

    final result = await _jokesApi.fetchRandomJoke();
    if (isClosed) return;

    result.when(
      success: (jokeDto) {
        emitIfNotClosed(JokesLoadedState(joke: jokeDto.toUiModel()));
      },
      failure: (failure) {
        if (failure.isContractViolation) {
          emitIfNotClosed(const JokesCriticalErrorState());
          return;
        }
        if (failure.isCancelError) {
          emitIfNotClosed(
            switch (lastGoodJoke) {
              null => const JokesInitialState(),
              final joke => JokesLoadedState(joke: joke),
            },
          );
          return;
        }
        emitIfNotClosed(
          JokesFailedState(
            uiFailure: UiNetworkFailure.fromNetworkFailure(failure)!,
            lastGoodJoke: lastGoodJoke,
          ),
        );
      },
    );
  }
}
