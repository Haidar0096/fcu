import 'package:flutter/widgets.dart';
import 'package:{{proj_name}}/common/models/ui_models/src/displayable_ui_model.dart';
import 'package:{{proj_name}}/infrastructure/l10n/l10n.dart';
import 'package:{{proj_name}}/infrastructure/networking/http_client/http_client.dart';

class UiNetworkFailure implements DisplayableUiModel {
  UiNetworkFailure(this._failure);

  final NetworkFailure _failure;

  @override
  String getDisplayText(BuildContext context) => switch (_failure) {
    NetworkError() => context.appLocalizations.networkErrorMessage,
    ServerError() => context.appLocalizations.serverErrorMessage,
    TimeoutError() => context.appLocalizations.timeoutErrorMessage,
    CancelError() => context.appLocalizations.requestCancelledMessage,
    UnknownError() => context.appLocalizations.unknownErrorMessage,
  };
}
