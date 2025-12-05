import 'package:{{proj_name}}/features/random_jokes/src/models/dtos/joke_dto.dart';
import 'package:{{proj_name}}/foundation/basic_types/basic_types.dart';
import 'package:{{proj_name}}/foundation/networking/networking.dart';

/// API for random jokes operations
class JokesApi {
  const JokesApi(this._httpClient);

  final HttpClient _httpClient;

  /// Fetches a random joke from the API
  Future<Result<NetworkFailure, JokeDto>> fetchRandomJoke() =>
      _httpClient.request(
        path: '/jokes/random',
        method: 'GET',
        successResponseMapper:
            (response) =>
                JokeDto.fromJson(response.data as Map<String, dynamic>),
      );
}
