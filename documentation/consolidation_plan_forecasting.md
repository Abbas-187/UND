---

## Forecasting Consolidation Plan (Started - April 2025)

### Key Instructions
- The final, unified forecasting code will reside under `lib/features/forecasting`, following the structure and organization of `lib2/features/forecasting` as the template.
- All unique and improved files from both `lib/features/forecasting` and `lib2/features/forecasting` will be merged into `lib/features/forecasting`, using the `lib2` structure as the template.
- If a file exists in both but is located differently, the `lib2/features/forecasting` file and its location will be used in `lib/features/forecasting`.
- All unique files from both are retained in the final structure.
- All logic/features are compared before migration; if any logic is missing in the `lib2` version, it is merged.
- After each folder (e.g., `presentation`, `domain`, `data`) is fully consolidated and migrated to `lib/features/forecasting`, the corresponding folder in `lib2/features/forecasting` will be deleted.
- Once all folders are consolidated, `lib2/features/forecasting` will be deleted entirely.
- Special care: Many forecasting files may have minor differences; careful mapping and merging is required.

---

### Progress So Far
- **Planning phase:** Directory structures and file lists for both `lib/features/forecasting` and `lib2/features/forecasting` have been reviewed. No folders have been consolidated yet.

---

### Next up
- Begin consolidation folder-by-folder, starting with `presentation`, then `domain`, then `data`.
- For each folder:
  - Compare all files for logic/features.
  - Migrate all unique/advanced files to `lib/features/forecasting` using the `lib2` structure as the template.
  - After migration, delete the corresponding folder in `lib2/features/forecasting`.
- When all folders are complete, delete `lib2/features/forecasting` entirely.

---

### Example Mapping Table (for reference)

| File/Folder                                      | Category      | Source      | Destination (Unified)                | Consolidation Approach           |
|--------------------------------------------------|--------------|-------------|--------------------------------------|----------------------------------|
| presentation/screens/forecasting_screen.dart     | UI Screen    | Both        | lib/features/forecasting/presentation/screens/ | Use lib2 version in lib          |
| domain/usecases/create_forecast_usecase.dart     | Usecase      | Both        | lib/features/forecasting/domain/usecases/      | Compare, merge if needed         |
| domain/algorithms/arima.dart                     | Algorithm    | Both        | lib/features/forecasting/domain/algorithms/    | Use lib2 version in lib          |
| data/models/forecast_model.dart                  | Model        | lib2 only   | lib/features/forecasting/data/models/          | Copy from lib2                   |
| ...                                              | ...          | ...         | ...                                  | ...                              |

---

### Next Steps
- Start with the `presentation` folder. Compare and migrate all files as per the plan.
- After each folder is migrated, delete the corresponding folder in `lib2/features/forecasting`.
- When all folders are complete, delete `lib2/features/forecasting` entirely.

--- 