# Implementation Plan: Industrial Inventory - Phase 1: Batch/Lot & Expiry Date Management

**Document Version:** 1.0
**Date:** May 9, 2025
**Focus:** Flawless tracking of perishable and batch-controlled items.

## 1. Introduction

This document outlines the detailed implementation steps for enhancing Batch/Lot and Expiry Date management within the Industrial-Level Inventory Management system. The primary goal is to ensure accurate tracking, visibility, and utilization of perishable and batch-controlled inventory, directly supporting FEFO (First-Expired, First-Out) principles and minimizing spoilage or obsolescence.

## 2. Prerequisites

*   **Familiarity with Core Models:** Understanding of `InventoryMovementItemModel`, `InventoryItem`, and `ProductModel` (or equivalent item master data model).
*   **Existing UseCases:** Knowledge of `CalculateInventoryAgingUsecase` and `GetLowStockAlertsUseCase` structures.
*   **Integration Points:** Awareness of how `milk_reception` (for inbound raw materials) and `order_management` (for outbound picking) interact with the inventory module regarding batch and expiry information.
*   **Development Environment:** Standard Flutter development environment and access to the codebase.
*   **Version Control:** All changes managed via Git.

## 3. Detailed Implementation Steps

---

### Step 3.1: Data Model Review & Enforcement (`InventoryMovementItemModel`, `ProductModel`)

*   **Task:** Ensure `batchLotNumber`, `productionDate`, `expirationDate` are mandatorily and accurately captured for relevant items on all `InventoryMovementItemModel` instances.
*   **Files:**
    *   `lib/features/inventory/models/inventory_movement_item_model.dart`
    *   `lib/features/inventory/models/inventory_item.dart` (if batch/lot info is summarized or directly held)
    *   `lib/features/shared/product/models/product_model.dart` (or equivalent item master)
*   **Implementation Details:**
    1.  **Product Level Flags:**
        *   In `ProductModel`, add/verify boolean flags: `isBatchTracked` (bool), `isPerishable` (bool).
        *   These flags will determine if batch/expiry details are mandatory for an item.
    2.  **`InventoryMovementItemModel` Enhancements:**
        *   Review `batchLotNumber` (String?), `productionDate` (DateTime?), `expirationDate` (DateTime?).
        *   Ensure these fields are non-nullable in the model if the related `ProductModel.isBatchTracked` or `isPerishable` is true. This validation might occur in UseCases creating the movement item.
    3.  **Validation Logic:**
        *   In UseCases responsible for creating `InventoryMovementItemModel` (e.g., during PO receipt, milk reception, production output):
            *   Fetch the `ProductModel` for the item.
            *   If `isBatchTracked` is true, `batchLotNumber` must be provided.
            *   If `isPerishable` is true, `productionDate` and `expirationDate` must be provided.
            *   Throw validation errors if mandatory fields are missing.
*   **Foolproof Notes:**
    *   Ensure consistency in how dates are handled (UTC, timezone considerations).
    *   Clearly define business rules for items that are batch-tracked but not perishable (expiry might be optional).
*   **Verification:**
    *   Code review of model changes and validation logic.
    *   Unit tests for UseCases to ensure validation is triggered correctly for different item types.

---

### Step 3.2: Strengthen `CalculateInventoryAgingUsecase`

*   **Task:** Ensure high accuracy of inventory aging calculations based on `productionDate` or `expirationDate`.
*   **File:** `lib/features/inventory/domain/usecases/calculate_inventory_aging_usecase.dart`
*   **Implementation Details:**
    1.  **Review Current Logic:**
        *   Confirm the use case correctly utilizes `productionDate` (for aging since production) and/or `expirationDate` (for time until expiry).
        *   Ensure it accurately fetches `InventoryMovementItemModel` or aggregated batch stock with relevant dates.
    2.  **Aging Buckets:**
        *   Define standard aging buckets (e.g., 0-30 days, 31-60 days, 61-90 days, 90+ days since production; or <30 days to expire, 30-60 days to expire).
        *   The use case should be able to categorize stock into these buckets.
    3.  **Handling Non-Perishables:** Ensure the use case gracefully handles items where `isPerishable` is false (they might not have expiry dates, or aging is less critical).
*   **Foolproof Notes:**
    *   Ensure date calculations are precise (e.g., using `DateTime.difference`).
*   **Verification:**
    *   Unit tests with various scenarios: items just produced, nearing expiry, past expiry, non-perishable items.
    *   Test data should cover edge cases for date calculations.

