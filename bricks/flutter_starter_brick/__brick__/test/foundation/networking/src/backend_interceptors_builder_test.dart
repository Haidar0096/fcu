import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:flutter_test/flutter_test.dart';
import 'package:{{proj_name}}/foundation/authentication/authentication.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';
import 'package:{{proj_name}}/foundation/networking/networking.dart';
import 'package:{{proj_name}}/foundation/networking/src/authorization_header.dart';
import 'package:{{proj_name}}/foundation/networking/src/backend_interceptors_builder.dart';

/// The logged-in chain, stood up exactly as a generated app stands it up: the
/// real builder, over a real transport, with a scripted transport adapter.
///
/// The transport package is named here because this test exercises the
/// module's internal chain builder directly. Neither the builder nor its
/// transport-bearing signature leaves the public networking barrel.
void main() {
  group('the logged-in chain', () {
    test(
      'retries a refused request with the renewed token, not the held one',
      () async {
        final store = await _storeHolding(
          _tokens('held', endsIn: const Duration(hours: 1)),
        );
        final renewed = _tokens('renewed', endsIn: const Duration(hours: 1));
        final coordinator = AuthTokenRenewalCoordinator(
          renewTokens: ({required AuthTokens currentTokens}) async =>
              AuthTokenRenewedOutcome(tokens: renewed),
        );
        addTearDown(coordinator.close);

        final adapter = _ScriptedAdapter(const [401, 200]);
        final transport = _chainOn(
          adapter: adapter,
          store: store,
          coordinator: coordinator,
        );

        await transport.get<dynamic>('/protected');

        // Two requests reached the transport: the first carrying what was held,
        // the second — the retry — carrying what the renewal handed back. A
        // retry that carries the held token again is refused for the same
        // reason the first request was.
        expect(adapter.authorizationHeaders, <String?>[
          AuthorizationHeader.valueFor('held'),
          AuthorizationHeader.valueFor('renewed'),
        ]);
      },
    );

    test(
      'renews before the request and after the refusal, never on the retry',
      () async {
        // Near its end, so the proactive step renews before the request
        // leaves.
        final store = await _storeHolding(
          _tokens('held', endsIn: const Duration(seconds: 10)),
        );

        // Every renewal records the refresh credential it was handed, because
        // WHICH credential is presented is the thing that can go wrong: a
        // count alone passes while the second renewal presents the credential
        // the first one already spent.
        final presented = <String>[];
        final coordinator = AuthTokenRenewalCoordinator(
          renewTokens: ({required AuthTokens currentTokens}) async {
            presented.add(currentTokens.refreshToken);
            return AuthTokenRenewedOutcome(
              tokens: _tokens(
                'renewed${presented.length}',
                endsIn: const Duration(hours: 1),
              ),
            );
          },
        );
        addTearDown(coordinator.close);

        final adapter = _ScriptedAdapter(const [401, 200]);
        final transport = _chainOn(
          adapter: adapter,
          store: store,
          coordinator: coordinator,
        );

        await transport.get<dynamic>('/protected');

        // Twice, and each on a credential nothing had spent: the first on the
        // held set, the second on what the first renewal handed back. A second
        // renewal on `held-refresh` would present a credential the first one
        // already spent, and the server answers that by logging the user out.
        // A third renewal would do the same to the second one's credential.
        expect(presented, <String>['held-refresh', 'renewed1-refresh']);
      },
    );
  });
}

/// Builds the logged-in chain on a transport answered by [adapter].
///
/// The transport carries no base address: [adapter] answers every request
/// without dialling, and a real address in Dart source is what the
/// `no_backend_url_literals` rule exists to stop.
dio.Dio _chainOn({
  required _ScriptedAdapter adapter,
  required AuthTokenStore store,
  required AuthTokenRenewalCoordinator coordinator,
}) {
  final transport = dio.Dio()..httpClientAdapter = adapter;
  transport.interceptors.addAll(
    loggedInInterceptorsBuilder(
      tokenStore: store,
      renewalCoordinator: coordinator,
    )(transport),
  );
  return transport;
}

/// The real token store over an in-memory secure store, already holding
/// [tokens].
Future<AuthTokenStore> _storeHolding(AuthTokens tokens) async {
  final values = <String, String>{};
  final store = AuthTokenStore(
    appLogger: const AppLogger(),
    errorLogger: ErrorLogger(
      reportSender: const _DiscardingReportSender(),
      flowBuffer: FlowBuffer(),
      appShortName: 'test',
    ),
    readValue: ({required key}) async => values[key],
    writeValue: ({required key, required value}) async {
      values[key] = value;
    },
    deleteValue: ({required key}) async {
      values.remove(key);
    },
  );
  await store.write(tokens: tokens);
  return store;
}

AuthTokens _tokens(String accessToken, {required Duration endsIn}) =>
    AuthTokens(
      accessToken: accessToken,
      refreshToken: '$accessToken-refresh',
      accessTokenExpiresAt: DateTime.now().toUtc().add(endsIn),
    );

/// Answers each request from a fixed list of status codes and records the
/// authorization header every request carried.
final class _ScriptedAdapter implements dio.HttpClientAdapter {
  _ScriptedAdapter(this._statusCodes);

  final List<int> _statusCodes;

  /// The `Authorization` header of every request that reached the transport,
  /// in the order they reached it.
  final List<String?> authorizationHeaders = <String?>[];

  int _answered = 0;

  @override
  Future<dio.ResponseBody> fetch(
    dio.RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    authorizationHeaders.add(
      options.headers[AuthorizationHeader.name] as String?,
    );
    final statusCode =
        _statusCodes[_answered.clamp(0, _statusCodes.length - 1)];
    _answered++;
    return dio.ResponseBody.fromString('', statusCode);
  }

  @override
  void close({bool force = false}) {}
}

final class _DiscardingReportSender implements ReportSender {
  const _DiscardingReportSender();

  @override
  Future<void> send(ErrorReportDto report) async {}

  @override
  Future<void> sendParkedReports() async {}
}
