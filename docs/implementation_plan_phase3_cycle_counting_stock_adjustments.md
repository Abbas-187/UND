# Implementation Plan: Industrial Inventory - Phase 3: Cycle Counting & Stock Adjustments

**Document Version:** 1.0
**Date:** May 9, 2025
**Focus:** Implementing systematic cycle counting procedures and robust stock adjustment functionalities within the Inventory module.

## 1. Introduction

This document details the implementation steps for establishing Cycle Counting and Stock Adjustment processes. This initiative aims to improve inventory accuracy through regular, systematic checks (cycle counting) and provide a controlled way to manage discrepancies or other necessary adjustments (e.g., for damages, loss, found items).

**The primary goals are to enable scheduled and ad-hoc inventory counts, accurately record count results, process discrepancies leading to stock adjustments, and provide clear audit trails for all adjustments.**

## 2. Prerequisites

*   **Phase 1 (Core Inventory Excellence) Completion:** Stable `InventoryItemModel`, `InventoryBatchLotModel` (if used), `InventoryMovementModel`, and core inventory operations.
*   **ABC Classification (Optional but Recommended):** If cycle counting is to be prioritized by item value/velocity, an ABC classification mechanism (potentially from `inventory_analytics` or a basic version within `inventory`) should be available.
*   **User Roles & Permissions:** A system for managing user permissions to control who can initiate counts, enter results, approve adjustments, and perform manual adjustments.

## 3. Detailed Implementation Steps

---

### Step 3.1: Define Data Models for Cycle Counting

*   **Task:** Create new data models to manage cycle count schedules, sheets, and individual item counts.
*   **Module Involved:** `inventory`
*   **Implementation Details:**
    1.  **`CycleCountScheduleModel`:**
        *   `scheduleId` (PK)
        *   `scheduleName` (e.g., "Weekly High-Value Items", "Monthly Warehouse Section A")
        *   `creationDate`
        *   `frequency` (e.g., daily, weekly, monthly, quarterly)
        *   `nextDueDate`
        *   `itemSelectionCriteria` (e.g., ABC class, specific location, item category, velocity, random %)
        *   `status` (e.g., 'Active', 'Inactive', 'Archived')
        *   `lastGeneratedSheetId` (FK to `CycleCountSheetModel`)
    2.  **`CycleCountSheetModel`:**
        *   `sheetId` (PK)
        *   `scheduleId` (FK, if generated from a schedule)
        *   `creationDate`
        *   `assignedUserId` (User responsible for the count)
        *   `dueDate`
        *   `status` (e.g., 'Pending', 'In Progress', 'Completed', 'Processing', 'Adjusted', 'Cancelled')
        *   `warehouseId` / `locationScope` (e.g., specific zones, bins)
        *   `notes`
    3.  **`CycleCountItemModel`:** (Line items for a `CycleCountSheetModel`)
        *   `countItemId` (PK)
        *   `sheetId` (FK)
        *   `inventoryItemId` (FK)
        *   `batchLotNumber` (if applicable)
        *   `expectedQuantity` (system quantity at time of sheet generation)
        *   `countedQuantity` (nullable, entered by user)
        *   `countTimestamp`
        *   `discrepancyQuantity` (calculated: `countedQuantity - expectedQuantity`)
        *   `discrepancyReasonCodeId` (FK to a new `ReasonCodeModel` for adjustments)
        *   `status` (e.g., 'Pending Count', 'Counted', 'Requires Review', 'Adjusted')
        *   `adjustmentMovementId` (FK to `InventoryMovementModel` if an adjustment is made)
*   **Foolproof Notes:**
    *   Ensure relationships between models are clear.
    *   Consider if `expectedQuantity` should be frozen at the moment the sheet is generated to avoid issues with ongoing transactions.
*   **Verification:** Data models designed, fields defined, and relationships established.

---

### Step 3.2: Develop Cycle Count Sheet Generation Logic

*   **Task:** Create a use case/service to generate `CycleCountSheetModel` and its `CycleCountItemModel` lines based on schedules or ad-hoc requests.
*   **Module Involved:** `inventory`
*   **Implementation Details:**
    1.  **`GenerateCycleCountSheetUseCase`:**
        *   Input:
            *   `scheduleId` (optional, if based on a schedule)
            *   Ad-hoc criteria (optional, e.g., list of item IDs, location, ABC class, % of items).
            *   `assignedUserId`, `dueDate`, `warehouseId`/`locationScope`.
        *   Logic:
            *   If `scheduleId` provided, retrieve `itemSelectionCriteria` from `CycleCountScheduleModel`.
            *   Fetch relevant `InventoryItemModel` (and `InventoryBatchLotModel` if applicable) based on criteria.
                *   **ABC Classification:** If using ABC, query items by their class (e.g., count all 'A' items monthly, 'B' items quarterly).
                *   **Velocity:** Select items based on recent movement frequency.
                *   **Random Selection:** Select a random percentage of items within a location/category.
            *   For each selected item/batch:
                *   Get current `quantityOnHand` (this becomes `expectedQuantity`). **Freeze this value.**
                *   Create a `CycleCountItemModel` record.
            *   Create a `CycleCountSheetModel` record linking to the items.
            *   Update `lastGeneratedSheetId` and `nextDueDate` on `CycleCountScheduleModel` if applicable.
        *   Output: `sheetId` of the newly generated `CycleCountSheetModel`.