---

### Step 3.3: Enhance `GetLowStockAlertsUseCase` for Expiring Items

*   **Task:** Improve alerts for items nearing expiration, distinct from quantity-based low stock.
*   **File:** `lib/features/inventory/domain/usecases/get_low_stock_alerts_usecase.dart`
*   **Implementation Details:**
    1.  **Expiry Alert Logic:**
        *   Add functionality to check `expirationDate` of available batches against a configurable threshold (e.g., system setting: "Alert if expiring within X days").
        *   This might involve iterating through stock batches and identifying those within the expiry warning window.
    2.  **Alert Distinction:**
        *   Ensure alerts generated by this use case clearly differentiate between "low quantity" and "nearing expiration." The alert model might need a new field or type.
    3.  **Configuration:** The "X days to expiry" threshold should be configurable, possibly per item category or system-wide.
*   **Foolproof Notes:**
    *   Avoid duplicate alerts if an item is both low in quantity and nearing expiry; perhaps a combined alert status.
*   **Verification:**
    *   Unit tests for generating expiry alerts based on different thresholds and expiry dates.
    *   Test scenarios where items are only nearing expiry, only low quantity, or both.

---

### Step 3.4: Implement/Verify FEFO Logic for Picking Suggestions

*   **Task:** Ensure picking suggestions prioritize items expiring soonest (First-Expired, First-Out).
*   **Files:**
    *   Relevant UseCases in `lib/features/inventory/domain/usecases/` that provide stock availability or picking suggestions (e.g., `GetAvailableStockForOrderItemUseCase`).
    *   UseCases in `lib/features/order_management/domain/usecases/` that request stock for picking.
*   **Implementation Details:**
    1.  **Sorting Logic:**
        *   When fetching available stock batches for an order item (especially for `ProductModel.isPerishable == true` items):
            *   Primary sort: `expirationDate` in ascending order (oldest expiry first).
            *   Secondary sort (if expiries are the same, or for non-perishables): `productionDate` or `receivedDate` (FIFO) in ascending order.
    2.  **Use Case Modification:** Ensure any use case that lists available stock for picking incorporates this FEFO sorting.
    3.  **Visibility:** If picking lists are generated, they should reflect the FEFO order.
*   **Foolproof Notes:**
    *   Clearly define tie-breaking rules if multiple batches have the same expiry date.
    *   Consider performance implications if sorting large numbers of batches; ensure efficient querying.
*   **Verification:**
    *   Unit tests for the sorting logic within the relevant use cases.
    *   Integration tests simulating order fulfillment with multiple batches having different expiry dates, verifying the correct batch is suggested/picked.

---

### Step 3.5: Integration with `milk_reception` for Accurate Data Capture

*   **Task:** Ensure the `milk_reception` module accurately captures and provides mandatory batch/expiry data for raw materials.
*   **Files:**
    *   Relevant services/UseCases in `lib/features/milk_reception/domain/usecases/` (e.g., `RecordMilkReceptionUseCase`).
    *   The point of interface where `milk_reception` calls an inventory service to record the received items.
*   **Implementation Details:**
    1.  **Data Provision:**
        *   Verify that `milk_reception` processes (UI and backend logic) capture `batchLotNumber`, `productionDate`, and `expirationDate` for received milk.
        *   Ensure this data is correctly passed to the Inventory module when creating `InventoryMovementItemModel`.
    2.  **Input Validation (Inventory Side):**
        *   The inventory UseCase that handles milk reception (e.g., `AddInventoryMovementUseCase` called by `milk_reception`) should validate that these fields are present and valid for milk items (which are perishable and batch-tracked).
*   **Foolproof Notes:**
    *   Consider scenarios where batch/expiry might not be known precisely at reception and how that's handled (e.g., provisional data, immediate update required).
*   **Verification:**
    *   Integration tests: Simulate milk reception, ensure `InventoryMovementItemModel` is created with correct batch/expiry details in Firestore.
    *   Check validation errors if `milk_reception` attempts to send incomplete data for these fields.

---

### Step 3.6: Integration with `order_management` for FEFO Picking

*   **Task:** Ensure `order_management` picking processes respect and utilize FEFO logic provided by the inventory module.
*   **Files:**
    *   Picking-related UseCases in `lib/features/order_management/domain/usecases/` (e.g., `GeneratePickingListUseCase`, `FulfillOrderItemUseCase`).
