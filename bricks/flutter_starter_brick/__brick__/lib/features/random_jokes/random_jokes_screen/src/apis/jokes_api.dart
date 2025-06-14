import 'dart:async';

import 'package:{{proj_name}}/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/src/models/dtos/joke_dto.dart';
import 'package:{{proj_name}}/infrastructure/basic_types/basic_types.dart';
import 'package:{{proj_name}}/infrastructure/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/infrastructure/networking/http_client/http_client.dart';

@LazySingletonService()
class JokesApi {
  JokesApi(
    @DIName(DependencyInjectionInstanceNames.jokesBackendHttpClient)
    HttpClient httpClient,
  ) : _httpClient = httpClient;

  final HttpClient _httpClient;

  Future<Result<NetworkFailure, JokeDto>> fetchRandomJoke() async =>
      _httpClient.request(
        path: '/jokes/random',
        method: 'GET',
        successResponseMapper:
            (response) =>
                JokeDto.fromJson(response.data as Map<String, dynamic>),
      );
}
