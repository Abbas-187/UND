# Implementation Plan: Industrial Inventory - Phase 2: Production/Manufacturing Module Integration

**Document Version:** 1.0
**Date:** May 9, 2025
**Focus:** Deep integration between the Inventory module and the Production/Manufacturing module (within `lib/features/factory`) to accurately track raw material consumption and finished goods output.

## 1. Introduction

This document outlines the detailed implementation steps for integrating the Inventory module with your Production/Manufacturing processes, managed within the `lib/features/factory/production` directory. This integration is essential for maintaining accurate inventory levels by recording the consumption of raw materials used in production and the creation of finished goods.

**The primary goals are to ensure that raw material stock is depleted correctly as it's consumed by production, and that newly manufactured finished goods are accurately added to inventory with appropriate costing and batch/lot information.**

This plan assumes that a "Production Execution" (likely managed by use cases such as `create_production_execution.dart` and `update_production_execution_status.dart`) is the operational representation of a `ProductionOrderModel`.

## 2. Prerequisites

*   **Phase 1 (FIFO/LIFO Costing) Completion (Highly Recommended):** This is crucial for the Inventory module to provide accurate costs for consumed raw materials and to correctly value finished goods if their cost is based on material costs.
*   **Defined Production Lifecycle:** A clear understanding of the production workflow within the `factory` module (e.g., creation of production execution, status updates like "In Progress", completion).
*   **Key Factory Models Understood:**
    *   `ProductionOrderModel` (in `lib/features/factory/models/`): Contains `id`, `scheduledDate`, and `List<MaterialModel> requiredMaterials`.
    *   `MaterialModel` (in `lib/features/factory/models/`): Contains `materialId` and `requiredQuantity` for a specific production order.
*   **Inventory Module Stability:** Core inventory functionalities are stable.
*   **API/Service Layer Design:** Both Inventory and Factory modules should expose clear services or APIs for inter-module communication.
*   **Development Environment & Version Control:** Standard setup.

## 3. Detailed Implementation Steps

---

### Step 3.1: Raw Material Consumption / Issuance to Production

*   **Task:** Implement the process where the initiation or progress of a production execution triggers the deduction of required raw materials from the Inventory module.
*   **Modules Involved:** `inventory`, `factory` (specifically `factory/production`)
*   **Implementation Details:**
    1.  **Trigger Point Identification (Responsibility: `factory` module team):**
        *   Determine the exact use case and status change within the `factory/production` workflow that signifies raw materials should be issued/consumed.
        *   **Assumption:** This might occur when `update_production_execution_status.dart` changes a production execution to "In Progress", or as part of `track_batch_process_usecase.dart` if materials are consumed in stages. For this plan, we'll assume a primary trigger point (e.g., status change to "In Progress").
    2.  **Data to be Passed from `factory` to `inventory` for consumption:**
        *   `productionOrderId` (or `productionExecutionId`)
        *   A list of materials to consume, derived from `ProductionOrderModel.requiredMaterials`. Each item in this list should specify:
            *   `inventoryItemId` (mapping from `MaterialModel.materialId`)
            *   `quantityToConsume` (from `MaterialModel.requiredQuantity`)
    3.  **Inventory Module Service/UseCase (`IssueMaterialsToProductionUseCase`):**
        *   Input: `productionOrderId`, list of `{inventoryItemId, quantityToConsume}`.
        *   Logic:
            *   For each material to consume:
                *   Check available stock for the `inventoryItemId`.
                *   Determine which batch(es) to issue from, following FIFO/FEFO rules (this is internal Inventory logic).
                *   Calculate the cost of the issued material based on the consumed batch(es) and the Inventory module's costing method (FIFO/LIFO from Phase 1). This is the `costAtTransaction` for this issuance.
                *   Create an outbound `InventoryMovementModel` (Type: `PRODUCTION_ISSUE`).
                *   The `InventoryMovementItemModel` should record `itemId`, `quantity` issued, `batchLotNumber` (of the consumed inventory), `productionDate` and `expirationDate` (of the consumed batch), and the calculated `costAtTransaction`.
                *   Link to `productionOrderId` in `referenceDocuments`.
            *   Return a list of `{inventoryItemId, quantityIssued, actualCostIncurred}` back to the `factory` module. This is important if the factory module needs to accumulate actual material costs for the production order.
            *   Handle partial issuance or insufficient stock scenarios (e.g., raise an alert, block production start, or allow partial start based on business rules).
    4.  **Factory Module Update:**
        *   The calling use case in `factory` (e.g., `update_production_execution_status.dart`) receives the confirmation and actual costs from Inventory.
        *   The `factory` module may store these actual material costs against its production execution record for later use in calculating finished good costs.
