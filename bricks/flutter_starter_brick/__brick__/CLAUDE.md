# CLAUDE.md

## Architecture Overview

### Architecture Philosophy

We follow a hybrid architecture that combines ideas from Clean Architecture and Domain-Driven Design,
but adapted to what actually works for Flutter apps. It's not purely one or the other - it's what
makes sense for building maintainable apps.

### Module Structure Pattern

Every logical module follows the same structure: a `src/` folder for private implementation and a
barrel file for public exports. A "logical module" is any folder that represents a cohesive unit of
functionality that other parts of the code might need to import.

The rule is simple: if you need to hide implementation details and control what's public, use the
src + barrel pattern. This applies at any nesting level where it makes logical sense. Files inside
the same src folder can import each other freely, but anything outside must go through the barrel
file.

However, avoid excessive nesting. If you already have a module boundary (like features/authentication/src/),
don't create additional src folders inside unless there's a compelling reason. For example, within
a feature's shared folder, subfolders like storage/, apis/, and models/ can contain files directly
without their own src folders.

When creating barrel files, follow the principle of least access: only export what external code
actually needs. By default, keep everything private unless there's a clear need to expose it. This
keeps your public API surface small and makes it easier to refactor internal implementations without
breaking external code.

**Important barrel file guidelines:**
- Don't create barrel files prematurely - wait until you've implemented all files in the module
- **Keep barrel files empty initially** - Only add exports when another module actually needs to import something
- Only export what other modules actually need to use
- Internal implementation details (like storage keys, helper classes) should not be exported
- Question every export: "Who needs this outside this module?" If no clear answer, don't export it
- For features, typically only UI screens and maybe some models need to be exported
- This approach helps verify module boundaries and ensures we only expose true public APIs

### Import Rules

| Folder/File           | Can Import From                                           |
|-----------------------|-----------------------------------------------------------|
| resources/            | Nothing (leaf folder)                                     |
| foundation/           | resources/, other foundation subfolders (through barrels) |
| features/         | foundation/, resources/ (through barrels)                 |
| router/               | features/, foundation/, resources/, dependency_injection/ (through barrels)  |
| dependency_injection/ | Any folder (including src/ for registration)              |
| app/                  | Any folder (through barrels)                              |
| main_development.dart | foundation/ (for Environment), main_common.dart           |
| main_staging.dart     | foundation/ (for Environment), main_common.dart           |
| main_production.dart  | foundation/ (for Environment), main_common.dart           |
| main_common.dart      | Any folder (through barrels)                              |

## Project Structure

### Project Structure Overview

```
lib/
app/                        # Application entry point widgets 
dependency_injection/       # DI configuration 
foundation/                 # Core utilities and shared components 
resources/                  # Assets, translations, etc 
features/                   # Feature modules 
router/                    # Navigation configuration 
main_*.dart                # Environment-specific entry points 

```

### Features Folder

The features folder contains all app features as self-contained modules. Each feature follows a consistent structure:

```
feature_name/
├── feature_name.dart       # Barrel file - exports only public APIs
└── src/                     # Private implementation
    ├── apis/               # HTTP API clients
    ├── blocs/              # State management (Bloc/Cubit)
    ├── models/             # Data models
    │   ├── dtos/          # Data Transfer Objects
    │   ├── ui_models/     # UI-specific models
    │   └── enums/         # Feature-specific enums
    ├── ui/                 # UI components and screens
    └── services/           # Business logic services (optional)
```

