# Order Management Data Layer Cleanup Plan

This document describes a foolproof, step-by-step plan to refactor and organize the `lib/features/order_management/data` layer. Follow each step in order, and verify before proceeding to the next.

## 1. Consolidate the Local Data Source

- In `lib/features/order_management/data/datasources/`, you should see two files:
  - `order_local_data_source.dart`
  - `order_local_datasource.dart`
- Choose **one** filename (we’ll keep `order_local_datasource.dart`):
  1. Delete `order_local_data_source.dart`.
  2. Search the entire feature for imports of the deleted file and update them to:
     ```dart
     import '../datasources/local/order_local_datasource.dart';
     ```
- Confirm that only a single `OrderLocalDataSource` (abstract + implementation) remains.

## 2. Split “datasources” from “services”

1. Create a new folder:
   ```
   lib/features/order_management/data/services/
   ```
2. Move these files into the new `services/` folder:
   - `order_service.dart`
   - `notification_service.dart`
   - `role_permission_service.dart`
   - `order_discussion_service.dart`
   - `order_audit_trail_service.dart`
3. Leave in `datasources/` only:
   - `order_remote_datasource.dart`
   - `order_local_datasource.dart`
4. Update imports in moved files to use relative paths:
   - e.g., `import '../datasources/…';` and `import '../services/…';` where appropriate.

## 3. Standardize & Wire Up Integrations

- In `lib/features/order_management/data/integrations/`, ensure these three files exist:
  - `inventory_integration.dart`
  - `crm_integration.dart`
  - `customer_profile_integration.dart`
- For each integration file:
  1. **If** a Riverpod provider already exists at the bottom, leave it.
  2. **If not**, add:
     ```dart
     final <serviceName>Provider = Provider<<ServiceClass>>((ref) {
       // Inject dependencies via ref.watch(...)
       return <ServiceClass>(/*…*/);
     });
     ```
- Confirm each integration is injectable via its own provider.

## 4. Consolidate All Providers into One File

1. Remove provider declarations from scattered files:
   - `data/repositories/*.dart`
   - service files
   - individual integration files (except the three you kept)
2. Open `lib/features/order_management/data/providers/order_data_layer_providers.dart` and add providers in this order:
   1. `OrderRemoteDataSource`
   2. `OrderLocalDataSource`
   3. `OrderRepository`
   4. `OrderInventoryIntegrationService` (from `inventory_integration.dart`)
   5. `CustomerProfileIntegrationService` (from `customer_profile_integration.dart`)
   6. `CrmIntegrationService`
   7. All service classes moved into `services/`
3. Use **only** relative imports in this file.

## 5. Enforce Relative Imports Everywhere

- Search for `package:und_app/features/order_management/data/` within this feature.
- Replace **all** such imports with relative paths, for example:
  ```dart
  import '../../data/models/...';
  import '../datasources/...';
  import '../services/...';
  import '../integrations/...';
  ```
- Verify that **no** `package:und_app` imports remain in the `order_management` feature code.

## 6. Clean Up the Repositories Folder

- In `lib/features/order_management/data/repositories/`, you should end up with only:
  - `order_repository_impl.dart`
  - `order_discussion_repository_impl.dart`
  - `order_audit_trail_repository_impl.dart`
- Confirm **none** of these files declare providers—they should purely implement domain interfaces.

## 7. Final Verification & Testing

1. Run `flutter analyze` and fix any import or type errors.
2. Run the app or test suite to confirm the following flows still work:
   - Fetching and caching orders
   - Creating/updating/cancelling orders
   - Discussion and audit trail features
3. Spot-check one screen in the `order_management` feature to ensure everything bootstraps correctly.

---

After completing these steps, the `order_management/data` layer will be:

- Free of duplicate files
- Clearly separated into `datasources`, `services`, `integrations`, `models`, and `repositories`
- Wired only in **one** providers file
- Using strictly **relative** imports

Pass this checklist to your assistant to guarantee a foolproof refactor.