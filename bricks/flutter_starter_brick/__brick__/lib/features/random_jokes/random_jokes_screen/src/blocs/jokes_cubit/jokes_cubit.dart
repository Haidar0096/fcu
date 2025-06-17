import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/src/apis/jokes_api.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/src/models/mappers/joke_mapper.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/src/models/ui_models/ui_joke.dart';
import 'package:{{proj_name}}/infrastructure/blocs/bloc_utils/bloc_utils.dart';
import 'package:{{proj_name}}/infrastructure/dependency_injection/dependency_injection.dart';

part 'jokes_state.dart';

@Service()
class JokesCubit extends Cubit<JokesState> with CubitUtils {
  JokesCubit(this._api) : super(JokesInitial());
  final JokesApi _api;

  Future<void> fetch() async {
    if (state.loading) return; // Prevent multiple fetches
    emitIfNotClosed(JokesLoading());
    final result = await _api.fetchRandomJoke();
    result.when(
      success: (joke) => emitIfNotClosed(JokesLoaded(joke.toUi())),
      failure:
          (f) => emitIfNotClosed(
        JokesFailed('Couldn’t fetch a joke – try again.'),
      ),
    );
  }
}
