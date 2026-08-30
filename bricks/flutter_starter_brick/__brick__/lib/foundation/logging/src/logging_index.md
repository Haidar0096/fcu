# What each file in `logging/src/` holds

Audience: developers working in the generated app's logging foundation; this
page contains module structure only.

The module's public door is `logging.dart` one level up. This index maps the
flat source folder; it does not widen that public API.

## Logging and reporting roads

| File | What it holds |
| --- | --- |
| `app_logger.dart` | Debug console lines with timestamps, tags, and optional stacks. |
| `event_logger.dart` | Debug event lines after sensitive-data stripping. |
| `error_logger.dart` | The one road that composes, strips, and sends error and information reports. |
| `error_report_dto.dart` | The outgoing report shape and its two report levels. |

## Report delivery

| File | What it holds |
| --- | --- |
| `report_sender.dart` | The owned interface for sending fresh and parked reports. |
| `backend_report_sender.dart` | The default sender through the app's own backend client. |
| `report_sender_kind.dart` | The configured sender kind. |
| `parked_report_store.dart` | The bounded device store for reports awaiting another send. |
| `parked_report_persistence.dart` | The platform selector for parked-report persistence. |
| `parked_report_persistence_io.dart` | Native JSONL persistence in application-support storage. |
| `parked_report_persistence_web.dart` | Browser persistence through shared preferences. |
| `parked_report_persistence_stub.dart` | The explicit stop for unsupported platforms. |
| `parked_report_store_keys.dart` | The browser-storage keys owned by the parked-report store. |

## Context and privacy

| File | What it holds |
| --- | --- |
| `flow_buffer.dart` | The bounded in-memory list of recent screen names. |
| `screen_trail_observer.dart` | The router observer that fills the flow buffer with screen names. |
| `sensitive_data_sanitizer.dart` | The forbidden-field list and the stripping functions for headers, bodies, and report text. |
