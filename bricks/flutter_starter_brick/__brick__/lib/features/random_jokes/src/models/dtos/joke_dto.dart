import 'package:json_annotation/json_annotation.dart';
import 'package:{{proj_name}}/features/random_jokes/src/models/ui_models/ui_joke.dart';
import 'package:{{proj_name}}/foundation/ui/mixins/mixins.dart';

part 'joke_dto.g.dart';

/// DTO for joke API response.
///
/// Chosen deviation from "required stays required at parse": both fields are
/// nullable and fall back inside [toUiModel] BECAUSE the sample talks to a
/// third-party demo endpoint whose contract this project does not own, and a
/// starter must not die because someone else's demo changed. A DTO for this
/// project's OWN backend keeps contract-required fields non-nullable, so a
/// contract break fails loudly instead of rendering an empty card.
///
/// Response-only DTO: nothing ever sends a joke to a server, so the write
/// direction is not generated.
@JsonSerializable(createToJson: false)
final class JokeDto with UiConvertibleDtoMixin<UiJoke> {
  const JokeDto({required this.id, required this.value});

  factory JokeDto.fromJson(Map<String, dynamic> json) =>
      _$JokeDtoFromJson(json);

  /// Unique identifier for the joke
  final String? id;

  /// The joke content/text
  final String? value;

  @override
  UiJoke toUiModel() => UiJoke(id: id ?? '', content: value ?? '');
}
