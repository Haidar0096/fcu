# What each file in `widgets/src/` holds

Audience: developers working in the generated app's shared UI foundation; this
page contains module structure only.

The module's public door is `widgets.dart` one level up. This index maps the
flat source folder; it does not widen that public API.

## Screen frame and status feedback

| File | What it holds |
| --- | --- |
| `root_screen_widget.dart` | The shared outer frame for screens, including platform chrome, safe areas, back handling, and screen slots. |
| `loader_widget.dart` | The shared loading indicator and its design defaults. |
| `status_banner_widget.dart` | The shared inline status view for loading, success, error, warning, and information states. |
| `status_banner_widget_defaults.dart` | Design values owned by the status banner. |
| `sliding_banner.dart` | The transient overlay-banner controller, durations, and build-context helpers. |
| `sliding_banner_widget.dart` | The private animated widget used by `sliding_banner.dart`. |

## Buttons, fields, and validation

| File | What it holds |
| --- | --- |
| `custom_elevated_button.dart` | The configurable elevated-button base and its defaults. |
| `main_button.dart` | The primary action button. |
| `secondary_button.dart` | The secondary action button. |
| `destructive_button.dart` | The destructive action button. |
| `custom_radio_button.dart` | The animated radio-button view and its design defaults. |
| `custom_text_form_field.dart` | The shared text field, public validation state, and field defaults. |
| `invisible_validation_widget.dart` | Validation state for values that have no visible input field. |

## Layout and visual helpers

| File | What it holds |
| --- | --- |
| `spacing.dart` | The project's fixed spacing scale. |
| `spacing_widget.dart` | Directional gap widgets built from the spacing scale. |
| `blur_widget.dart` | Optional backdrop blur and its default intensity. |
| `dim_widget.dart` | Optional dimming over a child widget. |
| `expandable_card.dart` | The expandable card, its public state, and its design defaults. |
| `png_image.dart` | Rendering helpers for registered PNG assets. |

## Platform and lifecycle seams

| File | What it holds |
| --- | --- |
| `on_app_lifecycle_changed_callback.dart` | The callback type for app-lifecycle changes. |
| `platform_navigation.dart` | The conditional-export door for platform navigation. |
| `platform_navigation_io.dart` | Platform navigation for native targets. |
| `platform_navigation_web.dart` | Platform navigation for web targets. |
| `platform_navigation_stub.dart` | The fallback used where no platform implementation applies. |
