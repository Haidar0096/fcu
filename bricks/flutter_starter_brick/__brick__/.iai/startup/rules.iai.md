# {{proj_name.pascalCase()}} — Project Rules

Project-specific rules for this app. Universal Flutter/Dart rules and architecture come from the global `flutter-developer` skill — only the app-specific bits live here.

## Project Overview

<TODO({{dev_name}}): Add an overview of the app here, be comprehensive. This overview should cover everything one needs to know to understand what is this app.>

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
- `error/` — Global error screen

### Code Generation Dependencies
- `json_serializable`: DTO serialization
- `go_router_builder`: Type-safe routing
- `flutter_gen`: Asset generation

### Localization System
- Supports English out of the box (Arabic structure ready)
- ARB files in `resources/src/arb/`
- Uses `flutter_localizations` package
- Access via `context.appLocalizations.keyName`

### Animation Extensions
Widgets can be easily animated using extensions on `Widget`:

```dart
// Single widget animations
MyWidget().fadeIn(duration: Duration(seconds: 1))
MyWidget().scaleIn()
MyWidget().slideInFromBottom()

// List animations with stagger
[widget1, widget2, widget3].staggeredFadeIn(
  duration: Duration(milliseconds: 300),
  delay: Duration(milliseconds: 100),
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

1. Add new failure type to `foundation/networking/models/`
2. Create corresponding UI wrapper in `foundation/models/ui_models/`
3. Add localized messages to ARB files
4. Update state classes to use new failure types
