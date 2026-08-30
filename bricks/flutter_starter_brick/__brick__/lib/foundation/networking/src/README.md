Audience: developers working on the generated networking module; this page may contain only the module's file map and public/private boundaries.

# What each file in `networking/src/` holds

This folder is flat and large enough that a reader needs a map before a file
name is enough. The map is here; the module's door stays `networking.dart`
one level up, which says what leaves the folder and what does not.

## The contract the rest of the app sees

| File | What it holds |
| --- | --- |
| `http_client.dart` | The owned request interface — `get`, `post`, `put`, `patch`, `delete`, `uploadFile`, `uploadBytes` — and the progress callback type. Every caller in the app names this and nothing below it. |
| `http_response.dart` | The owned response carrier a caller's mapper reads. |
| `network_failure.dart` | The sealed family of ways a request can fail. A caller must tell the arms apart. |
| `status_codes.dart` | The status-code numbers and the questions asked of them. |
| `cancel_token.dart` | The owned cancel handle, so no caller holds the transport package's own. |

## The transport, and the one place its package is named

| File | What it holds |
| --- | --- |
| `dio_http_client.dart` | The implementation of the owned interface over the transport package. |
| `dio_error_message_builder.dart` | The plain sentence a transport failure is turned into. |
| `http_interceptor.dart` | The owned base every chain step extends; it is what keeps the transport package's name out of every step's signature. |
| `socket_exception.dart` · `socket_exception_io.dart` · `socket_exception_stub.dart` · `socket_exception_web.dart` | Recognising "the machine has no connection" without importing `dart:io` on the web. The facade picks the platform's own file. |

## The two backend clients

| File | What it holds |
| --- | --- |
| `backend_http_client.dart` | The backend client: base address, default headers, timeouts, error parser — set once, here. It takes the chain it will run as a parameter. |
| `backend_interceptors_builder.dart` | The two chains, side by side: the public one, and the logged-in one in its fixed order. Which chain a client runs is decided here and nowhere else. |
| `backend_error_message_parser.dart` | The backend's own error shape, read into a message and a code. |
| `backend_meta_headers.dart` | The headers every backend request carries about the app itself. They ship empty. |

## The steps of a chain, in the order they run

| File | What it holds |
| --- | --- |
| `meta_headers_interceptor.dart` | Step 1 of both chains: the app's own headers go on. |
| `proactive_renewal_interceptor.dart` | Step 2 of the logged-in chain: a token about to end is renewed before the request leaves. |
| `bearer_token_interceptor.dart` | Step 3 of the logged-in chain; attaches its current bearer before the send. The reactive retry replaces that header with the renewed bearer. |
| `reactive_renewal_interceptor.dart` | Step 4 of the logged-in chain: a refused request renews once and is sent again on the same transport. |
| `authorization_header.dart` | The one home of the header name and scheme a token rides under. |
| `request_extras.dart` | The keys the steps leave notes for each other under, on one request's own side data. |

The token store, the renewal coordinator, the renewal outcomes and the
excluded-path list are not here: they live in `foundation/authentication/`,
which owns everything about the token itself.
