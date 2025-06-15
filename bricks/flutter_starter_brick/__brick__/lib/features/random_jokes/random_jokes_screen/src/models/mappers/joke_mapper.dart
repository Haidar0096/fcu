import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/src/models/dtos/joke_dto.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/src/models/ui_models/ui_joke.dart';

extension JokeDtoMapper on JokeDto {
  UiJoke toUiModel() => UiJoke(id: id ?? '', content: value ?? '');
}
