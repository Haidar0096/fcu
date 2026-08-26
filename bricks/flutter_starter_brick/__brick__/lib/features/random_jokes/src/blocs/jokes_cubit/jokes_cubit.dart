import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/features/random_jokes/src/apis/jokes_api.dart';
import 'package:{{proj_name}}/features/random_jokes/src/models/ui_models/ui_joke.dart';
import 'package:{{proj_name}}/foundation/blocs/bloc_utils/bloc_utils.dart';
import 'package:{{proj_name}}/foundation/ui/models/models.dart';

part 'jokes_state.dart';

/// Manages the state and logic for fetching random jokes
///
/// Conflict matrix: none — fetching a joke is the only action and the entry
/// guard below drops a second one. A matrix becomes needed the moment a second
/// action (a save, a share) can sit in an async gap beside the fetch.
class JokesCubit extends Cubit<JokesState> with CubitUtils<JokesState> {
  JokesCubit({required JokesApi jokesApi})
    : _jokesApi = jokesApi,
      super(const JokesInitial());

  final JokesApi _jokesApi;

  Future<void> fetchJoke() async {
    if (state.isLoading) return;

    emitIfNotClosed(const JokesLoading());

    final result = await _jokesApi.fetchRandomJoke();

    result.when(
      success: (jokeDto) {
        emitIfNotClosed(JokesLoaded(jokeDto.toUiModel()));
      },
      failure: (failure) {
        emitIfNotClosed(JokesFailed(UiNetworkFailure(failure)));
      },
    );
  }
}
