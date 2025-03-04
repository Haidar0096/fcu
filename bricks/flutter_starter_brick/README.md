# flutter_starter_brick

[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

A brick for bootstrapping a new Flutter project with useful features.

Includes multiple environments, API support, and Bloc for state management.

## Features

- [&check;] **Multiple Environments Configuration**: Easily set up development, staging, and production environments.
- [&check;] **API Integration**: Seamlessly integrate RESTful APIs into your project.
- [&check;] **Bloc State Management**: Manage your application's state efficiently using the Bloc pattern.
- [&check;] **Internet Connectivity Handling**: Automatically detect and handle changes in internet connectivity.
- [&check;] **Customizable UI Components**: Utilize pre-built widgets like buttons, forms, and more, ready for customization.
- [&check;] **Theming and Styling**: Implement consistent theming across your application with predefined color schemes.
- [&check;] **Internationalization (i18n)**: Support multiple languages effortlessly.
- [&check;] **Form Validation**: Built-in validation utilities to ensure data integrity in forms.
- [&check;] **Script to create APK for all platforms**.
- [&check;] **Script to upload IPA to TestFlight**.
- [&cross;] **Github actions (Coming Soon)**: Release to github releases, google play internal track, and testflight.

## Project Structure
Here is the project structure of the starter brick using mermaid.
You can view it at [https://mermaid.live/](https://mermaid.live/).
```mermaid
graph TD
    lib --> common
    lib --> dependency_injection
    lib --> features
    lib --> infrastructure
    lib --> resources
    lib --> router
    lib --> main_files[main files]

    features --> error_screen
    features --> home
    features --> splash_screen

    common --> variables
    common --> widgets

    home --> home_screen

    infrastructure --> basic_types
    infrastructure --> blocs
    infrastructure --> dependency_injection
    infrastructure --> environments
    infrastructure --> l10n
    infrastructure --> logging
    infrastructure --> networking
    infrastructure --> ui
    infrastructure --> validators

    blocs --> app_meta_data_cubit
    blocs --> bloc_utils

    networking --> dio_http_client[dio_http_client]
    networking --> http_client

    ui --> animations
    ui --> theme
    ui --> widgets

    theme --> theme_src[src]
    theme_src --> theme_cubit
    theme_src --> theme_data

    resources --> src
    src --> arb
    src --> fonts
    src --> images

    main_files --> |files| main_list[main_common.dart<br/>main_development.dart<br/>main_production.dart<br/>main_staging.dart]

    classDef default fill:#f9f,stroke:#333,stroke-width:2px;
    classDef folder fill:#bbf,stroke:#333,stroke-width:2px;
```

## Support Me

It is really hard and time-consuming to maintain and update open-source projects, so if you like my work and would like to support me, consider buying me a coffee, it will be a **GREAT MOTIVATION** for me to keep doing this work.

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/haidarmehsen)
