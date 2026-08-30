import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:{{proj_name}}/foundation/authentication/src/auth_token_store_keys.dart';
import 'package:{{proj_name}}/foundation/authentication/src/auth_tokens.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';

/// Reads one value from the platform secure store.
typedef OnReadAuthTokenValueCallback =
    Future<String?> Function({required String key});

/// Atomically replaces one value in the platform secure store.
typedef OnWriteAuthTokenValueCallback =
    Future<void> Function({required String key, required String value});

/// Deletes one value from the platform secure store.
typedef OnDeleteAuthTokenValueCallback =
    Future<void> Function({required String key});

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
  factory AuthTokenStore.standard({
    required AppLogger appLogger,
    required ErrorLogger errorLogger,
  }) {
    const secureStorage = FlutterSecureStorage();
    return AuthTokenStore(
      appLogger: appLogger,
      errorLogger: errorLogger,
      readValue: ({required key}) => secureStorage.read(key: key),
      writeValue: ({required key, required value}) =>
          secureStorage.write(key: key, value: value),
      deleteValue: ({required key}) => secureStorage.delete(key: key),
    );
  }

  /// Creates the store over package-free secure-storage operations.
  const AuthTokenStore({
    required AppLogger appLogger,
    required ErrorLogger errorLogger,
    required OnReadAuthTokenValueCallback readValue,
    required OnWriteAuthTokenValueCallback writeValue,
    required OnDeleteAuthTokenValueCallback deleteValue,
  }) : _appLogger = appLogger,
       _errorLogger = errorLogger,
       _readValue = readValue,
       _writeValue = writeValue,
       _deleteValue = deleteValue;

  static const String _tag = 'AuthTokenStore';
  final AppLogger _appLogger;
  final ErrorLogger _errorLogger;
  final OnReadAuthTokenValueCallback _readValue;
  final OnWriteAuthTokenValueCallback _writeValue;
  final OnDeleteAuthTokenValueCallback _deleteValue;

  /// Reads the held token set, or null when nothing is held.
  ///
  /// A partly written or unreadable set answers null rather than a half token
  /// set: a request then rides without a header and the server refuses it
  /// loudly, which is the visible failure.
  Future<AuthTokens?> read() async {
    try {
      final encoded = await _readValue(key: AuthTokenStoreKeys.tokens);
      if (encoded == null) return null;

      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Stored token set is not a JSON object.');
      }
      final accessToken = decoded['accessToken'];
      final refreshToken = decoded['refreshToken'];
      final accessTokenExpiresAt = decoded['accessTokenExpiresAt'];
      if (accessToken is! String ||
          refreshToken is! String ||
          accessTokenExpiresAt is! String) {
        throw const FormatException('Stored token set has an invalid shape.');
      }
      final parsedEnd = DateTime.tryParse(accessTokenExpiresAt);
      if (parsedEnd == null) {
        throw const FormatException('Stored token expiry is invalid.');
      }

      return AuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessTokenExpiresAt: parsedEnd.toUtc(),
      );
    } catch (_, stackTrace) {
      await _recordFailure(
        message: 'Failed to read the stored authentication token set.',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Replaces the held token set with [tokens].
  Future<void> write({required AuthTokens tokens}) async {
    try {
      await _writeValue(
        key: AuthTokenStoreKeys.tokens,
        value: jsonEncode({
          'accessToken': tokens.accessToken,
          'refreshToken': tokens.refreshToken,
          'accessTokenExpiresAt': tokens.accessTokenExpiresAt
              .toUtc()
              .toIso8601String(),
        }),
      );
    } catch (_, stackTrace) {
      await _recordFailure(
        message: 'Failed to replace the stored authentication token set.',
        stackTrace: stackTrace,
      );
      Error.throwWithStackTrace(
        StateError('Failed to replace the stored authentication token set.'),
        stackTrace,
      );
    }
  }

  /// Deletes the one record holding the complete token set.
  Future<void> clear() async {
    try {
      await _deleteValue(key: AuthTokenStoreKeys.tokens);
    } catch (_, stackTrace) {
      await _recordFailure(
        message: 'Failed to clear the stored authentication token set.',
        stackTrace: stackTrace,
      );
      Error.throwWithStackTrace(
        StateError('Failed to clear the stored authentication token set.'),
        stackTrace,
      );
    }
  }

  Future<void> _recordFailure({
    required String message,
    required StackTrace stackTrace,
  }) async {
    _appLogger.log(message: message, tag: _tag, stackTrace: stackTrace);
    await _errorLogger.recordError(error: message, stackTrace: stackTrace);
  }
}
