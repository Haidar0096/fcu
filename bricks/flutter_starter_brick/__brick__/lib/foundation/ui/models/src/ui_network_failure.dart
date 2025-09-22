import 'package:flutter/widgets.dart';
import 'package:{{proj_name}}/foundation/l10n/l10n.dart';
import 'package:{{proj_name}}/foundation/networking/models/models.dart';
import 'package:{{proj_name}}/foundation/ui/mixins/mixins.dart';

@immutable
class UiNetworkFailure implements DisplayableUiModelMixin {
  const UiNetworkFailure(this._failure);

  final NetworkFailure _failure;

  @visibleForTesting
  NetworkFailure get networkFailure => _failure;

  @override
  String getDisplayText(BuildContext context) {
    // Always use localized generic messages for security reasons
    // Backend error messages may contain technical details or sensitive info
    return switch (_failure) {
      NetworkError() => context.appLocalizations.networkErrorMessage,
      ServerError() => context.appLocalizations.serverErrorMessage,
      TimeoutError() => context.appLocalizations.timeoutErrorMessage,
      CancelError() => context.appLocalizations.requestCancelledMessage,
      UnknownError() => context.appLocalizations.unknownErrorMessage,
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
