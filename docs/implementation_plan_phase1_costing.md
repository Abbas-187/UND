# Implementation Plan: Industrial Inventory - Phase 1: FIFO/LIFO Costing

**Document Version:** 1.0
**Date:** May 9, 2025
**Focus:** Implementing True FIFO/LIFO Costing for Accurate Inventory Valuation and COGS.

## 1. Introduction

This document outlines the detailed implementation steps for Phase 1 of the Industrial-Level Inventory Management enhancement, focusing on establishing accurate financial tracking through FIFO (First-In, First-Out) or LIFO (Last-In, First-Out) costing methodologies. This is a critical foundation for financial reporting and accurate inventory valuation.

**The primary goal of this phase is to ensure that the cost of goods sold and the value of remaining inventory are calculated based on the actual historical costs of specific batches/lots.**

## 2. Prerequisites

*   **Decision on Costing Method:** The business must definitively choose between FIFO or LIFO for financial reporting. This plan will refer to "chosen costing method" but examples might lean towards FIFO for simplicity.
*   **Inventory Module Structure:** Familiarity with the existing inventory module structure (`InventoryItem`, `InventoryMovementModel`, `InventoryMovementItemModel`, `InventoryRepository`, relevant UseCases).
*   **Integration Points Identified:** Basic understanding of how `procurement` and `milk_reception` modules provide cost information upon receipt of goods.
*   **Development Environment:** Standard Flutter development environment set up and access to the codebase.
*   **Version Control:** All changes must be managed via Git, with feature branches for this implementation.

## 3. Detailed Implementation Steps

---

### Step 3.1: Data Model Enhancement (`InventoryMovementItemModel`)

*   **Task:** Add a new field to `InventoryMovementItemModel` to store the cost of the item at the time of the transaction.
*   **File:** `lib/features/inventory/models/inventory_movement_item_model.dart`
*   **Field to Add:**
    *   Name: `costAtTransaction`
    *   Data Type: `double?` (nullable double, as some movements might not directly involve a cost, or cost might be derived differently for internal transfers if not revalued).
*   **Implementation Details:**
    1.  Add the `costAtTransaction` field to the class properties.
    2.  Update the constructor to include `this.costAtTransaction`.
    3.  Update the `fromJson` factory method to parse `costAtTransaction` from JSON (ensure proper type casting from `num?`).
    4.  Update the `toJson` method to include `costAtTransaction`.
    5.  Update the `copyWith` method to include `costAtTransaction`.
    6.  Update the `toString()` method for debugging purposes.
*   **Foolproof Notes:**
    *   Ensure the JSON key for `costAtTransaction` (e.g., `'costAtTransaction'`) is consistently used.
    *   Handle potential null values gracefully during JSON parsing.
*   **Verification:**
    *   Code review of the model changes.
    *   Run existing unit tests for `InventoryMovementItemModel`; add new tests specifically for `costAtTransaction` field handling (serialization, deserialization, copyWith).

---

### Step 3.2: Update Data Layer - Capturing `costAtTransaction` for Inbound Movements

*   **Task:** Modify the Inventory Repository and its implementation to correctly save `costAtTransaction` when goods are received or inventory value is otherwise established (e.g., production output).
*   **Files:**
    *   `lib/features/inventory/domain/repositories/inventory_repository.dart` (if interface signatures for adding movements need to change to accept cost – likely they already accept the full `InventoryMovementItemModel`).
    *   Concrete implementation of `InventoryRepository` (e.g., `lib/features/inventory/data/repositories/inventory_repository_impl.dart`).
    *   Services/UseCases in `procurement` and `milk_reception` that call the Inventory Repository to record receipts.
*   **Implementation Details:**
    1.  **Identify Inbound Movement Triggers:**
        *   Goods receipt against a Purchase Order (from `procurement` module).
        *   Milk reception (from `milk_reception` module).
        *   Production output of finished goods (if applicable, from a production module).
        *   Positive adjustments where a cost needs to be established.
    2.  **Ensure Cost Provision:**
        *   The calling modules (`procurement`, `milk_reception`, etc.) **must** provide the `costAtTransaction` for each item batch being received. This cost should be the actual acquisition cost (e.g., from supplier invoice).
        *   Modify the data contracts or function calls from these modules to the Inventory module if they don't already pass this cost information per item/batch.
    3.  **Persist `costAtTransaction`:**
        *   In the Inventory Repository implementation (e.g., `addMovement` or similar method), ensure that the `costAtTransaction` from the provided `InventoryMovementItemModel` is correctly persisted to Firebase/Firestore alongside other movement item details.