*   **Foolproof Notes:**
    *   **Material ID Mapping:** Ensure a robust mapping between `MaterialModel.materialId` (from `factory`) and the actual `InventoryItem.id` in the Inventory module.
    *   **Timing of Consumption:** Consume materials from inventory as close to the actual point of use in production as possible to maintain accuracy. If consumption is staged, this integration might need to be called multiple times by `track_batch_process_usecase.dart`.
    *   **Cost Feedback Loop:** The cost of materials consumed, as determined by Inventory, is crucial if the factory module uses this for its own production costing.
    *   **Error Handling:** Clear procedures if Inventory reports insufficient stock for a required material. Does production halt? Is a substitution allowed (this would be complex)?
*   **Verification:**
    *   Unit tests for `IssueMaterialsToProductionUseCase` in Inventory.
    *   Integration Test: `factory` module triggers material issuance -> `inventory` creates outbound movements for all required materials, depletes correct batches, calculates and returns costs.
    *   Test scenarios: sufficient stock, insufficient stock, batch-specific items.

---

### Step 3.2: Finished Goods Output / Reporting from Production

*   **Task:** Implement the process where the completion of a production execution triggers the addition of newly manufactured finished goods into the Inventory module.
*   **Modules Involved:** `inventory`, `factory` (specifically `factory/production`)
*   **Implementation Details:**
    1.  **Trigger Point (Responsibility: `factory` module):**
        *   **Assumption:** The `complete_production_execution.dart` use case in the `factory/production` module will trigger this when a production order is marked as finished.
    2.  **Data to be Passed from `factory` to `inventory` for finished goods:**
        *   `productionOrderId` (or `productionExecutionId`)
        *   `finishedGoodInventoryItemId` (the `InventoryItem.id` of the item that was produced)
        *   `quantityProduced`
        *   `newBatchLotNumber` (generated by the `factory` module or following a defined convention)
        *   `finishedGoodProductionDate` (typically current date/time)
        *   `finishedGoodExpirationDate` (if applicable, calculated based on item master data or factory input)
        *   `costOfFinishedGood` (This is the **unit cost** of the finished good, calculated by the `factory` module. This cost should ideally include actual raw material costs (from Step 3.1), plus labor, overhead, etc., as per factory costing logic).
        *   Initial `qualityStatus` (e.g., 'Available', 'Pending Final QC'. This might come from `record_quality_control_usecase.dart` if QC is the last step before completion).
    3.  **Inventory Module Service/UseCase (`ReceiveFinishedGoodsFromProductionUseCase`):**
        *   Input: The data packet described above from `factory`.
        *   Logic:
            *   Validate the `finishedGoodInventoryItemId`.
            *   Create an inbound `InventoryMovementModel` (Type: `PRODUCTION_OUTPUT`).
            *   The `InventoryMovementItemModel` should store all received details: `itemId`, `quantityProduced`, `newBatchLotNumber`, `finishedGoodProductionDate`, `finishedGoodExpirationDate`, the provided `costOfFinishedGood` (as `costAtTransaction`), and initial `qualityStatus`.
            *   Link to `productionOrderId` in `referenceDocuments`.
            *   The core inventory quantity for the `finishedGoodInventoryItemId` (and its new batch) increases.
            *   Return success/failure status to `factory`.
    4.  **Factory Module Update:**
        *   `complete_production_execution.dart` use case is notified of successful inventory update.
*   **Foolproof Notes:**
    *   **Finished Good Cost Calculation:** The `factory` module **must** have a robust way to calculate the `costOfFinishedGood`. If this cost is not accurate, inventory valuation will be incorrect. This calculation should ideally use the actual material costs fed back from Inventory in Step 3.1.
    *   **Batch Number Uniqueness:** Ensure the `newBatchLotNumber` for finished goods is unique and follows any established system-wide conventions.
    *   **Quality Status:** The initial quality status of finished goods is important. If they require further QC before being sellable, they should enter inventory with a status like 'Pending QC'.
*   **Verification:**
    *   Unit tests for `ReceiveFinishedGoodsFromProductionUseCase` in Inventory.
    *   Integration Test: `factory` module completes a production execution -> `inventory` creates an inbound movement for the finished good with all correct details (new batch, expiry, cost, quality status) and quantity updates.
    *   Verify that the `costAtTransaction` for the finished good in inventory matches the `costOfFinishedGood` provided by the factory.

---

### Step 3.3: API/Service Layer Definition & Implementation