*   **Foolproof Notes:**
    *   The logic for selecting items needs to be robust and configurable.
    *   Freezing `expectedQuantity` is crucial for accurate discrepancy calculation.
*   **Verification:**
    *   Unit tests for `GenerateCycleCountSheetUseCase` with different criteria.
    *   Cycle count sheets are correctly generated with appropriate items and frozen expected quantities.

---

### Step 3.3: UI for Cycle Count Data Entry & Management

*   **Task:** Develop UI screens for users to view assigned cycle count sheets, enter count results, and manage sheets.
*   **Module Involved:** `inventory` (frontend/presentation layer)
*   **Implementation Details:**
    1.  **Cycle Count Dashboard/List:**
        *   Display `CycleCountSheetModel` records assigned to the user or all sheets (based on permissions).
        *   Show status, due dates, etc. Allow filtering and sorting.
    2.  **Cycle Count Sheet Detail View:**
        *   Display `CycleCountItemModel` lines for a selected sheet.
        *   Show `inventoryItemId`, `description`, `batchLotNumber`, `location`, `expectedQuantity`.
        *   Input field for `countedQuantity` for each item.
        *   Ability to save progress, mark sheet as 'Completed'.
        *   (Optional) Barcode scanning support for item identification and quick quantity entry.
    3.  **Cycle Count Sheet Management:**
        *   UI for creating ad-hoc cycle count sheets (calling `GenerateCycleCountSheetUseCase`).
        *   UI for managing schedules (`CycleCountScheduleModel` CRUD).
*   **Foolproof Notes:** User experience should be efficient for rapid data entry, especially for large sheets.
*   **Verification:** UI allows users to view sheets, enter counts, and save. Ad-hoc sheet creation and schedule management are functional.

---

### Step 3.4: Process Count Results & Create Adjustments

*   **Task:** Develop a use case to process completed cycle count sheets, identify discrepancies, and create corresponding inventory adjustments.
*   **Module Involved:** `inventory`
*   **Implementation Details:**
    1.  **Define New `InventoryMovementModel` Type:**
        *   `ADJUSTMENT_CYCLE_COUNT` (can be positive or negative quantity).
    2.  **Define `ReasonCodeModel`:**
        *   `reasonCodeId` (PK)
        *   `reasonCode` (e.g., "CC_SHRINKAGE", "CC_OVERAGE_FOUND", "DMG_WAREHOUSE")
        *   `description`
        *   `appliesTo` (e.g., 'CycleCount', 'ManualAdjustment')
    3.  **`ProcessCycleCountResultsUseCase`:**
        *   Input: `sheetId`.
        *   Logic:
            *   Retrieve `CycleCountSheetModel` and its `CycleCountItemModel` lines.
            *   Ensure sheet status is 'Completed'.
            *   For each `CycleCountItemModel` where `countedQuantity` is entered:
                *   Calculate `discrepancyQuantity = countedQuantity - expectedQuantity`.
                *   If `discrepancyQuantity != 0`:
                    *   **Approval Workflow (Conditional):** If `abs(discrepancyQuantity * itemCost)` exceeds a configurable threshold, flag the item for review/approval before adjustment. Change `CycleCountItemModel.status` to 'Requires Review'. The actual adjustment happens after approval (see Step 3.5).
                    *   If no approval needed or already approved:
                        *   Create an `InventoryMovementModel` record:
                            *   `type = ADJUSTMENT_CYCLE_COUNT`
                            *   `itemId`, `batchLotNumber`
                            *   `quantity = discrepancyQuantity` (will be negative for shrinkage, positive for overage)
                            *   `movementDate = now()`
                            *   `reasonCodeId` (from `CycleCountItemModel` or a default)
                            *   `referenceId = countItemId` or `sheetId`
                            *   `userId` (user who processed or system)
                        *   Update `InventoryItemModel.quantityOnHand` (and `InventoryBatchLotModel.quantity` if applicable) by `discrepancyQuantity`.
                        *   Update `CycleCountItemModel.status` to 'Adjusted' and store `adjustmentMovementId`.
            *   Update `CycleCountSheetModel.status` to 'Adjusted' (or 'Partially Adjusted/Requires Review').
