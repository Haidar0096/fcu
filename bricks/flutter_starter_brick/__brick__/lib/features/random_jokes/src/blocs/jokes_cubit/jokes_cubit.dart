import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/features/random_jokes/src/apis/jokes_api.dart';
import 'package:{{proj_name}}/features/random_jokes/src/models/ui_models/ui_joke.dart';
import 'package:{{proj_name}}/foundation/blocs/bloc_utils/bloc_utils.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';
import 'package:{{proj_name}}/foundation/ui/models/models.dart';

part 'jokes_state.dart';

/// Manages the state and logic for fetching random jokes
final class JokesCubit extends Cubit<JokesState> with CubitUtils {
  JokesCubit({
    required JokesApi jokesApi,
    required AppLogger appLogger,
  }) : _jokesApi = jokesApi,
       _appLogger = appLogger,
       super(const JokesInitial());

  final JokesApi _jokesApi;
  final AppLogger _appLogger;

  static const String _tag = 'JokesCubit';

  Future<void> fetchJoke() async {
    if (state is JokesLoading) return; // Prevent multiple fetches

    _appLogger.log('Fetching new joke', tag: _tag);
    emitIfNotClosed(const JokesLoading());

    final result = await _jokesApi.fetchRandomJoke();

    result.when(
      success: (jokeDto) {
        _appLogger.log('Joke fetched successfully', tag: _tag);
        emitIfNotClosed(JokesLoaded(jokeDto.toUiModel()));
      },
      failure: (failure) {
        _appLogger.log('Failed to fetch joke', tag: _tag);
        emitIfNotClosed(JokesFailed(UiNetworkFailure(failure)));
      },
    );
  }
}