**Folder Responsibilities:**
- **apis/**: Thin HTTP wrappers that return Result types
- **blocs/**: Orchestrate between data sources, convert DTOs to UI models, manage state
- **models/dtos/**: API request/response objects with JSON serialization
- **models/ui_models/**: Clean display models without API concerns
- **ui/**: Flutter widgets, screens, and user input handling
- **services/**: Complex business logic (payments, calculations, third-party integrations)

**Inter-Feature Communication:**
Features cannot import from each other directly. Communication happens through:
- Shared models in `foundation/models/` for common DTOs
- Dependency injection callbacks set up in `dependency_injection/`
- Global blocs (Authentication, Subscription) available app-wide

**Cross-Feature Reuse:**
If DTO/UI model/enum from Feature A is needed in Feature B: move it to `foundation/models/` first, update imports in Feature A, then use in Feature B. Features must never import from each other unless allowed by the import rules table. If you find a feature being imported by many others, and you are moving alot of its models to foundation, consider moving the whole feature to foundation instead, and adding back its models to its own src/ if.

### Entry Points

#### Main Files

We have four main files at the lib level:

- `main_development.dart`
- `main_staging.dart`
- `main_production.dart`
- `main_common.dart`

The three environment-specific main files (dev, staging, prod) are incredibly simple - they each
just contain a main() function that calls the mainCommon() function from main_common.dart, passing
the appropriate environment. That's it. They're just thin wrappers that select the environment.

The real work happens in main_common.dart. This is where all the app initialization lives - Flutter bindings, dependency injection, third-party services, state persistence, error handling, and finally launching the root widget.

This separation means we can have different entry points for different environments while keeping
all the initialization logic in one place.

To run the app in a specific environment, we use:
`flutter run -t lib/main_development.dart` (or main_staging.dart, main_production.dart)

### Core Infrastructure

### The App Folder

The app folder contains the application's entry point widgets - the root widget tree that wraps the entire app. It provides top-level blocs (authentication, subscription, theme, localization), sets up MaterialApp.router for navigation, and adds global utilities like overlays, state listeners, and scaffold access.

Following our module pattern, the app folder uses `app/src/` for implementation and `app/app.dart` as the barrel file that exports only the public RootAppWidget.

### Dependency Injection

The dependency_injection folder provides explicit service registration using the ServiceLocator pattern that wraps GetIt. It's initialized in main_common and provides `serviceLocator.get<Type>()` access throughout the app.

The ServiceLocator abstracts the underlying DI library, supports named instances for multiple services of the same type, and follows the src + barrel pattern with only ServiceLocator exported publicly.

### Shared Components

### Foundation Folder

The foundation folder contains the fundamental building blocks and shared components that the
application features build upon. It includes both reusable, app-agnostic components (like the Result
type, base HTTP clients, and UI utilities) as well as app-specific shared components (like the
backend HTTP client configuration).

The foundation folder is structured differently from other top-level folders. It doesn't follow the
src + barrel pattern itself because it contains multiple modules. Instead, it acts as a container
for various foundational modules:

- apis/ - Shared API implementations
- basic_types/ - Core type definitions and utilities
- blocs/ - Base bloc/cubit classes and utilities
- environment_variables/ - Environment-specific variables
- environments/ - Environment configuration classes
- extensions/ - Dart extension methods
- formatters/ - Data formatting utilities
- l10n/ - Localization infrastructure
- logging/ - Logging infrastructure
- models/ - Shared data structures (DTOs, enums, UI models)
- networking/ - HTTP clients and network utilities
- ui/ - Reusable UI components, themes, and widgets
- validators/ - Form validation functions

Each of these folders either contains more nested modules or follows the src + barrel pattern
directly. The key is that no matter how deeply nested we are in the foundation folder, the same
import rules apply: files can only import from their own src folder or through barrel files from
other modules they're allowed to access.

#### Foundation Modules

#### apis/
Shared API implementations used across multiple features.

#### basic_types/
Provides the Result type - a sealed class for handling operations that can fail. Use `result.when()` and `result.whenAsync()` for pattern matching instead of switch statements due to Dart's variance limitations.

#### blocs/
Base bloc/cubit classes and utilities for state management. Provides mixins for safe state emission and common bloc patterns.

#### environment_variables/
Environment-specific configuration via EnvironmentVariables sealed class. Each environment (dev, staging, prod) provides appropriate values for backend URLs, API keys, etc. Registered in DI container based on current environment.

#### environments/
Defines Environment enum (development, staging, production) used by main_*.dart entry points for environment-specific app configuration.

#### extensions/
App-agnostic Dart extension methods. Domain-specific extensions belong elsewhere.

#### formatters/
Data formatting utilities for consistent display across the app.

#### l10n/
Localization infrastructure with BuildContext extensions (`context.appLocalizations`) and LocalizationCubit for persisting language preferences.

#### logging/
Three specialized loggers: AppLogger (console, debug only), ErrorLogger (crash reporting integration), EventLogger (analytics). Separates concerns for different logging strategies.

#### networking/
Layered HTTP architecture: abstract HttpClient interface → DioHttpClient implementation → BackendHttpClient app-specific configuration. Uses Result pattern, NetworkFailure sealed class hierarchy, and supports interceptors for auth/logging.

#### models/
Inter-feature shared data structures organized by purpose: dtos/ (API communication), enums/ (shared enumerations), ui_models/ (UI representations). Feature-specific models stay in features.

#### ui/
Comprehensive UI foundation providing reusable components, Material 3 theming, common widgets, overlays, animations, and UI services. Contains pre-styled components that follow the app's design system.

#### validators/
Reusable form validation functions for common inputs (email, password, names). Return null for valid input or error message string for invalid input, integrating with Flutter's TextFormField validation.

## Coding Patterns

### DTOs and UI Models

DTOs (Data Transfer Objects) aren't just for parsing backend JSON. They're objects designed to
transfer data between layers:
- **Backend → Frontend**: Parse JSON responses into DTOs
- **Frontend → Backend**: Collect form data into DTOs for API submission

The pattern enforces separation: DTOs arrive at the bloc layer but must be converted to UI models
(via `toUiModel()`) before being emitted in bloc states IF the data will be displayed on screen.
This keeps UI layer decoupled from API contracts.

**DTO Construction Pattern**: Always construct request DTOs in the UI layer (forms/widgets) and pass them to cubits/blocs. Never reconstruct DTOs in the cubit - this maintains consistency and makes it clear where data transformation happens. The UI layer is responsible for gathering user input and packaging it into DTOs, while the cubit/bloc layer just forwards these DTOs to the appropriate APIs. Note that it's perfectly fine to use DTOs in the UI layer when they're being used to collect data (like LoginRequestDto, SignupRequestDto) - these are for data collection, not display. Only response DTOs that will be displayed need conversion to UI models.

**User Input Handling**: Never call `.trim()` on user input from controllers. Let validators see the actual input - if invalid, validation should fail. For optional nullable String fields in DTOs, convert empty string to null: `text.isEmpty ? null : text`.

**How to use UiConvertibleDtoMixin**:
1. When creating a DTO that will be displayed in the UI, add `with UiConvertibleDtoMixin<YourUiModel>`
2. Implement the `toUiModel()` method to convert DTO fields to the UI model
3. Use arrow functions for simple conversions: `YourUiModel toUiModel() => YourUiModel(...);`
4. In your bloc/cubit, call `dto.toUiModel()` before emitting states ONLY if the UI needs to display the data
5. It's acceptable to pass DTOs in states when:
- The data is only used for navigation/routing decisions
- The data is passed to callbacks without being displayed
- The DTO serves as a data container between layers without UI representation

Example:
```dart
class UserDto with UiConvertibleDtoMixin<UiUser> {
  final String id;
  final String email;
  
  @override
  UiUser toUiModel() => UiUser(id: id, email: email);
}
```

**Important**: Any UI model that needs to display text on the screen should implement the
`DisplayableUiModel` mixin. This ensures consistent text representation and proper localization
support. For example, error models, user models, or any model shown in dropdowns/lists should
implement `getDisplayText(BuildContext)` to provide their string representation.

### Typography Usage Patterns

When using typography styles in the app, follow these guidelines to maintain consistency:

**1. ALWAYS provide colors explicitly - typography defines ONLY fonts:**
```dart
// GOOD - Always specify color explicitly
Text(
  'Welcome',
  style: context.typography?.primaryTitle.copyWith(
    color: primaryTitleColor,
  ),
)
```

**2. Use copyWith when overriding dynamic or state-dependent properties:**
```dart
// GOOD - Color depends on widget state
Text(
  'Link',
  style: context.typography?.linkText.copyWith(
    color: isEnabled ? primary : disabled, // State-dependent
  ),
)

// GOOD - Single property override
Text(
  'Error: Invalid input',
  style: context.typography?.bodyText.copyWith(
    color: context.themeData.colorScheme.error, // Dynamic from theme
  ),
)

// ACCEPTABLE - Properties depend on runtime state/context
Text(
  'Dynamic',
  style: context.typography?.bodyText.copyWith(
    fontWeight: isImportant ? FontWeight.w600 : FontWeight.w400,
    height: isCompact ? 1.2 : 1.5,
  ),
)
```

**3. Create new Typography style when reused with same static overrides:**
```dart
// If used in 2+ places with same static overrides, add to Typography:
TextStyle get bannerText => Fonts.montserratMedium.textStyle(fontSize: 14);

// Then use it:
Text('Banner', style: context.typography?.bannerText)
```

**4. Inline TextStyle for truly unique one-off styles:**
```dart
// GOOD - Unique style, used once, 50%+ different properties
Text(
  'Limited Time: 50% OFF',
  style: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.promotional,
    decoration: TextDecoration.underline,
    letterSpacing: 2,
  ),
)
```

**Decision Framework:**

When you need a text style, ask:
1. **Does existing style match?** → Use it directly
2. **Need to override properties?**
   - Only dynamic/state-dependent properties? → Use copyWith ✅
   - Overriding 3+ static properties OR 50%+ of style? → Go to step 3
3. **Will this style be reused (2+ places)?**
   - Yes → Add new style to Typography class
   - No → Inline new TextStyle

**copyWith Guidelines:**

Use copyWith **ONLY when** overriding properties that are:
- **Dynamic/state-dependent**: Colors based on enabled/disabled state, values from widget state
- **Runtime values**: User input, API data, theme-dependent colors
- **Local context**: Values that Typography class cannot know about

**Do NOT use copyWith when:**
- Overriding **3+ static properties** (constant values like fontSize, fontWeight, height)
- Overriding **50%+ of the style properties** (means it's a different style)
- The same overrides are used in **2+ places** (extract to Typography instead)

**CRITICAL: Semantic Meaning Preservation**

When using `copyWith` on Typography fields, **NEVER** override these properties as they define the semantic identity of the style:
- ❌ **fontSize** - Changing size changes what the style represents
- ❌ **fontFamily** - Breaking the design system's font choice
- ❌ **fontWeight** - Changes the style fundamentally (regular vs bold vs semibold)
- ❌ **fontStyle** - Changes meaning (normal vs italic)

**Acceptable to override** (visual variations that preserve semantic meaning):
- ✅ **color** - Visual variation, doesn't change what it is
- ✅ **decoration** - Adding underline, strikethrough, etc.
- ✅ **letterSpacing** - Layout/spacing adjustment
- ✅ **height** - Line height adjustment
- ✅ **backgroundColor** - Background highlight
- ✅ Other visual/layout properties (shadows, wordSpacing, textBaseline, etc.)

**The Rule:** Only override `copyWith` properties that don't change the semantic identity of the Typography style. The 4 forbidden properties (fontSize, fontWeight, fontFamily, fontStyle) define WHAT the style represents. All other properties are visual variations.

**Example violations:**
```dart
// BAD - Changing fontSize breaks semantic meaning
context.typography?.primaryTitle.copyWith(fontSize: 18) // NOT a primary title anymore!

// BAD - Changing fontWeight breaks semantic meaning
context.typography?.bodyText.copyWith(fontWeight: FontWeight.w600) // NOT body text anymore!

// Solution: Create new style or use existing one
context.typography?.mediumBodyText // Proper semantic style with w500
```

If you need different fontSize/fontWeight/fontStyle/fontFamily, you need a **different style** - either:
1. Use an existing Typography field that matches
2. Create a new Typography field
3. Inline a custom TextStyle (if truly one-off)

**Examples:**
```dart
// GOOD - Only dynamic property
linkText.copyWith(color: isEnabled ? primary : disabled)

// GOOD - Runtime/theme-dependent
bodyText.copyWith(color: context.themeData.colorScheme.error)

// ACCEPTABLE - All properties are state-dependent
bodyText.copyWith(
  fontWeight: isImportant ? FontWeight.w600 : FontWeight.w400,
  height: isCompact ? 1.2 : 1.5,
)

// BAD - 3 static properties (fontWeight always w500, height always 1.5)
bodyText.copyWith(
  color: context.themeData.colorScheme.onSurface,
  fontWeight: FontWeight.w500,  // STATIC
  height: 1.5,                   // STATIC
)
// Solution: Create mediumBodyText style with w500 and height 1.5

// BAD - Used in multiple places with same overrides
bodyText.copyWith(fontWeight: FontWeight.w500) // Used in 5 files
// Solution: Create medium14 or mediumBodyText style in Typography
```

**What NOT to do:**
```dart
// BAD - Using typography but overriding most properties
Text(
  'Title',
  style: context.typography?.primaryTitle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: Colors.blue,
  ),
)
// If you're changing 3+ properties, create a custom style instead
```

**Typography System Architecture:**

**Fonts (resources/fonts.dart):**
- Enum defining all font files with family, weight, and style
- Extension `textStyle` getter that creates base TextStyle (no fontSize/color)
- Usage: `Fonts.montserratBold.textStyle.copyWith(fontSize: 24, color: red)`

**Typography (foundation/ui/theme/typography.dart):**
- ThemeExtension containing all app text styles as fields
- **IMPORTANT**: Typography provides ONLY font properties (family, weight, size, height)
- **Colors are NEVER included** - must be provided via `.copyWith(color: ...)` in UI code
- Static constants for theme component fonts (defaultButtonFont, etc.)
- Styles named after Figma design tokens (primaryTitle, bodyText, etc.)
- Each field has documentation specifying the font properties and suggested color to use
- Add new styles as you discover them in Figma designs
- Uses **Montserrat** font family by default

### Theme and UI Component Usage

When building UI components, always leverage the existing theme and design system:

**Use the Material 3 Theme:**
```dart
// GOOD - Using theme colors
Container(
  color: context.themeData.colorScheme.primary,
)

// BAD - Hardcoding colors
Container(
  color: Colors.blue,
)
```

**Reuse Existing Components:**
- Check `foundation/ui/widgets/` for existing buttons, cards, dialogs, etc.
- Don't recreate components that already exist
- Use the app's standard button styles, input fields, and other widgets
- When similar functionality exists, extend or compose rather than duplicate

**Theme Constants Over Magic Numbers:**
```dart
// GOOD - Using theme spacing/sizing
Padding(
  padding: EdgeInsets.all(context.themeData.spacing.medium),
)

// BAD - Hardcoding dimensions
Padding(
  padding: EdgeInsets.all(16),
)
```

**Access Theme via Context:**
- Use `context.themeData` for Material theme access
- Use `context.colorScheme` for color scheme shortcuts
- Use `context.typography` for text styles
- Leverage ThemeCubit for theme state management when needed

**Consistency is Key:**
- Before creating any new UI component, search for similar existing components
- Follow the patterns established in similar features
- Maintain visual consistency across the app by reusing theme values

### Spacing Strategy: Figma to Code Translation

When translating designs from Figma to code, follow this systematic approach for spacing values:

**Design System Principle:**
- **Figma = Design exploration** - Designers can use any value (10px, 12px, 37px, etc.)
- **Code = Systematic implementation** - Constrained to design system values for consistency

**Our Spacing System** (`SpacingSize` enum in `foundation/ui/widgets/spacing.dart`):
```dart
xxSmall  = 4px   // Minimal gaps
xSmall   = 8px   // Small gaps (base unit)
small    = 16px  // Standard gaps
medium   = 24px  // Medium gaps
large    = 32px  // Large gaps
xLarge   = 40px  // Extra large gaps
xxLarge  = 48px  // Very large gaps
xxxLarge = 64px  // Maximum gaps
```

**Translation Rules:**

1. **Round to nearest available `SpacingSize` value**
   - Acceptable tolerance: **±4px** (half of base 8px unit)
   - Prioritize consistency over pixel-perfection

2. **Example Translations:**
   | Figma Value | Round To | SpacingSize | Difference |
   |-------------|----------|-------------|------------|
   | 6px | 8px | xSmall | +2px ✅ |
   | 10px | 8px | xSmall | -2px ✅ |
   | 12px | 16px | small | +4px ✅ |
   | 20px | 16px | small | -4px ✅ |
   | 28px | 24px | medium | -4px ✅ |
   | 36px | 40px | xLarge | +4px ✅ |

3. **Always use `Spacing.vertical()` or `Spacing.horizontal()` widgets:**
   ```dart
   // GOOD - Using design system
   const Spacing.vertical(SpacingSize.small)

   // BAD - Hardcoded spacing
   const SizedBox(height: 16)
   ```

4. **When to add new spacing values:**
   - **Only if** a specific value is used **20+ times** across the entire app
   - **Only if** rounding creates obvious visual problems in user testing
   - **Only if** designer explicitly requires it for accessibility/branding
   - Otherwise, always round to existing values

### Sealed Class Patterns

When working with sealed classes in Dart, always use switch statements for exhaustive pattern matching:

**Use switch statements with sealed classes:**
```dart
// GOOD - Using switch for exhaustive handling
switch (state) {
  case AppMetaDataInitial():
    // Handle initial state
  case AppMetaDataLoading():
    // Handle loading state  
  case AppMetaDataLoaded(:final appVersion, :final buildNumber):
    // Handle loaded state with destructuring
  case AppMetaDataError(:final message):
    // Handle error state
}
```

**What NOT to do:**
```dart
// BAD - Using if-else with is checks for sealed classes
if (state is AppMetaDataLoaded) {
  // This doesn't give compile-time exhaustiveness checking
}

// BAD - Using if without handling all cases
if (state is AppMetaDataLoaded) {
  context.read<SplashCubit>().checkVersion(
    appVersion: state.appVersion,
    buildNumber: state.buildNumber,
  );
}
// Missing handling for other states
```

**Benefits of switch with sealed classes:**
- Compile-time exhaustiveness checking - Dart analyzer warns if you miss a case
- Better performance - Single evaluation vs multiple type checks
- Cleaner, more readable code
- Pattern matching with destructuring for accessing properties
- Future-proof - Adding new subtypes forces you to handle them

**Exception: Result type**
The Result type uses `when` and `whenAsync` methods instead of switch due to Dart's variance limitations with generic types. Always use these methods with Result:
```dart
// For Result type, use when/whenAsync
result.when(
  success: (data) => // Handle success
  failure: (error) => // Handle failure  
);
```

### Bloc Architecture Pattern

We follow a pragmatic approach to the Bloc architecture pattern, using repositories where they add real value rather than applying them dogmatically everywhere.

**The Architecture Layers:**
```
UI → Bloc/Cubit → [Repository] → Data Sources
```

**Layer Responsibilities:**
1. **UI Layer**: Sends events/calls methods, reacts to state changes, constructs DTOs for requests
2. **Bloc/Cubit Layer**: Contains ALL business logic, orchestrates operations, validates context after async gaps
3. **Repository Layer** (when used): Abstracts data access, decides between data sources (cache vs network vs storage), NO business logic ever
4. **Data Sources**: Where actual data operations happen
    - **API + HttpClient**: Network requests (these work together as one data source)
    - **Local Storage**: SharedPreferences, SecureStorage, etc.
    - **Local Database**: SQLite, Hive, or other local DB solutions
    - **In-Memory Cache**: Temporary data storage

**When to Use Repository Pattern:**

Use repositories when you have:
- **Multiple data sources**: Need to coordinate between cache, network, and/or local storage
- **Shared data access**: Multiple blocs/cubits need the same data
- **Data source abstraction**: Want to swap implementations without touching bloc
- **Future caching/offline support**: Planning to add these capabilities later

Usually we do not use repositories for:
- **Single data source**: When you'll only ever call one API with no caching
- **One-time operations**: Config loading, version checks, etc.
- **UI orchestration**: Navigation, launching URLs, showing dialogs
- **Local-only state**: Theme preferences, UI settings
  This really depends on the specific case.

**The Pragmatic Principle:**
> "Use repositories for data access abstraction when you have multiple data sources or shared data needs. Don't add them just for pattern purity."

**Repository Rules:**
```dart
// GOOD - Repository only handles data access
class ChatRepository {
  Future<Result<NetworkFailure, List<ChatDto>>> searchChats(request) {
    // Decide: cache or network?
    // Transform: API response to DTOs
    // Return: data or error
    return _api.searchChats(request);
  }
}

// BAD - Repository with business logic
class AuthenticationRepository {
  Future<void> refreshToken() {
    // DON'T put retry logic here
    // DON'T put session validation here
    // DON'T put expiration checks here
    // These belong in the Bloc!
  }
}
```

**Bloc/Cubit Rules:**
```dart
// GOOD - Bloc contains business logic
class AuthenticationBloc {
  Future<void> _handleRefreshToken() async {
    // Business logic: check if token expired
    // Business logic: prevent concurrent refreshes
    // Business logic: retry with backoff
    final result = await _repository.getNewToken();
    // Business logic: validate and store token
  }
}

// BAD - Bloc directly calling API
class LoginCubit {
  final LoginApi _api; // WRONG - should use repository
}
```

**State Management for Interactive UIs:**

For complex interactive UIs (like chat), use single freezed state classes instead of sealed classes:

```dart
// GOOD - Single state class for interactive UI
@freezed
class ChatDrawerState with _$ChatDrawerState {
  const factory ChatDrawerState({
    required UnmodifiableListView<Chat> chats,
    required bool isFetchingChats,
    required bool isDeletingChat,
    required UiNetworkFailure? fetchError,
    // ... other fields
  }) = _ChatDrawerState;
}

// BAD - Sealed classes for interactive UI
sealed class ChatDrawerState {}
class ChatDrawerLoading extends ChatDrawerState {}
class ChatDrawerLoaded extends ChatDrawerState {
  final List<Chat> chats; // Lost during state transitions!
}
```

**Async Gap Validation Pattern:**

CRITICAL: After every `await` statement, validate that your operation context is still valid before emitting state:

```dart
// GOOD - Validation after async gap
Future<void> _handleRename(event, emit) async {
  final chatIndex = _chats.indexWhere((c) => c.id == event.chatId);
  
  // Async gap - anything could happen here!
  final result = await _repository.renameChat(event.chatId, event.newName);
  
  // CRITICAL: Validate context still valid
  final stillExists = _chats.indexWhere((c) => c.id == event.chatId);
  if (stillExists == -1) return; // Chat was deleted, abort!
  
  // Safe to emit
  emitIfNotClosed(emit, state.copyWith(chats: updatedChats));
}

// BAD - No validation after async gap
Future<void> _handleRename(event, emit) async {
  final result = await _repository.renameChat(event.chatId, event.newName);
  emit(state.copyWith(chats: updatedChats)); // Chat might be deleted!
}
```

**Operation Flag Ownership:**
- Whoever starts an operation owns its loading flag
- If superseded by same operation type, new operation owns the flag
- If returning early for other reasons, must reset your own flag
- Use `emitIfNotClosed` from BlocUtils after async gaps

**State Emission Pattern:**
- Always use the state constructor (e.g., `ChatState(...)`) when emitting state, never `state.copyWith(...)`
- Explicitly specify ALL required fields in the constructor
- For fields that should remain unchanged, use `state.fieldName` to preserve current values
- This prevents accidentally preserving stale values and makes state changes explicit and visible

**Consistency Within Features:**
- If a feature has a main Bloc with repository, ALL its Cubits should use repositories too
- Example: AuthenticationBloc has repository → LoginCubit, SignupCubit should too
- This prevents confusion and maintains predictable patterns

### Operation Counter Pattern for Race Condition Prevention

When handling async operations in Blocs that can be superseded by other operations, we use the Operation Counter Pattern to prevent race conditions and ensure consistent state.

**The Problem:**
User performs action A (e.g., loads Chat 1), then quickly performs action B (e.g., loads Chat 2). If Chat 2 loads faster but Chat 1's async operation completes later, Chat 1 could wrongly replace Chat 2's state.

**The Solution:**
```dart
class SomeBloc {
  // Operation counter for tracking operation context
  int _loadOperationCounter = 0;

  Future<void> _handleLoadOperation(event, emit) async {
    // 1. Increment and capture counter BEFORE async gap
    _loadOperationCounter++;
    final capturedCounter = _loadOperationCounter;

    // 2. Set loading flag (this operation now owns it)
    emitIfNotClosed(
      emit,
      SomeState(
        isLoading: true,
        data: state.data,
        // ... other fields
      ),
    );

    // 3. ASYNC GAP - perform operation
    final result = await repository.loadData();

    // 4. Check if still current operation after async gap
    if (capturedCounter != _loadOperationCounter) {
      // Operation was superseded - DO NOT emit state
      // The newer operation owns the loading flag now
      return;
    }

    // 5. Safe to emit - this is still the current operation
    emitIfNotClosed(
      emit,
      SomeState(
        isLoading: false,
        data: result,
        // ... other fields
      ),
    );
  }
}
```

**Critical Rules:**

1. **Ownership Transfer**: When a handler increments a counter, it takes ownership of all related state flags. The previous operation should NOT clear flags when superseded.

2. **Flag Responsibility**: The handler that increments the counter MUST properly set/clear all relevant loading flags and state. Check every emission path!

3. **Systematic Counter Increments**: For each async handler, identify ALL other handlers that could conflict and increment their counters at the START of your handler.

4. **Conflict Analysis Method**:
    - For EACH handler being implemented, go through EVERY other handler
    - Ask: "If this other handler is in an async gap, will its completion conflict with my state?"
    - If YES → Increment that handler's operation counter
    - Document conflicts in a conflict matrix

**Example from ChatBloc:**
```dart
void _handleCreateNewChat(event, emit) {
  // Takes ownership of both load and send operations
  _loadOperationCounter++;  // Supersedes any LoadChat in progress
  _sendOperationCounter++;  // Supersedes any SendMessage in progress

  // Cancel active operations
  _cancelActiveStream();

  // Reset state - this handler owns all flags now
  emit(ChatState.initial());
}
```

**When to Apply:**
- Loading operations that can be interrupted
- Sending/streaming operations
- Any async operation that updates shared state
- Operations where "last one wins" is the desired behavior

**Conflict Matrix Example:**

A conflict matrix helps visualize which operations need to increment counters:

| In Async Gap ↓ / New Operation → | LoadChat | SendMessage | CreateNewChat | StopStreaming |
|-----------------------------------|----------|-------------|---------------|---------------|
| **LoadChat (async)**              | ✅ Inc counter | ✅ Inc counter | ✅ Inc counter | ❌ No conflict |
| **SendMessage (async)**           | ✅ Inc counter | ✅ Inc counter | ✅ Inc counter | ✅ Inc counter |
| **CreateNewChat (sync)**          | impossible | impossible | impossible | impossible |
| **StopStreaming (sync)**          | impossible | impossible | impossible | impossible |

Legend:
- ✅ = New operation must increment the row operation's counter
- ❌ = No conflict, no counter increment needed
- impossible = Synchronous operations can't be in async gap

### Logging Pattern

The application uses three specialized loggers with clear separation of concerns:

**Logger Types:**
- **AppLogger**: Debug console logging (only active in debug mode)
- **ErrorLogger**: Production error reporting (Sentry, Crashlytics, etc.)
- **EventLogger**: Analytics tracking (currently unused in starter)

**Logging Rules:**

1. **Where to Log:**
   - **HTTP Client Layer**: Logs ALL network errors with technical details (status codes, URLs, headers)
   - **Cubit/Bloc Layer**: ONLY logs critical business errors that are NOT network-related
   - **UI Layer**: NEVER log in UI components

2. **What to Log:**
   - **Normal Operations**: Don't log (e.g., successful API calls, theme changes)
   - **Network Errors**: Logged automatically by DioHttpClient with both AppLogger and ErrorLogger
   - **Critical Errors**: Log with both AppLogger and ErrorLogger including stack traces

3. **How to Log Errors:**
   ```dart
   // For critical errors (non-network), always use both loggers:
   try {
     // Critical operation
   } catch (error, stackTrace) {
     _appLogger.log('Error description: $error', tag: _tag);
     await _errorLogger.recordError(error: error, stackTrace: stackTrace);
   }
   ```

4. **Avoid Double Logging:**
   - Network errors are logged ONLY in DioHttpClient
   - Cubits that call APIs should NOT log the network failures again
   - Only log in cubits if handling non-network critical errors

**Example Implementation:**
- **AppMetaDataCubit**: Logs initialization errors (critical, non-network) ✅
- **JokesCubit**: No logging for API failures (would double-log) ✅
- **DioHttpClient**: Logs all HTTP errors with full details ✅

### Resources Folder

The resources folder provides type-safe access to static assets and localization. This is a leaf folder
in our architecture - it doesn't import anything but can be imported by any other module.

It provides typed access to images, fonts, and localization resources through Dart enums and constants,
preventing typos and making refactoring easier.

Example usage:
```dart
// Images - use typed enums instead of strings:
Image.asset(PngImages.appIcon.path)

// Typography - use semantic named styles:
Text(
  'Welcome',
  style: context.typography?.primaryTitle,
)

Text(
  'Body content',
  style: context.typography?.bodyText,
)

// Available styles (add more as you build screens):
context.typography?.primaryTitle     // Titles (24px, Bold)
context.typography?.indicationText   // Labels, hints (12px, Regular)
context.typography?.fieldInput       // Text field input (14px, Regular)
context.typography?.linkText         // Links (16px, Regular)
context.typography?.smallLinkText    // Small links (12px, Regular)
context.typography?.bodyText         // General body text (14px, Regular)
context.typography?.mediumBodyText   // Medium body text (14px, w500, height 1.5)
context.typography?.errorText        // Error messages (14px, Italic, theme error color)
```