*   **Foolproof Notes:**
    *   Ensure atomicity: inventory update and movement creation should be a single transaction per item.
    *   Clearly define how item costs are retrieved for approval thresholds.
*   **Verification:**
    *   Unit tests for `ProcessCycleCountResultsUseCase`.
    *   Discrepancies correctly identified.
    *   `ADJUSTMENT_CYCLE_COUNT` movements are created with correct quantities (positive/negative) and details.
    *   Inventory stock levels are updated accurately.

---

### Step 3.5: Approval Workflow for Large Adjustments (Optional but Recommended)

*   **Task:** Implement a mechanism for reviewing and approving significant discrepancies found during cycle counts.
*   **Module Involved:** `inventory`
*   **Implementation Details:**
    1.  **Status Updates:** `CycleCountItemModel.status` can be 'Requires Review', 'Approved', 'Rejected'.
    2.  **Approval UI:**
        *   A screen for authorized managers to view items/sheets requiring adjustment approval.
        *   Display item details, expected vs. counted, discrepancy value.
        *   Options to 'Approve' or 'Reject' adjustment (with comments).
    3.  **`ApproveCycleCountAdjustmentUseCase`:**
        *   Input: `countItemId`, `approverUserId`, `approvalDecision` (Approved/Rejected), `comments`.
        *   Logic:
            *   If 'Approved', trigger the adjustment logic from Step 3.4 for that specific item (create movement, update stock).
            *   Update `CycleCountItemModel.status` and log approval details.
            *   If 'Rejected', update status and log. No stock adjustment is made; item might need recounting or investigation.
*   **Foolproof Notes:** Clearly define roles and permissions for approval.
*   **Verification:** Approval workflow functions correctly; adjustments are only posted after approval if required.

---

### Step 3.6: Generic Stock Adjustment Functionality

*   **Task:** Create a use case and UI for ad-hoc manual stock adjustments (e.g., for damages, loss, found items, initial stock loading).
*   **Module Involved:** `inventory`
*   **Implementation Details:**
    1.  **Define New `InventoryMovementModel` Type:**
        *   `ADJUSTMENT_MANUAL` (can be positive or negative).
    2.  **`PerformManualStockAdjustmentUseCase`:**
        *   Input:
            *   `inventoryItemId`
            *   `batchLotNumber` (if applicable)
            *   `adjustmentQuantity` (positive for increase, negative for decrease)
            *   `reasonCodeId` (FK to `ReasonCodeModel` - e.g., "DAMAGED_GOODS", "THEFT_LOSS", "STOCK_FOUND", "INITIAL_BALANCE")
            *   `referenceNotes` (e.g., damage report number, explanation)
            *   `userId` (performing the adjustment)
        *   Logic:
            *   Validate inputs (e.g., ensure sufficient stock for negative adjustments if not allowing negative inventory).
            *   **Approval Workflow (Optional):** Similar to cycle count adjustments, large manual adjustments might require approval.
            *   Create an `InventoryMovementModel` record:
                *   `type = ADJUSTMENT_MANUAL`
                *   `itemId`, `batchLotNumber`
                *   `quantity = adjustmentQuantity`
                *   `movementDate = now()`
                *   `reasonCodeId`, `notes = referenceNotes`
                *   `userId`
            *   Update `InventoryItemModel.quantityOnHand` (and `InventoryBatchLotModel.quantity`) by `adjustmentQuantity`.
        *   Output: `movementId`.
    3.  **Manual Stock Adjustment UI:**
        *   A form for authorized users to perform manual adjustments.
        *   Fields for item selection, batch/lot, quantity, reason code, notes.
        *   Calls `PerformManualStockAdjustmentUseCase`.
*   **Foolproof Notes:**
    *   Reason codes are essential for tracking why manual adjustments are made.
    *   Permissions for manual adjustments should be tightly controlled.
*   **Verification:**
    *   Manual adjustments correctly update stock and create `ADJUSTMENT_MANUAL` movements.
    *   Reason codes are captured.

---

### Step 3.7: Reporting on Adjustments & Discrepancies

*   **Task:** Develop reports to provide insights into cycle count accuracy and stock adjustment history.
*   **Module Involved:** `inventory` (reporting/analytics layer)
*   **Implementation Details:**
    1.  **Cycle Count Accuracy Report:**
        *   Metrics: Count accuracy (by items, by value), average discrepancy, common discrepancy reasons.
        *   Filters: Date range, warehouse, item category, schedule.
    2.  **Stock Adjustment History Report:**
        *   List all `ADJUSTMENT_CYCLE_COUNT` and `ADJUSTMENT_MANUAL` movements.
        *   Details: Item, quantity, date, user, reason code, reference.
        *   Filters: Date range, adjustment type, reason code, user, item.
