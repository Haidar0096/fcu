dump: full

# {{proj_name.pascalCase()}} — Project Rules

Project-specific rules for this app. Universal Flutter/Dart rules and architecture come from the global `mobile` skill (its Flutter mechanics live in `mobile/flutter/`) — only the app-specific bits live here.

## Project Overview

<TODO({{dev_name.paramCase()}}): Add an overview of the app here, be comprehensive. This overview should cover everything one needs to know to understand what is this app.>

## Generated App Defaults

This app was generated from the Flutter Starter Brick (`flutter_starter_brick` from FCU). The defaults below describe what ships out of the box; replace any of them as the project requires.

### App Configuration
- **Orientation**: Locked to portrait mode
- **Full screen**: System UI overlays hidden
- **Storage**: HydratedBloc for persistent state
- **Error handling**: Global error logger
- **Linting**: very_good_analysis package

### Unsettled Project Facts

- **Lock model**: Unsettled. Record the project answer before production.
- **Native crash vendor**: Unsettled. No vendor has been selected.
- **Dark mode**: Unsettled. The starter contains both themes; shipping policy
  needs a project answer.
- **Digit style**: Unsettled. Choose Western or local-script digits.

### Starter Features
The brick ships with three example features in `lib/features/`:
- `splash_screen/` — Splash with initialization
- `random_jokes/random_jokes_screen/` — Example feature with API
- `critical_error_screen/` — Unrecoverable-error screen

### Starter Screen Choices

- The splash cover and critical-error screen are centered full-screen states,
  so neither uses the default fixed header/body/action composition.
- The disposable random-jokes sample keeps its existing headerless body; a
  product header requires the project's copy and design decision.
- The random-jokes inline loader and persistent failure banner are provisional
  smallest-visible choices until the project chooses its loading and failure
  surfaces.
- A shared wide-screen maximum is unsettled. Add the standard constrained
  center only after the project chooses `ThemeDefaults.maxContentWidth`.

### Code Generation Dependencies
- `json_serializable`: DTO serialization
- `go_router_builder`: Type-safe routing

### Localization System
- Supports English and Arabic out of the box
- ARB files in `resources/src/arb/`
- Uses `flutter_localizations` package
- Access via `context.appLocalizations.keyName`

### BLoC Utilities

`foundation/blocs/bloc_utils/` ships a `CubitUtils<State>` mixin that gives `Cubit` classes safe state emission via `emitIfNotClosed`. Use it on every Cubit to avoid emitting after `close()`:

```dart
class MyCubit extends Cubit<MyState> with CubitUtils<MyState> {
  Future<void> loadData() async {
    emit(const LoadingState());
    final data = await loadFromOutsideWorld();
    if (isClosed) return;
    emitIfNotClosed(LoadedState(data: data));
  }
}
```

For `Bloc`s, `emitIfNotClosed(emit: emit, state: state)` is also available —
see the file in `lib/foundation/blocs/bloc_utils/src/`.

## Common Tasks

### Modifying Error Handling

1. Add the new failure type to the sealed family in `foundation/networking/src/network_failure.dart`
2. Add its arm to the UI wrapper's `getDisplayText` switch in `foundation/ui/models/src/ui_network_failure.dart` — that method is the only road error text takes to a user
3. Add the localized messages to both ARB files
4. Update state classes to use the new failure types
