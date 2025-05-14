---

## Inventory Consolidation Plan (Updated - April 19, 2025)

### Key Instructions
- The final, unified inventory code will reside under `lib/features/inventory`, following the structure and organization of `lib2/features/inventory` as the template.
- All unique and improved files from both `lib` and `lib2` will be merged into `lib/features/inventory`, using the `lib2` structure as the template.
- After each folder (e.g., data, domain, etc.) is fully consolidated and migrated to `lib`, the corresponding folder in `lib2` will be deleted.
- Once all folders are consolidated, `lib2/features/inventory` will be deleted entirely.
- If a file exists in both but is located differently, the `lib2` file and its location will be used in `lib`.
- All unique files from both `lib` and `lib2` are retained in the final structure.
- All logic/features are compared before migration; if any logic is missing in the `lib2` version, it is merged.

---

## Updated Instructions (April 19, 2025)

- The final, unified inventory code will reside under `lib/features/inventory`, but the structure and organization will follow `lib2/features/inventory` as the template.
- All unique and improved files from both `lib` and `lib2` will be merged into `lib/features/inventory`, using the `lib2` structure as the template.
- After each folder (e.g., data, domain, etc.) is fully consolidated and migrated to `lib`, the corresponding folder in `lib2` will be deleted.
- Once all folders are consolidated, `lib2/features/inventory` will be deleted entirely.
- If a file exists in both but is located differently, the `lib2` file and its location will be used in `lib`.
- All unique files from both `lib` and `lib2` are retained in the final structure.
- All logic/features are compared before migration; if any logic is missing in the `lib2` version, it is merged.
- After each folder is consolidated and migrated, immediately delete the corresponding folder in `lib2`.

---

### Progress So Far
- **Domain folder**: Fully consolidated. All unique and advanced files from each subfolder in `lib2/features/inventory/domain` have been migrated to `lib/features/inventory/domain`, following the `lib2` structure as the template. The original `lib2/features/inventory/domain` folder has been deleted.
- **Data folder**: Fully consolidated. All models, providers, and repositories from `lib2/features/inventory/data` have been copied to `lib/features/inventory/data`, including all unique and advanced files. The `providers` folder was created in `lib` as needed. The original `lib2/features/inventory/data` folder has been deleted.
- **Models folder**: Fully consolidated. All unique and advanced files from each subfolder in `lib2/features/inventory/models` have been migrated to `lib/features/inventory/models`, following the `lib2` structure as the template. The original `lib2/features/inventory/models` folder has been deleted.
- **Presentation folder**: Fully consolidated. All unique and advanced files from each subfolder in `lib2/features/inventory/presentation` (including `screens`, `widgets`, and `providers`) have been migrated to `lib/features/inventory/presentation`, following the `lib2` structure as the template. The original `lib2/features/inventory/presentation` folder has been deleted.

---

### Next up
- **Final cleanup:** Delete the entire `lib2/features/inventory` folder if all subfolders are confirmed consolidated.
- Review for any remaining unique files or documentation in `lib2/features/inventory` that have not yet been migrated.

---

### Example Mapping Table (for reference)

| File/Folder                                 | Category      | Source                | Destination (Unified)                | Consolidation Approach                 |
|---------------------------------------------|--------------|-----------------------|--------------------------------------|----------------------------------------|
| data/models/batch_model.dart                | Data Model   | Both                  | lib/features/inventory/data/models/   | Use lib2 version in lib                |
| data/models/inventory_item_model_extensions.dart | Data Model   | lib2 only             | lib/features/inventory/data/models/   | Copy from lib2                        |
| data/repositories/inventory_repository.dart | Data Repo    | Both                  | lib/features/inventory/data/repositories/ | Use lib2 version in lib           |
| ...                                         | ...          | ...                   | ...                                  | ...                                    |

---

### Next Steps
- Continue folder-by-folder consolidation for any remaining folders, always using the `lib2` structure as the template and migrating all unique/advanced files to `lib`.
- After each folder is migrated, delete the corresponding folder in `lib2`.
- When all folders are complete, delete `lib2/features/inventory` entirely.

---