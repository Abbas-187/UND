# Implementation Plan: Industrial Inventory - Phase 3: Inventory Quality Control

**Document Version:** 1.0
**Date:** May 9, 2025
**Focus:** Integrating quality control (QC) processes with the Inventory module, enabling management of items based on their quality status, and linking with factory QC procedures.

## 1. Introduction

This document outlines the implementation steps for establishing robust Inventory Quality Control. This involves enhancing inventory models to track quality statuses, integrating with the factory's quality control outcomes, and ensuring that inventory operations respect these statuses. This will improve visibility into stock quality and prevent the use or dispatch of non-conforming items.

**The primary goals are to accurately reflect the quality status of inventory items and batches, ensure that only 'Available' stock is used for fulfillment or further production, and provide tools for managing quality status changes.**

This plan specifically considers integration with the `record_quality_control_usecase.dart` from the `factory` module.

## 2. Prerequisites

*   **Phase 1 (Core Inventory Excellence) Completion:** Stable `InventoryItemModel`, `InventoryBatchLotModel`, `InventoryMovementModel`, and core inventory operations.
*   **Phase 2 (Production Integration) Completion:** Understanding of how finished goods are reported from production (as per `implementation_plan_phase2_production_integration.md`), as QC often follows production.
*   **Factory Module (`factory`):** A functional `record_quality_control_usecase.dart` (or similar) that determines the quality outcome of produced or received items.
*   **Defined Quality Statuses:** A clear, agreed-upon list of quality statuses and their meanings (e.g., 'Available', 'Pending Inspection', 'Rejected', 'Rework', 'Blocked').

## 3. Detailed Implementation Steps

---

### Step 3.1: Define Quality Statuses & Enhance Inventory Models

*   **Task:** Finalize the list of quality statuses and add a `qualityStatus` field to relevant inventory models.
*   **Module Involved:** `inventory`
*   **Implementation Details:**
    1.  **Define Standard Quality Statuses (Enum/Constants):**
        *   `AVAILABLE`: Fit for use/sale.
        *   `PENDING_INSPECTION`: Awaiting QC assessment (e.g., newly received goods, newly produced goods before final QC).
        *   `REJECTED`: Failed QC, not usable, potentially for scrap/disposal.
        *   `REWORK`: Failed QC but can be reworked to become 'Available'.
        *   `BLOCKED`: Temporarily not usable for other reasons (e.g., recall, investigation).
        *   *(Consult with stakeholders to finalize this list)*
    2.  **Enhance `InventoryItemModel` (e.g., in `lib/features/inventory/domain/models/inventory_item_model.dart`):**
        *   While individual batches/lots will primarily hold the quality status, the `InventoryItemModel` might have a default initial quality status for new items if not batch/lot tracked, or an aggregated view (though less common for QC).
        *   Consider if any item-level QC parameters are needed.
    3.  **Enhance `InventoryBatchLotModel` (e.g., in `lib/features/inventory/domain/models/inventory_batch_lot_model.dart`):**
        *   Add `String qualityStatus` (or an Enum type based on the defined statuses). This is the primary location for tracking the quality of a specific batch/lot.
        *   Add `DateTime? lastQualityStatusUpdateTimestamp`.
        *   Add `String? lastQualityUpdateReason` (e.g., "Post-Production QC", "Manual Override", "Return Inspection").
*   **Foolproof Notes:**
    *   Ensure the chosen quality statuses cover all necessary scenarios for the business.
    *   The `qualityStatus` on `InventoryBatchLotModel` is critical. For non-batch-tracked items, a similar field might be needed directly on a more granular stock record if `InventoryItemModel` is too high-level.
*   **Verification:** Models updated, quality statuses defined and accessible.

---

### Step 3.2: Implement Quality Status Update Service & Movement Type