*   **Foolproof Notes:**
    *   Clearly define the responsibility for providing the `costAtTransaction`. It should originate from the source module (e.g., `procurement` gets it from the PO/invoice).
    *   Handle scenarios where cost might not be available (though for new receipts, it should be). Decide on a default or error handling if `costAtTransaction` is unexpectedly null for a receipt.
*   **Verification:**
    *   Code review of repository changes and integration points.
    *   Integration tests:
        *   Simulate a PO receipt from `procurement` with item costs; verify `InventoryMovementItemModel` in Firestore contains the correct `costAtTransaction`.
        *   Simulate `milk_reception` with costs; verify persistence.
    *   Unit tests for any new logic in the repository layer.

---

### Step 3.3: Implement FIFO/LIFO Valuation Logic for Outbound Movements

*   **Task:** Create or modify a service/use case within the Inventory module to determine the cost of goods being issued, sold, or consumed, based on the chosen costing method (FIFO/LIFO). This service will also identify which specific batches (and their `costAtTransaction`) are affected.
*   **Files:**
    *   Likely a new UseCase: e.g., `CalculateOutboundMovementCostUseCase.dart` or `DetermineCostOfGoodsSoldUseCase.dart` in `lib/features/inventory/domain/usecases/`.
    *   This UseCase will heavily rely on `InventoryRepository` to fetch relevant `InventoryMovementItemModel` records (specifically inbound movements with positive quantities and `costAtTransaction`).
*   **Implementation Details:**
    1.  **Input:** `itemId`, `quantityToIssue`, `chosenCostingMethod` (FIFO/LIFO).
    2.  **Logic:**
        *   Fetch all relevant historical inbound `InventoryMovementItemModel` records for the `itemId` that still have a theoretical "remaining quantity" available for costing. These are your "cost layers" or "batches."
        *   Sort these layers:
            *   **FIFO:** Sort by `timestamp` (or `productionDate`/`expirationDate` if that defines the "first-in") in ascending order.
            *   **LIFO:** Sort by `timestamp` in descending order.
        *   Iterate through the sorted layers, "consuming" the required `quantityToIssue`:
            *   For each layer, determine how much quantity can be taken from it.
            *   Record the `costAtTransaction` of that layer and the quantity taken from it.
            *   If a layer is fully consumed, move to the next. If partially consumed, record the partial quantity.
            *   Sum the `(quantity_taken_from_layer * costAtTransaction_of_layer)` to get the total COGS for the `quantityToIssue`.
    3.  **Output:** A list of `{ batchIdentifier (e.g., original movement ID or batchLotNumber), quantityConsumed, costAtTransaction, totalCostForThisPortion }` and the total COGS.
    4.  **Persisting Consumption (Conceptual):** While this use case calculates cost, the actual reduction of "available quantity for costing" from these layers needs careful handling. This might involve:
        *   Creating corresponding outbound `InventoryMovementItemModel` records that explicitly link back to the consumed inbound batch/layer (e.g., via a `consumedFromBatchId` field). This provides a clear audit trail for costing.
        *   Alternatively, maintaining a separate ledger or view of "available cost layers" that gets updated. This is more complex. *Initially, focus on correct calculation; audit trail for consumption can be an enhancement if needed.*
*   **Foolproof Notes:**
    *   **Atomicity:** If updating "remaining quantities" of cost layers, ensure operations are atomic to prevent race conditions.
    *   **Data Integrity:** Ensure that the sum of quantities consumed from layers matches `quantityToIssue`.
    *   **Edge Cases:** Handle scenarios where there isn't enough stock to fulfill the `quantityToIssue` based on available cost layers.
    *   **Performance:** For items with very long transaction histories, fetching and sorting all inbound movements could be performance-intensive. Consider optimizations like only fetching layers with a theoretical positive balance.
*   **Verification:**
    *   Extensive unit tests for the `CalculateOutboundMovementCostUseCase` covering:
        *   FIFO logic with single batch, multiple batches, partial consumption.
        *   LIFO logic with similar scenarios.
        *   Insufficient stock scenarios.
        *   Zero quantity issuance.
    *   Code review of the algorithm.

---

### Step 3.4: Integrate Cost Calculation into Outbound Inventory Movements

