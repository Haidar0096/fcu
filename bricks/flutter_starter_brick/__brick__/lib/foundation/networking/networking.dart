export 'src/backend_http_client.dart';
// Only the owned interface leaves the module: the dio-backed implementation
// carries dio types on its own constructor and on an extension it declares,
// which no caller may see, so it is reachable only from inside this folder.
export 'src/cancel_token.dart' show CancelToken;
export 'src/http_client.dart';
export 'src/http_response.dart';
export 'src/network_failure.dart';
export 'src/status_codes.dart';
