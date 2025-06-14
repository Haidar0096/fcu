import 'package:json_annotation/json_annotation.dart';

part 'joke_dto.g.dart';

@JsonSerializable()
class JokeDto {
  const JokeDto({required this.id, required this.value});

  factory JokeDto.fromJson(Map<String, dynamic> json) =>
      _$JokeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$JokeDtoToJson(this);

  final String? id;
  final String? value;
}
