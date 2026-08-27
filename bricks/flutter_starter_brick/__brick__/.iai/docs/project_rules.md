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

### Starter Features
The brick ships with three example features in `lib/features/`:
- `splash_screen/` — Splash with initialization
- `random_jokes/` — Example feature with API
- `critical_error_screen/` — Unrecoverable-error screen

### Code Generation Dependencies
- `json_serializable`: DTO serialization
- `go_router_builder`: Type-safe routing

### Localization System
- Supports English out of the box (Arabic structure ready)
- ARB files in `resources/src/arb/`
- Uses `flutter_localizations` package
- Access via `context.appLocalizations.keyName`

### Animation Extensions
Widgets are animated through one extension, `withAnimations`, on `Widget` and on `List<Widget>` (`foundation/ui/animations/`):

```dart
// Single widget
MyWidget().withAnimations(withFade: true, duration: Duration(seconds: 1))
MyWidget().withAnimations(withScale: true)
MyWidget().withAnimations(
  withSlide: true,
  slideDirection: SlideDirection.bottomToTop,
)

// List, with stagger
[widget1, widget2, widget3].withAnimations(
  staggered: true,
  staggeredDelay: Duration(milliseconds: 100),
)
```

### BLoC Utilities

`foundation/blocs/bloc_utils/` ships a `CubitUtils<State>` mixin that gives `Cubit` classes safe state emission via `emitIfNotClosed`. Use it on every Cubit to avoid emitting after `close()`:

```dart
class MyCubit extends Cubit<MyState> with CubitUtils<MyState> {
  Future<void> loadData() async {
    emitIfNotClosed(LoadingState());
    // ... async work
    emitIfNotClosed(LoadedState(data));
  }
}
```

For `Bloc`s, `emitIfNotClosed(emit, state)` is also available — see the file in `lib/foundation/blocs/bloc_utils/src/`.

## Common Tasks

### Modifying Error Handling

1. Add the new failure type to the sealed family in `foundation/networking/src/network_failure.dart`
2. Add its arm to the UI wrapper's `getDisplayText` switch in `foundation/ui/models/src/ui_network_failure.dart` — that method is the only road error text takes to a user
3. Add the localized messages to both ARB files
4. Update state classes to use the new failure types
