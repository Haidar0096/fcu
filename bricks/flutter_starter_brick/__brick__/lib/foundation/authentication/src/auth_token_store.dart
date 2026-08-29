import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:{{proj_name}}/foundation/authentication/src/auth_token_store_keys.dart';
import 'package:{{proj_name}}/foundation/authentication/src/auth_tokens.dart';

/// The one home of the app's tokens.
///
/// Hides `flutter_secure_storage`, the only package this class imports. Tokens
/// are the one thing that belongs here: a non-secret flag goes to preferences
/// and restart-surviving state to hydrated storage, by the storage-by-kind
/// rule.
///
/// IT SHIPS EMPTY. The starter declares no login, so nothing writes a token
/// yet; every [read] answers null and the logged-in client simply attaches no
/// header. [write] and [clear] are the doors a project's auth bloc uses the
/// day it adds login — the plumbing is here first so adding login is one
/// change, not two.
///
/// On macOS, an app that stores tokens in the Keychain needs the Keychain
/// Sharing entitlement, whose value carries that project's own bundle
/// identifier. The starter stores no token, so it adds none. Add it when login
/// is wired.
final class AuthTokenStore {
  /// Creates the store with the wrapper's default secure storage client.
  factory AuthTokenStore.standard() =>
      const AuthTokenStore(secureStorage: FlutterSecureStorage());

  /// Creates the store over an injected secure storage client.
  const AuthTokenStore({required FlutterSecureStorage secureStorage})
    : _secureStorage = secureStorage;

  final FlutterSecureStorage _secureStorage;

  /// Reads the held token set, or null when nothing is held.
  ///
  /// A partly written or unreadable set answers null rather than a half token
  /// set: a request then rides without a header and the server refuses it
  /// loudly, which is the visible failure.
  Future<AuthTokens?> read() async {
    final accessToken = await _secureStorage.read(
      key: AuthTokenStoreKeys.accessToken,
    );
    final refreshToken = await _secureStorage.read(
      key: AuthTokenStoreKeys.refreshToken,
    );
    final end = await _secureStorage.read(key: AuthTokenStoreKeys.accessTokenEnd);
    if (accessToken == null || refreshToken == null || end == null) return null;

    final parsedEnd = DateTime.tryParse(end);
    if (parsedEnd == null) return null;

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiresAt: parsedEnd.toUtc(),
    );
  }

  /// Replaces the held token set with [tokens].
  Future<void> write({required AuthTokens tokens}) async {
    await _secureStorage.write(
      key: AuthTokenStoreKeys.accessToken,
      value: tokens.accessToken,
    );
    await _secureStorage.write(
      key: AuthTokenStoreKeys.refreshToken,
      value: tokens.refreshToken,
    );
    await _secureStorage.write(
      key: AuthTokenStoreKeys.accessTokenEnd,
      value: tokens.accessTokenExpiresAt.toUtc().toIso8601String(),
    );
  }

  /// Deletes every held value, one delete after the previous one finishes.
  ///
  /// The deletes run SEQUENTIALLY on purpose: concurrent secure-storage
  /// deletes fail on some platforms.
  Future<void> clear() async {
    for (final key in AuthTokenStoreKeys.all) {
      await _secureStorage.delete(key: key);
    }
  }
}
