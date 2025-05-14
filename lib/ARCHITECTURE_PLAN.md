# Feature-First Modular Architecture Plan

## 1. Folder Structure

- lib/
  - features/
    - <feature_name>/
      - data/
        - datasources/
        - repositories/
        - models/
      - domain/
        - entities/
        - usecases/
      - presentation/
        - screens/
        - widgets/
        - providers/
  - core/           # App-wide utilities, base classes, error handling, DI
  - shared/         # Widgets, helpers, styles reused across features
  - l10n/           # Localization
  - theme/          # Theming
  - main.dart       # App entry point

## 2. Migration Steps

1. Identify all features in the app (e.g., auth, orders, inventory, etc.).
2. For each feature, create a folder under lib/features/<feature_name>.
3. Move related screens, widgets, models, providers, and services into the appropriate feature folder.
4. Move business logic, entities, and use cases to domain/ inside each feature.
5. Move data sources, repositories, and models to data/ inside each feature.
6. Place app-wide utilities and base classes in core/.
7. Place shared widgets and helpers in shared/.
8. Refactor imports to use the new structure.
9. Update test/ to mirror the lib/features structure.
10. Document the structure and guidelines in README.md.

## 3. File Conflict & Overwriting Policy

- Before moving or creating any file, always check if a file with the same name already exists in the target location.
- If a file already exists, compare both files:
  - If one is clearly better (more complete, up-to-date, or follows best practices), keep the better one and delete the other.
  - If both have unique content, merge them to retain all valuable code, then delete the redundant file.
- Never overwrite files blindly—always review and resolve conflicts manually.
- Document any file merges or deletions in the migration log or commit messages for traceability.

## 4. Best Practices

- Each feature is self-contained and only exposes what is necessary.
- Features depend on core, shared, and domain, but not on each other.
- Use dependency injection for services and repositories.
- Keep UI, domain, and data layers separated within each feature.
- Use shared/ only for truly reusable code.

## 5. Example Feature Structure

lib/features/orders/
  data/
    datasources/
    repositories/
    models/
  domain/
    entities/
    usecases/
  presentation/
    screens/
    widgets/
    providers/

## 6. Next Steps

- Start with one feature as a pilot for migration.
- Gradually refactor other features.
- Continuously update documentation and tests.
- Maintain a migration log to track file moves, merges, and deletions.