*   **Task:** Modify existing use cases/services that handle outbound inventory movements (e.g., `FulfillSalesOrderUseCase`, `IssueStockToProductionUseCase`, `ProcessInventoryAdjustmentUseCase` for negative adjustments) to utilize the new `CalculateOutboundMovementCostUseCase`.
*   **Files:**
    *   Relevant UseCases in `lib/features/inventory/domain/usecases/`.
    *   UseCases in `order_management`, `production` (if applicable) that trigger inventory depletion.
*   **Implementation Details:**
    1.  Before an outbound `InventoryMovementModel` is created and saved:
        *   Call the `CalculateOutboundMovementCostUseCase` (from Step 3.3) to get the COGS and the breakdown of which batches contributed.
    2.  The resulting COGS should be stored appropriately (e.g., associated with the sales order line in `order_management`, or with the production job).
    3.  The outbound `InventoryMovementModel` itself might not store the COGS directly (as it's a derived value based on historical costs), but it *must* accurately record the `itemId` and `quantity` depleted. The link to the cost comes from the calculation.
    4.  **(Optional but Recommended for Audit):** If feasible, the outbound `InventoryMovementItemModel` could store a reference or list of references to the inbound batches/layers it consumed for costing purposes.
*   **Foolproof Notes:**
    *   Ensure the COGS calculation happens *before* the inventory quantity is actually decremented or the outbound movement is finalized, to ensure consistency.
    *   Error handling: What happens if the COGS calculation fails (e.g., due to insufficient costed layers)? Should the outbound movement be blocked?
*   **Verification:**
    *   Integration tests:
        *   Simulate a sales order fulfillment: Verify COGS is calculated correctly and associated with the order.
        *   Simulate a stock issuance: Verify cost is determined.
    *   End-to-end testing of an order-to-cash or issue-to-production flow, checking financial implications.

---

### Step 3.5: Define and Update `InventoryItem.cost` Role & Logic

*   **Task:** Clarify the purpose of the existing `InventoryItem.cost` field and implement logic for its update, ensuring it doesn't conflict with the new FIFO/LIFO COGS calculation.
*   **Files:**
    *   `lib/features/inventory/domain/entities/inventory_item.dart`
    *   Services/UseCases that handle inbound movements (e.g., `ReceivePurchaseOrderUseCase`).
*   **Implementation Details:**
    1.  **Define Purpose:** `InventoryItem.cost` will **not** be used for COGS calculation if FIFO/LIFO is implemented. Its purpose could be:
        *   **Latest Purchase Cost:** Updated every time a new batch is received with its `costAtTransaction`.
        *   **Weighted Average Cost (WAC):** Recalculated after every receipt: `((OldQty * OldWAC) + (ReceivedQty * ReceivedCost)) / (OldQty + ReceivedQty)`. This is a common alternative costing method but can be maintained for informational purposes even if FIFO/LIFO is primary for COGS.
        *   **Standard Cost:** A predetermined cost used for internal analysis (less common if actual costing is implemented).
    2.  **Implement Update Logic:** Based on the chosen purpose, update the relevant services (e.g., when processing a PO receipt) to also update `InventoryItem.cost` accordingly.
*   **Foolproof Notes:**
    *   **Clarity:** Ensure the entire team understands that `InventoryItem.cost` is for informational/valuation purposes and *not* the source for FIFO/LIFO COGS.
    *   If WAC is chosen, ensure the calculation is accurate and triggered correctly.
*   **Verification:**
    *   Unit tests for the logic updating `InventoryItem.cost`.
    *   Verify that reports using `InventoryItem.cost` (if any) are understood to be based on this defined purpose (e.g., "Valuation at Latest Cost" or "Valuation at WAC").

---

### Step 3.6: Develop/Update Inventory Valuation Reports

*   **Task:** Create or modify inventory valuation reports to accurately reflect the value of stock on hand, based on the chosen FIFO/LIFO method.
*   **Files:** Reporting components, services, or new UseCases for generating report data.
*   **Implementation Details:**
    1.  **Logic:** To value current stock using FIFO/LIFO principles:
        *   For each `InventoryItem`:
            *   Fetch all its historical inbound `InventoryMovementItemModel` records (cost layers) with their `costAtTransaction`.
            *   Fetch all its historical outbound `InventoryMovementItemModel` records.
            *   Reconstruct the "remaining" quantities of each cost layer by subtracting the quantities consumed by outbound movements (following FIFO/LIFO logic for consumption).
            *   The value of current stock for the item is the sum of `(remaining_quantity_of_layer * costAtTransaction_of_layer)` for all layers that still have a remaining quantity.
    2.  **Report Content:**
        *   Item ID, Name, Category
        *   Total Quantity on Hand
        *   Valuation (based on chosen costing method)
        *   (Optional) Breakdown by batch/cost layer showing quantity and value per layer.
*   **Foolproof Notes:**
    *   This calculation can be complex and potentially resource-intensive for real-time reporting on many items. Consider:
        *   Calculating valuations periodically (e.g., end of day) and storing snapshots.
        *   Optimizing queries heavily.
    *   Ensure consistency between how COGS is calculated (Step 3.3/3.4) and how remaining stock is valued.
*   **Verification:**
    *   Manual verification of report outputs against test data with known transactions and costs.
    *   Comparison with expected values calculated manually or via a spreadsheet for test scenarios.
    *   Sign-off from finance/accounting stakeholders on the report accuracy and format.

---

### Step 3.7: Comprehensive Testing & Quality Assurance

*   **Task:** Conduct thorough testing of all changes and new functionalities.
*   **Implementation Details:**
    1.  **Unit Tests:** Already mentioned for each component, ensure high coverage.
    2.  **Integration Tests:**
        *   Inventory module internal: Test interaction between UseCases, Repository, and costing logic.
        *   Inter-module: Test data flow from `procurement`/`milk_reception` (cost input) and to `order_management` (COGS usage).
    3.  **End-to-End (E2E) Scenarios:**
        *   Full lifecycle: PO Creation -> Receipt (cost captured) -> Sales Order -> Fulfillment (COGS calculated using FIFO/LIFO) -> Inventory Valuation Report.
        *   Scenarios with multiple receipts at different costs.
        *   Scenarios with returns and adjustments.
    4.  **User Acceptance Testing (UAT):**
        *   Crucial involvement of finance/accounting team members to validate costing calculations, report accuracy, and overall financial integrity.
        *   Operations team to validate impact on inventory transaction processes.
*   **Foolproof Notes:**
    *   Develop a comprehensive test plan with detailed test cases *before* UAT.
    *   Use realistic test data, including edge cases and large volumes if possible.
*   **Verification:**
    *   All test cases passed.
    *   UAT sign-off from all relevant stakeholders.
    *   Defect tracking and resolution.

---

### Step 3.8: Documentation Updates & Team Training

*   **Task:** Update all relevant documentation and train the team on the new costing system.
*   **Implementation Details:**
    1.  **Technical Documentation:**
        *   Update `README.md` files for the inventory module.
        *   Document the new `costAtTransaction` field and its purpose.
        *   Document the FIFO/LIFO calculation logic and relevant UseCases.
        *   Update data flow diagrams.
    2.  **User Documentation:**
        *   Explain how inventory valuation is now calculated.
        *   Update guides for any reports that have changed.
    3.  **Team Training:**
        *   Sessions for developers on the new architecture and code.
        *   Sessions for finance/operations users on how the system works and how to interpret new reports or data.
*   **Foolproof Notes:**
    *   Ensure documentation is clear, concise, and accessible.
*   **Verification:**
    *   Documentation reviewed and approved.
    *   Training sessions completed and feedback gathered.

---

### Step 3.9: Deployment & Post-Deployment Monitoring

*   **Task:** Plan and execute the deployment of Phase 1 changes, and monitor the system post-deployment.
*   **Implementation Details:**
    1.  **Deployment Plan:**
        *   Consider a phased rollout if possible, or a deployment during off-peak hours.
        *   Backup existing data before deployment.
        *   Data migration strategy if historical `InventoryMovementItemModel` records need to be backfilled with an estimated `costAtTransaction` (this is complex and needs careful consideration – might be out of scope for initial rollout and applied going forward). **For a foolproof initial rollout, new costing may only apply to transactions after deployment.**
    2.  **Monitoring:**
        *   Closely monitor system logs for any errors related to costing calculations or data persistence.
        *   Track the accuracy of valuation reports.
        *   Gather user feedback.
*   **Foolproof Notes:**
    *   Have a rollback plan in case of critical issues post-deployment.
    *   Ensure key finance users are available to verify data immediately after deployment.
*   **Verification:**
    *   Successful deployment.
    *   System stability and performance confirmed.
    *   Key reports verified by stakeholders with live data.

---

### Step 3.10: Batch/Lot & Expiry Management

*   **Task:** Ensure `batchLotNumber`, `productionDate`, and `expirationDate` are mandatory for all relevant `InventoryMovementItemModel` records, especially for perishables.
*   **Implementation:** Update models and use cases to enforce and validate these fields. Integrate with `milk_reception` and `procurement` for batch/expiry capture.
*   **Verification:** Unit/integration tests for batch/expiry logic; ensure FEFO (First-Expired, First-Out) logic is available for picking.

---

### Step 3.11: Inventory Movement Types & Auditability

*   **Task:** Review and expand `InventoryMovementType` to cover all scenarios (Receipts, Issues, Sales, Returns, Adjustments, Transfers, Quality Status Changes, Production Consumption/Output).
*   **Implementation:** Enforce `reasonNotes`, `referenceDocuments`, and `initiatingEmployeeId` for all manual or adjustment movements.
*   **Verification:** Audit trail tests; ensure all movements are justified and traceable.

---

### Step 3.12: Riverpod State Management & Freezed Models

*   **Task:** Use Riverpod providers for all inventory state/business logic. Use Freezed for all inventory models, ensuring immutability and robust serialization.
*   **Implementation:** Refactor or confirm all inventory entities and providers follow this pattern.
*   **Verification:** Code review and test coverage for providers and models.

---

### Step 3.13: Integration with Forecasting & Optimization

*   **Task:** Prepare for dynamic ROP and safety stock by ensuring `InventoryItem` can store and update these fields. Integrate with `forecasting` module for demand-driven planning.
*   **Implementation:** Add/update fields and use cases for ROP/safety stock; set up data flows from forecasting.
*   **Verification:** Test dynamic stock calculations and alerting.

---

### Step 3.14: Quality Management Integration

*   **Task:** Integrate quality status at all inventory touchpoints (receiving, storage, pre-shipment).
*   **Implementation:** Update models and flows to capture and update `qualityStatus` as needed.
*   **Verification:** Test quality status changes and their impact on inventory availability.

---

### Step 3.15: Security, Permissions, and Audit Logging

*   **Task:** Implement role-based access control and ensure all actions are logged with user identity.
*   **Implementation:** Integrate with HR/user management for permissions; update logging.
*   **Verification:** Security and audit tests.

---

## 4. Definition of Done (DoD) for Phase 1

*   All code changes for FIFO/LIFO costing (Steps 3.1-3.15) are implemented, peer-reviewed, and merged to the main development branch.
*   All associated unit and integration tests are passing with satisfactory coverage.
*   Inventory valuation reports correctly reflect the chosen costing method (FIFO/LIFO) and are validated by finance.
*   COGS is correctly calculated for outbound movements and available for use by integrated modules.
*   Comprehensive E2E testing and UAT are completed and signed off.
*   All relevant technical and user documentation is updated.
*   Team members are trained on the new system.
*   Phase 1 changes are successfully deployed to the target environment.
*   Post-deployment monitoring shows stable and accurate system operation.

## 5. Roles & Responsibilities (Example - To be filled by Project Lead)

*   **Project Lead/Manager:** (Name) - Overall coordination, stakeholder communication.
*   **Lead Developer (Inventory):** (Name) - Technical oversight for inventory module changes.
*   **Inventory Module Team:** (Names) - Implementation of inventory-specific tasks.
*   **Procurement Module Team Lead:** (Name) - Ensuring cost data provision from procurement.
*   **Milk Reception Module Team Lead:** (Name) - Ensuring cost data provision from milk reception.
*   **QA Lead/Team:** (Name/s) - Test planning and execution, UAT coordination.
*   **Finance Stakeholder(s):** (Name/s) - Requirements validation, UAT participation, report sign-off.
*   **DevOps/Deployment Team:** (Name/s) - Deployment planning and execution.

## 6. Communication Plan

*   **Daily Stand-ups:** For the core development team.
*   **Weekly Sync-ups:** With broader stakeholders (Project Lead, Module Leads, Finance).
*   **Shared Documentation:** All plans, designs, and test results stored in a central repository (e.g., this `docs` folder).
*   **Issue Tracker:** Use of a tool like JIRA or GitHub Issues for tracking tasks, bugs, and progress.

---

This detailed plan should provide a clear path for implementing Phase 1. Remember to adapt it as needed and maintain open communication throughout the process.
