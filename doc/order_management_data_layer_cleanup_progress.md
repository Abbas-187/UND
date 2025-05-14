# Order Management Data Layer Cleanup Progress

*Last updated: 2024-06-15*

## Step 1: Consolidate the Local Data Source
- [x] Delete `order_local_data_source.dart`
- [x] Update imports to `import '../datasources/local/order_local_datasource.dart';`
- [x] Confirm only one `OrderLocalDataSource` remains

## Step 2: Split "datasources" from "services"
- [x] Create `lib/features/order_management/data/services/` folder
- [x] Move `order_service.dart`
- [x] Move `notification_service.dart`
- [x] Move `role_permission_service.dart`
- [x] Move `order_discussion_service.dart`
- [x] Move `order_audit_trail_service.dart`
- [x] Ensure only `order_remote_datasource.dart` and `order_local_datasource.dart` remain in `datasources/`
- [x] Update imports in moved files to use relative paths

## Step 3: Standardize & Wire Up Integrations
- [x] Verify `inventory_integration.dart`, `crm_integration.dart`, and `customer_profile_integration.dart` exist
- [x] Add Riverpod providers in files where missing

## Step 4: Consolidate All Providers into One File
- [x] Remove provider declarations from repositories and service/integration files
- [x] Add all providers in `order_data_layer_providers.dart` in the specified order
- [x] Use only relative imports in this file

## Step 5: Enforce Relative Imports Everywhere
- [x] Replace all `package:und_app/features/order_management/data/` imports with relative paths
- [x] Verify no `package:und_app` imports remain in this feature

## Step 6: Clean Up the Repositories Folder
- [x] Confirm only the following files exist in `repositories/`:
  - `order_repository_impl.dart`
  - `order_discussion_repository_impl.dart`
  - `order_audit_trail_repository_impl.dart`
- [x] Ensure repository files declare no providers

## Step 7: Final Verification & Testing
- [ ] Run `flutter analyze` and fix any errors
- [ ] Run app or test suite and confirm order workflows
- [ ] Spot-check one screen in the `order_management` feature

---
_Update this file as you complete each task, and update the date above._ 