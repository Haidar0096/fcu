import 'package:{{proj_name}}/foundation/authentication/src/auth_token_renewal_outcome.dart';
import 'package:{{proj_name}}/foundation/authentication/src/auth_tokens.dart';

const String _missingWiring =
    'Missing token renewal wiring: the renewal endpoint path, and the shape '
    'the server hands a new token set back in. The starter names neither. '
    'Hand the renewal coordinator the renewal this project owns when it '
    'adds login, and decide there whether the path is an environment value.';

/// The renewal the starter hands the coordinator: it stops loudly instead of
/// guessing.
///
/// Two facts a renewal needs are the project's own and cannot be known here:
/// the address the renewal is posted to, and the shape the server hands the
/// new token set back in. Inventing either would ship a renewal that posts a
/// refresh credential at a plausible-looking address and reads a plausible-
/// looking field — and fails silently the first time it meets a real server.
///
/// So the plumbing around it is complete and wired, and this one step stops
/// with a message naming exactly what is missing — the same shape a missing
/// build value takes at startup. The starter never reaches it: nothing holds
/// a token, so nothing renews. The day this project adds login it hands the
/// coordinator its own renewal in the dependency injection file, and that is
/// the only line that changes.
///
/// The renewal call itself rides the PUBLIC client, never the logged-in one,
/// so a renewal can never trigger another renewal. Which client a real
/// renewal takes is the dependency injection file's line, like every other
/// client decision.
Future<AuthTokenRenewalOutcome> unwiredAuthTokenRenewal({
  required AuthTokens currentTokens,
}) => throw StateError(_missingWiring);
