import 'package:json_annotation/json_annotation.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/src/models/ui_models/ui_joke.dart';
import 'package:{{proj_name}}/foundation/ui/mixins/mixins.dart';

part 'joke_dto.g.dart';

/// DTO for joke API response.
///
/// Response-only DTO: nothing ever sends a joke to a server, so the write
/// direction is not generated.
@JsonSerializable(createToJson: false)
final class JokeDto with UiConvertibleDtoMixin<UiJoke> {
  const JokeDto({required this.id, required this.value});

  factory JokeDto.fromJson(Map<String, dynamic> json) =>
      _$JokeDtoFromJson(json);

  final String id;

  final String value;

  @override
  UiJoke toUiModel() => UiJoke(id: id, content: value);
}
