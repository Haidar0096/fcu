import 'package:flutter/widgets.dart';
import 'package:{{proj_name}}/foundation/networking/networking.dart';
import 'package:{{proj_name}}/foundation/ui/mixins/mixins.dart';
import 'package:{{proj_name}}/resources/resources.dart';

@immutable
class UiNetworkFailure implements DisplayableUiModelMixin {
  const UiNetworkFailure({required NetworkFailure failure})
    : _failure = failure;

  final NetworkFailure _failure;

  @override
  String getDisplayText(AppLocalizations texts) {
    // Always use localized generic messages for security reasons
    // Backend error messages may contain technical details or sensitive info
    return switch (_failure) {
      NetworkError() => texts.networkErrorMessage,
      ServerError() => texts.serverErrorMessage,
      TimeoutError() => texts.timeoutErrorMessage,
      CancelError() => texts.requestCancelledMessage,
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
