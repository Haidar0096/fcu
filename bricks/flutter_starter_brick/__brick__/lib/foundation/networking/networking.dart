// What each file inside this module holds: `src/README.md`.
export 'src/authorization_header.dart';
export 'src/backend_http_client.dart';
// The chain builders leave the module so the composition root can name WHICH
// chain a client runs; the steps themselves and the transport type they sit on
// stay inside.
export 'src/backend_interceptors_builder.dart';
export 'src/backend_meta_headers.dart';
// Only the owned interface leaves the module: the dio-backed implementation
// carries dio types on its own constructor and on an extension it declares,
// which no caller may see, so it is reachable only from inside this folder.
export 'src/cancel_token.dart' show CancelToken;
export 'src/http_client.dart';
export 'src/http_response.dart';
export 'src/network_failure.dart';
export 'src/status_codes.dart';
