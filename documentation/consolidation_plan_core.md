---

## Core Consolidation Plan (Started - April 2025)

### Key Instructions
- The final, unified core code will reside under `lib/core`, following the structure and organization of `lib2/core` as the template.
- All unique and improved files from both `lib` and `lib2` will be merged into `lib/core`, using the `lib2/core` structure as the template.
- If a file exists in both but is located differently, the `lib2/core` file and its location will be used in `lib/core`.
- All unique files from both `lib` and `lib2` are retained in the final structure.
- All logic/features are compared before migration; if any logic is missing in the `lib2` version, it is merged.
- After each folder (e.g., widgets, utils, services, etc.) is fully consolidated and migrated to `lib/core`, the corresponding folder in `lib2/core` will be deleted.
- Once all folders are consolidated, `lib2/core` will be deleted entirely.
- Special care: Many core files in `lib` are scattered or duplicated; careful mapping and merging is required.

---

### Progress So Far
- **Planning phase:** Directory structures and file lists for both `lib/core` and `lib2/core` have been reviewed. No folders have been consolidated yet.

---

### Next up
- Begin consolidation folder-by-folder, starting with `widgets`, then `utils`, `services`, `network`, `layout`, `auth`, `routes`, `exceptions`, `di`, `config`, `logging`, `firebase`, and `ui`.
- For each folder:
  - Compare all files for logic/features.
  - Migrate all unique/advanced files to `lib/core` using the `lib2/core` structure as the template.
  - After migration, delete the corresponding folder in `lib2/core`.
- When all folders are complete, delete `lib2/core` entirely.

---

### Example Mapping Table (for reference)

| File/Folder                        | Category   | Source      | Destination (Unified)   | Consolidation Approach           |
|------------------------------------|------------|-------------|-------------------------|----------------------------------|
| widgets/primary_button.dart        | Widget     | Both        | lib/core/widgets/       | Use lib2 version in lib          |
| utils/validation_utils.dart        | Utils      | lib2 only   | lib/core/utils/         | Copy from lib2                   |
| services/firestore_service.dart    | Service    | Both        | lib/core/services/      | Compare, merge if needed         |
| network/api_client.dart            | Network    | Both        | lib/core/network/       | Use lib2 version in lib          |
| ...                                | ...        | ...         | ...                     | ...                              |

---

### Next Steps
- Start with the `widgets` folder. Compare and migrate all files as per the plan.
- After each folder is migrated, delete the corresponding folder in `lib2/core`.
- When all folders are complete, delete `lib2/core` entirely.

--- 