import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/shared/models/ui_models/ui_models.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/src/apis/jokes_api.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/src/models/mappers/joke_mapper.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/src/models/ui_models/ui_joke.dart';
import 'package:{{proj_name}}/infrastructure/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/infrastructure/networking/http_client/http_client.dart';

part 'jokes_state.dart';

@Service()
class JokesCubit extends Cubit<JokesState> {
  JokesCubit(this._api) : super(JokesInitial());

  final JokesApi _api;

  Future<void> fetch() async {
    if (state.loading) return; // Prevent multiple fetches
    emit(JokesLoading());
    final result = await _api.fetchRandomJoke();
    result.when(
      success: (joke) => emit(JokesLoaded(joke.toUiModel())),
      failure: (failure) => emit(JokesFailed(failure)),
    );
  }
}