*   **Implementation Details:**
    1.  **Querying Inventory:**
        *   When `order_management` needs to determine stock for picking, it must call inventory UseCases that return stock already sorted by FEFO (as per Step 3.4).
    2.  **Displaying to User:** If `order_management` UI displays suggested batches for picking, it should present them in the FEFO order.
    3.  **Confirmation:** The actual batch picked (if manual selection is allowed) should be confirmed and recorded.
*   **Foolproof Notes:**
    *   Ensure the "chosen" batch for picking is correctly communicated back to inventory for depletion.
*   **Verification:**
    *   End-to-end (E2E) tests: Create an order for a perishable item with multiple batches (different expiry dates), proceed to picking in `order_management`, and verify that the system guides towards/uses the FEFO batch.

---

### Step 3.7: Comprehensive Testing & Quality Assurance

*   **Task:** Conduct thorough testing of all changes and new functionalities related to batch/lot and expiry management.
*   **Implementation Details:**
    1.  **Unit Tests:** High coverage for all modified/new logic in UseCases and models.
    2.  **Integration Tests:**
        *   Inventory module internal: Test interaction between UseCases related to aging, alerts, and FEFO suggestions.
        *   Inter-module: Test data flow and validation between `inventory`, `milk_reception`, and `order_management`.
    3.  **End-to-End (E2E) Scenarios:**
        *   Full lifecycle: Receive perishable item (e.g., via `milk_reception`) with batch/expiry -> Check aging report -> Receive expiry alert -> Fulfill sales order using FEFO logic.
        *   Scenarios with multiple receipts of the same item with different batch/expiry dates.
    4.  **User Acceptance Testing (UAT):**
        *   Involve warehouse/operations team to validate FEFO picking and expiry alert usefulness.
        *   Involve quality/compliance team if applicable.
*   **Foolproof Notes:**
    *   Test with realistic date ranges and item types.
*   **Verification:**
    *   All test cases passed, UAT sign-off.

---

### Step 3.8: Documentation Updates & Team Training

*   **Task:** Update documentation and train relevant teams.
*   **Implementation Details:**
    1.  **Technical Documentation:** Update model definitions, UseCase descriptions, and integration point details.
    2.  **User Documentation:** Explain new validation rules, how FEFO works in picking, and how to interpret aging reports/expiry alerts.
    3.  **Training:** Sessions for developers, warehouse staff, and order fulfillment teams.
*   **Verification:** Documentation reviewed, training completed.

---

### Step 3.9: Deployment & Post-Deployment Monitoring

*   **Task:** Plan and execute deployment, and monitor post-deployment.
*   **Implementation Details:**
    1.  **Deployment Plan:** Standard deployment procedures.
    2.  **Data Migration (if needed):** Assess if existing `InventoryMovementItemModel` records for perishable/batch items need backfilling of `isBatchTracked`/`isPerishable` flags based on `ProductModel` (this might be complex; ideally, new rules apply going forward).
    3.  **Monitoring:** Monitor logs for validation errors, check accuracy of aging reports and FEFO suggestions with live data.
*   **Verification:** Successful deployment, system stability, key features verified with live data.

## 4. Definition of Done (DoD)

*   `ProductModel` includes `isBatchTracked` and `isPerishable` flags.
*   `InventoryMovementItemModel` creation enforces mandatory `batchLotNumber`, `productionDate`, `expirationDate` based on product flags.
*   `CalculateInventoryAgingUsecase` accurately calculates and categorizes stock aging.
*   `GetLowStockAlertsUseCase` includes alerts for items nearing expiration.
*   FEFO logic is implemented and used for picking suggestions in `inventory` and respected by `order_management`.
*   `milk_reception` integration correctly provides batch/expiry data.
*   All related unit, integration, and E2E tests are passing.
*   UAT is completed and signed off.
*   Documentation is updated, and teams are trained.
*   Changes are successfully deployed and monitored.

## 5. Roles & Responsibilities (Example - To be filled by Project Lead)

*   **Project Lead/Manager:** (Name)
*   **Lead Developer (Inventory):** (Name)
*   **Inventory Module Team:** (Names)
*   **Milk Reception Module Team Lead:** (Name)
*   **Order Management Module Team Lead:** (Name)
*   **QA Lead/Team:** (Name/s)
*   **Stakeholders (Warehouse/Operations):** (Name/s)

## 6. Communication Plan

*   Standard project communication channels (daily stand-ups, weekly syncs, shared documentation, issue tracker).