*   **Task:** Create a service in the Inventory module to handle quality status changes and a new inventory movement type to log these changes.
*   **Module Involved:** `inventory`
*   **Implementation Details:**
    1.  **Define New `InventoryMovementModel` Type:**
        *   Add `QUALITY_UPDATE` to the `InventoryMovementType` enum/constants.
    2.  **Create `UpdateInventoryQualityStatusUseCase` (Inventory Module):**
        *   Input:
            *   `inventoryItemId`
            *   `batchLotNumber` (if applicable)
            *   `newQualityStatus` (from the defined statuses)
            *   `quantityAffected` (usually the full batch/lot quantity, but could be partial for some scenarios if business rules allow splitting a batch by quality – complex, avoid if possible)
            *   `reason` (e.g., "Post-Production QC", "Manual Change", "Return Inspection")
            *   `referenceDocumentId` (e.g., Factory QC Record ID, Manual Change Authorization ID)
            *   `userId` (who performed/authorized the change)
        *   Logic:
            *   Validate inputs.
            *   Find the target `InventoryBatchLotModel` (or relevant stock record).
            *   Update its `qualityStatus`, `lastQualityStatusUpdateTimestamp`, and `lastQualityUpdateReason`.
            *   Create an `InventoryMovementModel` of type `QUALITY_UPDATE`:
                *   `itemId`, `batchLotNumber`.
                *   `quantity` should reflect the quantity whose status changed. Typically, this movement type might not change overall stock quantity but logs the status transition. The `fromQualityStatus` and `toQualityStatus` could be stored in `InventoryMovementItemModel` custom fields or the movement's `notes`.
                *   Store `reason`, `referenceDocumentId`, `userId`.
            *   **Crucially, this use case does NOT change the physical quantity on hand.** It only changes the *status* of existing quantity.
            *   Return success/failure.
*   **Foolproof Notes:**
    *   Ensure `QUALITY_UPDATE` movements are auditable and clearly show the transition from one status to another.
    *   Decide if a single batch can have multiple quality statuses (e.g. 8 units 'Available', 2 units 'Rejected' within the same batch). This adds significant complexity; prefer keeping a batch to a single status if possible.
*   **Verification:**
    *   Unit tests for `UpdateInventoryQualityStatusUseCase`.
    *   `InventoryMovementModel` of type `QUALITY_UPDATE` is correctly created and logs all relevant details.
    *   `InventoryBatchLotModel` quality status is updated.

---

### Step 3.3: Integrate with Factory Quality Control (`record_quality_control_usecase.dart`)

*   **Task:** Enable the factory module to update the quality status of inventory items/batches based on its QC results.
*   **Modules Involved:** `inventory`, `factory`
*   **Implementation Details:**
    1.  **Factory Module (`record_quality_control_usecase.dart` or similar):**
        *   After the factory performs its QC checks (e.g., on finished goods from production, or on received raw materials if factory does incoming QC):
            *   It determines the `inventoryItemId`, `batchLotNumber` (if applicable), the `quantityInspected`, and the `qcOutcome` (e.g., 'Passed', 'Failed-Rework', 'Failed-Reject').
            *   It will map its internal `qcOutcome` to the Inventory module's standard `qualityStatus` values (e.g., 'Passed' -> 'AVAILABLE', 'Failed-Rework' -> 'REWORK', 'Failed-Reject' -> 'REJECTED').
            *   It will then call the `UpdateInventoryQualityStatusUseCase` in the Inventory module, providing the mapped status, item/batch details, quantity, a reason like "Factory QC Result", and a reference to its QC record.
    2.  **Initial Status of Goods Entering Inventory from Production:**
        *   When finished goods are first reported from production (Phase 2 integration via `ReceiveFinishedGoodsFromProductionUseCase`), they should ideally enter inventory with an initial status like `PENDING_INSPECTION` if factory QC is a separate step *after* they are recorded in inventory.
        *   If factory QC is integral to the production completion reporting, the `ReceiveFinishedGoodsFromProductionUseCase` could directly take the `qualityStatus` from the factory as an input.
        *   **Decision Point:** Clarify if goods are in inventory *before* factory QC, or if factory QC is the gate *to* inventory.
