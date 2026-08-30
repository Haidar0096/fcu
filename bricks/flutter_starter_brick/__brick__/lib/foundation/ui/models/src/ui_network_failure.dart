import 'package:flutter/widgets.dart';
import 'package:{{proj_name}}/foundation/networking/networking.dart';
import 'package:{{proj_name}}/foundation/ui/mixins/mixins.dart';
import 'package:{{proj_name}}/resources/resources.dart';

@immutable
class UiNetworkFailure implements DisplayableUiModelMixin {
  const UiNetworkFailure._(this._failure);

  /// Converts only failures that belong on a user-visible error surface.
  /// Cancellation is a normal ending and therefore returns null.
  static UiNetworkFailure? fromNetworkFailure(NetworkFailure failure) =>
      switch (failure) {
        CancelError() => null,
        ContractViolationError() => null,
        NetworkError() || ServerError() || TimeoutError() || UnknownError() =>
          UiNetworkFailure._(failure),
      };

  final NetworkFailure _failure;

  @override
  String getDisplayText(AppLocalizations texts) {
    // Always use localized generic messages for security reasons
    // Backend error messages may contain technical details or sensitive info
    return switch (_failure) {
      NetworkError() => texts.networkErrorMessage,
      ServerError() => texts.serverErrorMessage,
      TimeoutError() => texts.timeoutErrorMessage,
      CancelError() => throw StateError(
        'Cancellation cannot create a UiNetworkFailure.',
      ),
      ContractViolationError() => throw StateError(
        'A contract violation must use the critical-error road.',
      ),
      UnknownError() => texts.unknownErrorMessage,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UiNetworkFailure &&
          runtimeType == other.runtimeType &&
          _failure == other._failure;

  @override
  int get hashCode => _failure.hashCode;
}