*   **Task:** Define and implement clear API contracts or service layer methods in both Inventory and Factory modules for the interactions described.
*   **Modules Involved:** `inventory`, `factory`
*   **Implementation Details:**
    1.  **Inventory Module Services Exposed:**
        *   `issueMaterialsToProduction(ProductionOrderDetails)`: Returns list of `{itemId, quantityIssued, actualCostIncurred}` or error.
        *   `receiveFinishedGoodsFromProduction(FinishedGoodsDetails)`: Returns success/failure.
    2.  **Factory Module (Internal Calls or Events):**
        *   The relevant use cases in `factory/production` (e.g., `update_production_execution_status.dart`, `complete_production_execution.dart`) will directly call the Inventory module services.
    3.  **Data Transfer Objects (DTOs):** Define clear DTOs for requests and responses (e.g., `ProductionOrderDetailsForMaterialIssue`, `FinishedGoodsReceiptInfo`).
*   **Foolproof Notes:** Versioning, error handling, security as per previous plans.
*   **Verification:** API contracts reviewed, services testable independently.

---

### Step 3.4: Comprehensive Testing & Quality Assurance

*   **Task:** Conduct thorough testing of all new integrations and functionalities.
*   **Implementation Details:**
    1.  **Unit Tests:** For all new UseCases and service methods in both modules.
    2.  **Integration Tests (Inter-Module):**
        *   Production Execution status update in `factory` -> Raw Material Issuance in `inventory` (quantities, costs, batches correct).
        *   Production Execution completion in `factory` -> Finished Goods Receipt in `inventory` (quantities, costs, new batch details correct).
    3.  **End-to-End (E2E) Scenarios:**
        *   Full Production Lifecycle: Create Production Order -> Start Production (Materials Issued from Inventory) -> Complete Production (Finished Goods Received into Inventory) -> Verify Inventory Levels and Valuation for both raw materials and finished goods.
        *   Scenarios with partial material consumption (if applicable).
        *   Scenarios involving quality control steps for finished goods.
    4.  **User Acceptance Testing (UAT):**
        *   Involve production planning team, factory floor supervisors, inventory managers, and finance team (for cost verification).
*   **Foolproof Notes:**
    *   Pay close attention to the flow of costs: from inventory (raw materials) -> to factory (WIP costing) -> back to inventory (finished goods valuation).
    *   Ensure batch traceability is maintained throughout the process.
*   **Verification:** All test cases passed, UAT sign-off.

---

### Step 3.5: Documentation Updates & Team Training

*   **Task:** Update documentation and train relevant teams.
*   **Implementation Details:**
    1.  **Technical Documentation:** API contracts, sequence diagrams for factory-inventory interactions, data flow diagrams, details on production cost calculation flow.
    2.  **User Documentation:** Updated SOPs for production execution, material handling on the factory floor, and finished goods reporting, highlighting inventory interactions.
    3.  **Team Training:** For production, warehouse, and finance teams on new workflows and data implications.
*   **Verification:** Documentation reviewed, training completed.

---

### Step 3.6: Deployment & Post-Deployment Monitoring

*   **Task:** Plan and execute deployment, and monitor post-deployment.
*   **Implementation Details:**
    1.  **Deployment Plan:** Coordinate deployment of changes in `inventory` and `factory` modules.
    2.  **Monitoring:** Monitor production execution times, material consumption accuracy, finished goods reporting accuracy, inventory level updates for raw materials and finished goods, and any errors in integration points. Closely watch inventory valuation reports.
*   **Verification:** Successful deployment, stable operation, key metrics monitored and validated.

## 4. Definition of Done (DoD) for Production/Manufacturing Integration

*   Raw materials are accurately issued from inventory when production starts/progresses, with correct batch depletion and cost recording.
*   Finished goods are accurately received into inventory upon production completion, with correct new batch details, quantity, and calculated production cost.
*   The `factory` module correctly calculates/provides the cost of finished goods, ideally incorporating actual raw material costs from inventory.
*   All new APIs/services for inter-module communication are implemented, tested, and documented.
*   Comprehensive E2E testing and UAT are completed and signed off, with particular focus on cost accuracy and batch traceability.
*   All relevant documentation is updated, and teams are trained.
*   Changes are successfully deployed, and the integration is operating stably and accurately.

## 5. Roles & Responsibilities (Example - To be filled by Project Lead)

*   **Project Lead/Manager:** (Name)
*   **Lead Developer (Inventory):** (Name)
*   **Lead Developer (Factory/Production):** (Name)
*   **Inventory Module Team:** (Names)
*   **Factory/Production Module Team:** (Names)
*   **QA Lead/Team:** (Name/s)
*   **Stakeholders (Production, Warehouse, Finance):** (Names) - UAT participation.

## 6. Communication Plan

*   Regular joint meetings between Inventory and Factory/Production development teams.
*   Weekly sync-ups with broader stakeholders.
*   Shared documentation and issue tracking.

---

This plan provides a detailed guide for integrating the Inventory and Production/Manufacturing modules. Success will depend on clear definition of trigger points within the factory module and robust calculation of finished goods costs.