*   **Foolproof Notes:** Reports should help identify trends, problem areas, or items needing more frequent counts.
*   **Verification:** Reports are accurate and provide useful insights.

---

### Step 3.8: API/Service Layer Definition & Implementation

*   **Task:** Define and implement necessary API contracts or service layer methods.
*   **Modules Involved:** `inventory`
*   **Implementation Details:**
    *   Expose use cases defined above (`GenerateCycleCountSheetUseCase`, `ProcessCycleCountResultsUseCase`, `ApproveCycleCountAdjustmentUseCase`, `PerformManualStockAdjustmentUseCase`) via a service layer if accessed by other internal modules or for consistency.
    *   Services for querying cycle count data, schedules, and adjustment history for reporting.
*   **Verification:** Service layer is well-defined and testable.

---

### Step 3.9: Comprehensive Testing & Quality Assurance

*   **Task:** Conduct thorough testing of all cycle counting and adjustment functionalities.
*   **Implementation Details:**
    1.  **Unit Tests:** For all new use cases, models, and services.
    2.  **Integration Tests:**
        *   Sheet generation -> Data entry -> Processing -> Adjustment creation -> Stock update.
        *   Manual adjustment -> Stock update.
        *   Approval workflows.
    3.  **End-to-End (E2E) Scenarios:**
        *   Full cycle count process for various item selection criteria.
        *   Manual adjustments for different reasons (damage, found, initial).
        *   Reporting accuracy.
    4.  **User Acceptance Testing (UAT):** Involve warehouse managers, inventory controllers, finance (for impact of adjustments).
*   **Verification:** All test cases passed, UAT sign-off.

---

### Step 3.10: Documentation Updates & Team Training

*   **Task:** Update documentation and train relevant teams.
*   **Implementation Details:**
    1.  **Technical Documentation:** Data models, use case logic, API endpoints, adjustment movement types.
    2.  **User Documentation:** How to create count schedules, generate sheets, enter counts, process results, handle approvals, perform manual adjustments, use reports.
    3.  **Team Training:** For warehouse staff, inventory controllers, managers.
*   **Verification:** Documentation reviewed, training completed.

---

### Step 3.11: Deployment & Post-Deployment Monitoring

*   **Task:** Plan and execute deployment, and monitor post-deployment.
*   **Implementation Details:**
    1.  **Deployment Plan.**
    2.  **Initial Configuration:** Set up reason codes, approval thresholds, initial cycle count schedules.
    3.  **Monitoring:** Track cycle count completion rates, adjustment frequencies, discrepancy trends. Monitor system performance during sheet generation and processing.
*   **Verification:** Successful deployment, stable operation, processes functioning as intended.

## 4. Definition of Done (DoD) for Cycle Counting & Stock Adjustments

*   Data models for cycle counting (`CycleCountScheduleModel`, `CycleCountSheetModel`, `CycleCountItemModel`) and `ReasonCodeModel` are implemented.
*   Cycle count sheets can be generated based on schedules or ad-hoc criteria, with expected quantities frozen.
*   UI for cycle count data entry and management is functional.
*   `ProcessCycleCountResultsUseCase` correctly identifies discrepancies and creates `ADJUSTMENT_CYCLE_COUNT` movements, updating stock levels.
*   Approval workflow for large adjustments is implemented (if applicable).
*   `PerformManualStockAdjustmentUseCase` and UI allow for ad-hoc adjustments with `ADJUSTMENT_MANUAL` movements and reason codes.
*   Reporting on cycle count accuracy and adjustment history is available.
*   All new APIs/services are documented and tested.
*   Comprehensive E2E testing and UAT are completed and signed off.
*   Relevant documentation is updated, and teams are trained.
*   The system is successfully deployed and monitored.

## 5. Roles & Responsibilities (Example - To be filled by Project Lead)

*   **Project Lead/Manager:** (Name)
*   **Lead Developer (Inventory):** (Name)
*   **Inventory Module Team:** (Names)
*   **QA Lead/Team:** (Name/s)
*   **Stakeholders (Warehouse Management, Inventory Control, Finance):** (Names) - UAT, process validation.

## 6. Communication Plan

*   Regular meetings with warehouse and inventory control teams to refine processes.
*   Workshops to define reason codes, approval thresholds, and reporting needs.
*   Shared documentation and issue tracking.

---

This plan provides a detailed guide for implementing Cycle Counting and Stock Adjustments. These processes are fundamental for maintaining accurate inventory records and operational efficiency.