*   **Foolproof Notes:**
    *   Ensure clear mapping between factory QC outcomes and inventory quality statuses.
    *   The timing of the status update is crucial. If goods are in `PENDING_INSPECTION` status, they should not be allocatable.
*   **Verification:**
    *   Integration Test: Factory completes QC -> `UpdateInventoryQualityStatusUseCase` is called -> `InventoryBatchLotModel` status is updated, and a `QUALITY_UPDATE` movement is logged.
    *   Test different QC outcomes (Pass, Fail-Rework, Fail-Reject).

---

### Step 3.4: Modify Inventory Logic to Respect Quality Status

*   **Task:** Ensure core inventory operations (allocation, dispatch, picking, stock lookups) consider the `qualityStatus`.
*   **Module Involved:** `inventory`
*   **Implementation Details:**
    1.  **Allocation Logic (e.g., for Sales Orders, Production Orders):**
        *   When checking for available stock or allocating stock, modify use cases (e.g., `AllocateStockToOrderUseCase`) to only consider items/batches with `qualityStatus == 'AVAILABLE'`.
        *   The definition of "available quantity" should now filter by this status.
    2.  **Dispatch/Picking Logic:**
        *   Picking lists and dispatch processes must only allow selection of items/batches with `qualityStatus == 'AVAILABLE'`.
    3.  **Stock Queries/Lookups:**
        *   Enhance services that provide stock information (e.g., `GetItemStockLevelUseCase`) to allow filtering by `qualityStatus` or to return quantities broken down by status.
    4.  **Physical Count / Adjustments:**
        *   When performing stock counts or adjustments, the `qualityStatus` of the counted/adjusted stock should be recorded or considered.
*   **Foolproof Notes:** This is a critical step. Missing any stock-consuming or stock-reporting process can lead to operational errors.
*   **Verification:**
    *   Test that allocation for sales orders fails or skips items that are not 'AVAILABLE'.
    *   Test that production orders cannot consume materials that are not 'AVAILABLE'.
    *   Verify that stock reports and lookups can correctly show quantities by quality status.

---

### Step 3.5: UI/UX for Quality Management

*   **Task:** Provide UI elements for viewing stock by quality status and for manually changing quality status (with appropriate permissions).
*   **Module Involved:** `inventory` (frontend/presentation layer)
*   **Implementation Details:**
    1.  **Stock Viewing Screens:**
        *   Display `qualityStatus` in inventory item detail screens, batch/lot detail screens, and stock overview lists.
        *   Allow filtering and grouping by `qualityStatus` in stock reports.
    2.  **Manual Quality Status Change Screen/Dialog:**
        *   Create a UI for authorized users to manually change the `qualityStatus` of an item/batch.
        *   Inputs: `itemId`, `batchLotNumber`, `newQualityStatus`, `reason`, `reference` (optional).
        *   This UI will call the `UpdateInventoryQualityStatusUseCase`.
        *   **Permissions:** Implement role-based access control to restrict who can perform manual quality status changes.
*   **Foolproof Notes:** Manual changes should be audited thoroughly. Ensure users provide a reason for manual changes.
*   **Verification:** UI correctly displays quality statuses. Manual change functionality works and is permission-controlled.

---

### Step 3.6: API/Service Layer Definition & Implementation

*   **Task:** Define and implement necessary API contracts or service layer methods.
*   **Modules Involved:** `inventory`, `factory`
*   **Implementation Details:**
    1.  **Inventory Module Services Exposed:**
        *   `UpdateInventoryQualityStatusUseCase` (as defined in Step 3.2) - to be called by `factory` and internal UI.
        *   Services for querying stock that include `qualityStatus` filters/outputs.
    2.  **Factory Module (Calls to Inventory):**
        *   `record_quality_control_usecase.dart` will call `UpdateInventoryQualityStatusUseCase`.
    3.  **Data Transfer Objects (DTOs):** For requests and responses related to quality updates.
*   **Verification:** API contracts reviewed, services testable.

