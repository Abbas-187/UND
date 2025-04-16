# Project Restructuring Plan

## Overview

This document outlines the plan for restructuring the UND App project to better align with clean architecture principles. We're focusing on:

1. Creating a standardized structure for all feature modules
2. Moving code from global folders to specific feature modules
3. Ensuring consistent imports across the project

## Standard Feature Module Structure

Each feature module should follow this structure:

```
feature_name/
├── data/
│   ├── datasources/
│   │   ├── remote_datasource.dart
│   │   └── local_datasource.dart
│   ├── models/
│   │   └── feature_model.dart
│   └── repositories/
│       └── feature_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── feature_entity.dart
│   ├── repositories/
│   │   └── feature_repository.dart
│   ├── usecases/
│   │   └── feature_usecases.dart
│   └── services/
│       └── feature_service.dart
└── presentation/
    ├── providers/
    │   └── feature_provider.dart
    ├── screens/
    │   └── feature_screen.dart
    └── widgets/
        └── feature_specific_widgets.dart
```

## Core Directory Improvements

- [x] Created a `di` directory with `app_providers.dart` for dependency injection
- [x] Added a `config` directory with `app_config.dart` for centralized configuration
- [x] Enhanced error handling with improved `AppException` and `Failure` classes
- [x] Improved the network layer with comprehensive error handling
- [x] Added a `storage` directory with storage services
- [x] Implemented a logging system
- [x] Enhanced utilities with `DateTimeUtils`, `StringUtils`, and `ValidationUtils`
- [x] Added reusable UI components in a `ui` directory
- [x] Created barrel files for easier imports
- [x] Added a `firebase` directory with firebase-related providers and services

## Files to Move from Global Folders to Feature Modules

### Auth Feature Module

- [x] Created/updated `auth_service.dart` in `features/auth/domain/services/`
- [x] Moved `user_model.dart` to `features/auth/data/models/` and connected it to domain entity
- [x] Move `auth_provider.dart` and `auth_provider.g.dart` to `features/auth/presentation/providers/`
- [x] Move `auth_repository.dart` and `auth_repository.g.dart` to `features/auth/domain/repositories/`
- [x] Move screens from `screens/auth/` to `features/auth/presentation/screens/`

### Milk Reception Feature Module

- [x] Move `reception_analytics_service.dart` to `features/milk_reception/domain/services/`
- [x] Move `reception_inventory_service.dart` to `features/milk_reception/domain/services/`
- [x] Move `reception_notification_service.dart` to `features/milk_reception/domain/services/`
- [x] Move `reception_inventory_provider.dart` to `features/milk_reception/presentation/providers/`

### Inventory Feature Module

- [x] Move files from `models/inventory/` to `features/inventory/data/models/`

### Home Feature Module

- [x] Move screens from `screens/home/` to `features/home/presentation/screens/`

### Other Features

For each remaining feature module:
- [ ] Ensure proper layer structure (data, domain, presentation)
- [ ] Move any related files from global folders to their proper feature module location
- [ ] Update imports across the project to reflect the new file locations

## Global Folder Cleanup

After moving files to their appropriate feature modules:

- [ ] Clean up the global `models/` directory
   - [x] `inventory/` models moved to feature module
   - [ ] Decide on `navigation_item.dart` (move to core or keep in models)
   - [ ] Remove duplicate `user_model.dart` after confirming all imports updated
- [ ] Clean up the global `providers/` directory
   - [ ] Remove duplicate `auth_provider.dart` and `auth_provider.g.dart`
   - [ ] Remove duplicate `firebase_providers.dart` and `firebase_providers.g.dart` (already in core/firebase)
   - [ ] Remove duplicate `reception_inventory_provider.dart`
- [ ] Clean up the global `repositories/` directory
   - [ ] Remove duplicate `auth_repository.dart` and `auth_repository.g.dart`
- [ ] Clean up the global `screens/` directory
   - [ ] Remove duplicate auth screens
   - [ ] Remove duplicate home screen
- [ ] Clean up the global `services/` directory
   - [ ] Remove duplicate `auth_service.dart`
   - [ ] Remove duplicate `reception_analytics_service.dart`
   - [ ] Remove duplicate `reception_inventory_service.dart`
   - [ ] Remove duplicate `reception_notification_service.dart`
- [ ] Ensure any remaining global files are truly cross-cutting concerns

## Import Updates

- [x] Updated imports in main.dart to use barrel files
- [x] Updated imports in service files to use barrel files
- [x] Updated imports in provider files to use barrel files
- [ ] Update remaining imports throughout the project to use the new file locations and barrel files

## Next Steps

1. **Cleanup Phase 1**: Remove duplicate files from global directories since imports have been updated
   - This can be done safely as searches show no code is importing from these global files
2. **Cleanup Phase 2**: Move any remaining global files that aren't cross-cutting concerns to their proper feature modules
3. **Final Verification**: Run the app and ensure everything still works correctly after restructuring
4. **Documentation**: Update any remaining documentation to reflect the new structure