---

### Step 3.7: Comprehensive Testing & Quality Assurance

*   **Task:** Conduct thorough testing of all QC-related functionalities.
*   **Implementation Details:**
    1.  **Unit Tests:** For all new/modified use cases and services.
    2.  **Integration Tests:**
        *   Factory QC -> Inventory status update.
        *   Manual status change -> Inventory status update and movement log.
        *   Allocation/dispatch logic correctly respecting statuses.
    3.  **End-to-End (E2E) Scenarios:**
        *   Full cycle: Item received/produced -> Enters `PENDING_INSPECTION` -> Factory QC updates to `AVAILABLE` -> Item allocated to sales order.
        *   Item received/produced -> Enters `PENDING_INSPECTION` -> Factory QC updates to `REJECTED` -> Item cannot be allocated.
        *   Manual change from `AVAILABLE` to `BLOCKED` -> Item becomes unavailable for allocation.
    4.  **User Acceptance Testing (UAT):** Involve QC personnel, warehouse managers, production supervisors.
*   **Verification:** All test cases passed, UAT sign-off.

---

### Step 3.8: Documentation Updates & Team Training

*   **Task:** Update documentation and train relevant teams.
*   **Implementation Details:**
    1.  **Technical Documentation:** Updated data models, `QUALITY_UPDATE` movement type, service APIs, integration points with `factory`.
    2.  **User Documentation:** SOPs for QC processes, how to view stock by quality, how to perform manual status changes (for authorized users), implications of different statuses.
    3.  **Team Training:** For QC staff, warehouse staff, production staff.
*   **Verification:** Documentation reviewed, training completed.

---

### Step 3.9: Deployment & Post-Deployment Monitoring

*   **Task:** Plan and execute deployment, and monitor post-deployment.
*   **Implementation Details:**
    1.  **Deployment Plan:** Coordinate deployment of changes in `inventory` and `factory` modules.
    2.  **Data Migration (if applicable):** If there's existing stock, a plan to set initial quality statuses might be needed.
    3.  **Monitoring:** Track the flow of items through different quality statuses, accuracy of status updates, and ensure operational processes correctly adhere to status constraints.
*   **Verification:** Successful deployment, stable operation, QC processes functioning as expected.

## 4. Definition of Done (DoD) for Inventory Quality Control

*   Inventory models (`InventoryBatchLotModel`, potentially `InventoryItemModel`) are enhanced with `qualityStatus` and related fields.
*   A defined list of quality statuses is implemented.
*   The `UpdateInventoryQualityStatusUseCase` and `QUALITY_UPDATE` movement type are implemented and functional.
*   The `factory` module (via `record_quality_control_usecase.dart`) successfully updates inventory quality statuses.
*   Core inventory operations (allocation, dispatch, queries) correctly respect item/batch quality statuses, only using 'AVAILABLE' stock for fulfillment.
*   UI for viewing stock by quality status and for authorized manual status changes is implemented.
*   All new APIs/services are documented and tested.
*   Comprehensive E2E testing and UAT are completed and signed off.
*   Relevant documentation is updated, and teams are trained.
*   The system is successfully deployed and monitored.

## 5. Roles & Responsibilities (Example - To be filled by Project Lead)

*   **Project Lead/Manager:** (Name)
*   **Lead Developer (Inventory):** (Name)
*   **Lead Developer (Factory):** (Name)
*   **Inventory Module Team:** (Names)
*   **Factory Module Team:** (Names)
*   **QA Lead/Team:** (Name/s)
*   **Stakeholders (QC Department, Warehouse Management, Production):** (Names) - UAT, process validation.

## 6. Communication Plan

*   Regular joint meetings between Inventory and Factory development teams.
*   Workshops with QC personnel and warehouse managers to define statuses and workflows.
*   Shared documentation and issue tracking.

---

This plan provides a detailed guide for implementing Inventory Quality Control. Clear definition of quality statuses and seamless integration with factory QC processes are key to its success.
