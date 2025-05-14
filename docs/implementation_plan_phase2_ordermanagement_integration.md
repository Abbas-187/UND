# Implementation Plan: Industrial Inventory - Phase 2: Order Management Integration

**Document Version:** 1.0
**Date:** May 9, 2025
**Focus:** Deep integration between the Inventory module and the Order Management (`order_management`) module for seamless sales order processing, stock allocation, and fulfillment.

## 1. Introduction

This document outlines the detailed implementation steps for a critical part of Phase 2 of the Industrial-Level Inventory Management enhancement: the deep integration with the `order_management` module. This integration will ensure real-time inventory visibility during order creation, accurate stock reservation/allocation, streamlined picking processes, correct inventory depletion upon shipment, and proper handling of customer returns.

**The primary goals of this integration are to improve order fulfillment accuracy, reduce stock discrepancies, enhance customer satisfaction, and provide a seamless flow of information between sales and inventory operations.**

## 2. Prerequisites

*   **Phase 1 (FIFO/LIFO Costing) Completion (Recommended):** While not a strict blocker, having accurate costing in place provides a more complete picture. If Phase 1 is not complete, COGS aspects might be deferred.
*   **Defined Order Management Lifecycle:** A clear understanding of the existing sales order lifecycle within the `order_management` module (e.g., order creation, confirmation, picking, packing, shipment, returns).
*   **Inventory Module Stability:** Core inventory functionalities (item master, stock balances, basic movements) from Phase 1 should be stable.
*   **API/Service Layer Design:** Both Inventory and Order Management modules should ideally expose clear services or APIs for inter-module communication.
*   **Development Environment & Version Control:** Standard setup (as per Phase 1).

## 3. Detailed Implementation Steps

---

### Step 3.1: Inventory Reservation/Allocation for Sales Orders

*   **Task:** Implement a mechanism to reserve or allocate specific inventory stock (including batch/lot if applicable) when a sales order is confirmed.
*   **Modules Involved:** `inventory`, `order_management`
*   **Implementation Details:**
    1.  **Decision on Reservation Strategy:**
        *   **Option A: New `InventoryReservation` Entity (Inventory Module):**
            *   Fields: `reservationId`, `orderId` (from `order_management`), `itemId`, `batchLotNumber` (if applicable), `reservedQuantity`, `reservationTimestamp`, `status` (e.g., 'Active', 'Fulfilled', 'Cancelled').
            *   Inventory Repository: Methods to `createReservation`, `getReservationsForItem`, `updateReservationStatus`, `deleteReservation`.
        *   **Option B: Add Status/Reserved Quantity to `InventoryItem` or `InventoryBatch` (Inventory Module):**
            *   Add fields like `reservedQuantity` directly to `InventoryItem` or a more granular batch/lot entity if one exists.
            *   This might be simpler but can be harder to manage for multiple concurrent orders against the same item/batch.
        *   **Recommendation:** Option A (`InventoryReservation` entity) is generally more robust and scalable for tracking reservations against specific orders.
    2.  **Order Management Trigger:**
        *   When a sales order reaches a "Confirmed" or "Ready for Allocation" status in the `order_management` module, it should trigger a call to the Inventory module.
    3.  **Inventory Module Service/UseCase (`CreateStockReservationUseCase`):**
        *   Input: `orderId`, list of `orderItems` (with `itemId`, `requiredQuantity`).
        *   Logic:
            *   For each `orderItem`, check available stock (current quantity - existing active reservations).
            *   If batch/lot specific and FEFO is required: Identify the appropriate batch(es) to reserve from.
            *   Create `InventoryReservation` records.
            *   Return success/failure (e.g., if stock is insufficient) to `order_management`.
    4.  **Order Management Update:**
        *   Update the sales order status based on successful reservation (e.g., "Stock Reserved", "Awaiting Picking").
        *   Handle cases where full reservation is not possible (e.g., partial reservation, backorder status).
*   **Foolproof Notes:**
    *   **Atomicity:** Reservation creation should be atomic. If reserving for multiple items in an order, either all succeed or all fail (or handle partials explicitly).
    *   **Concurrency:** Handle potential race conditions if multiple orders try to reserve the same limited stock simultaneously (e.g., using Firestore transactions if applicable for the reservation check & creation).
    *   **Visibility:** Ensure reserved quantities are considered "unavailable" for new, unreserved orders when checking stock availability.
*   **Verification:**
    *   Unit tests for `CreateStockReservationUseCase` and `InventoryReservation` entity logic.
    *   Integration Test: `order_management` confirms an order -> `inventory` creates reservations -> `order_management` order status updates.
    *   Test scenarios: sufficient stock, insufficient stock, partial reservation, batch-specific reservation.

---

### Step 3.2: Integrating the Picking Process

*   **Task:** Provide the `order_management` or `logistics` module with the necessary information to guide the picking process based on reserved stock and warehouse locations.
*   **Modules Involved:** `inventory`, `order_management`, `logistics` (if logistics handles picking execution)
*   **Implementation Details:**
    1.  **Picking List Generation (Responsibility: `order_management` or `logistics`):**
        *   When an order is ready for picking, the responsible module generates a picking list.
    2.  **Inventory Module Service/UseCase (`GetPickingSuggestionsUseCase` or enhance reservation query):**
        *   Input: `orderId` (or list of items to be picked).
        *   Logic:
            *   Retrieve the active `InventoryReservation` records for the `orderId`.
            *   For each reserved item/batch, fetch its current location(s) from `InventoryItem` / `InventoryLocationModel` / batch-specific location data.
            *   If FEFO is enforced, ensure suggestions prioritize the oldest (expiring soonest) reserved batches.
            *   Consider `qualityStatus` – only suggest pickable stock.
        *   Output: A list of items to pick, including `itemId`, `productName`, `batchLotNumber`, `quantityToPick`, `location` (bin, aisle, etc.), `expiryDate` (for verification).
    3.  **Display/Use in Picking Interface:** The `order_management` or `logistics` module uses this information in its picking interface (e.g., mobile app for warehouse staff).
*   **Foolproof Notes:**
    *   **Accuracy:** Ensure the location data provided by Inventory is precise and up-to-date.
    *   **Real-time Updates:** If stock moves during picking (rare, but possible), how is this handled? The initial picking list is a snapshot.
    *   **Picking Discrepancies:** The picking process itself (in `order_management`/`logistics`) needs to handle discrepancies (e.g., item not found at location, quantity mismatch). These discrepancies might require an inventory adjustment later.
*   **Verification:**
    *   Unit tests for `GetPickingSuggestionsUseCase`.
    *   Integration Test: Generate picking list for an order -> Inventory provides correct item details, batches, locations based on prior reservations.
    *   Test FEFO logic in picking suggestions.
    *   Test that only pickable quality status items are suggested.

---

### Step 3.3: Inventory Depletion upon Shipment

*   **Task:** Accurately deplete inventory quantities and fulfill reservations when an order is confirmed as shipped.
*   **Modules Involved:** `inventory`, `order_management`, `logistics`
*   **Implementation Details:**
    1.  **Shipment Confirmation Trigger (Responsibility: `order_management` or `logistics`):**
        *   When an order (or part of an order) is confirmed as shipped, the responsible module notifies the Inventory module.
    2.  **Inventory Module Service/UseCase (`ProcessShipmentDepletionUseCase`):**
        *   Input: `orderId`, list of shipped items (`itemId`, `shippedQuantity`, `batchLotNumber` actually shipped – this is important if discrepancies occurred during picking).
        *   Logic:
            *   For each shipped item:
                *   Create an outbound `InventoryMovementModel` (Type: `SALE_SHIPMENT` or similar).
                *   The `InventoryMovementItemModel` should record the actual `itemId`, `shippedQuantity`, `batchLotNumber`, `productionDate`, `expirationDate` of the shipped goods.
                *   If Phase 1 (Costing) is complete: Call the `CalculateOutboundMovementCostUseCase` to determine COGS for the shipped items. Store/pass this COGS to `order_management` for financial recording.
            *   Update the status of the corresponding `InventoryReservation` records to 'Fulfilled' or delete them.
            *   The core inventory quantity for the `InventoryItem` (and specific batch if tracked granularly) is reduced by the `shippedQuantity` (this is implicitly handled by creating the outbound `InventoryMovementModel` if your repository updates aggregate quantities based on movements).
    3.  **Order Management Update:**
        *   `order_management` updates the order status to "Shipped".
        *   Records COGS against the sales order if provided by Inventory.
*   **Foolproof Notes:**
    *   **Actual vs. Reserved:** Deplete based on *actual* shipped quantities and batches, not just what was initially reserved, to handle picking discrepancies.
    *   **Timing:** Ensure depletion happens only after confirmed shipment to avoid discrepancies if a shipment is cancelled last minute.
    *   **Error Handling:** What if inventory can't find the reservation or the batch to deplete? This indicates a prior process failure.
*   **Verification:**
    *   Unit tests for `ProcessShipmentDepletionUseCase`.
    *   Integration Test: Order shipped in `order_management`/`logistics` -> Inventory creates outbound movement, updates/deletes reservation, COGS calculated (if Phase 1 done).
    *   Verify `InventoryItem` quantities are correctly reduced.
    *   Verify batch-specific quantities are reduced if applicable.

---

### Step 3.4: Handling Customer Returns

*   **Task:** Process customer returns back into inventory, including quality inspection and stock updates.
*   **Modules Involved:** `inventory`, `order_management`
*   **Implementation Details:**
    1.  **Return Authorization & Receipt Trigger (Responsibility: `order_management`):**
        *   `order_management` handles Return Merchandise Authorization (RMA) and confirms receipt of returned goods.
        *   Upon physical receipt and initial inspection, `order_management` notifies the Inventory module.
    2.  **Inventory Module Service/UseCase (`ProcessCustomerReturnUseCase`):**
        *   Input: `returnId` (from `order_management`), `orderId` (original order), list of returned items (`itemId`, `returnedQuantity`, `batchLotNumber` if known/provided, `reasonForReturn`, initial `receivedCondition`).
        *   Logic:
            *   Create an inbound `InventoryMovementModel` (Type: `SALES_RETURN`).
            *   For each `InventoryMovementItemModel`:
                *   Record `itemId`, `returnedQuantity`, `batchLotNumber`.
                *   **Crucially, assign an initial `qualityStatus`** (e.g., 'Pending Inspection', 'Returned-Damaged', 'Returned-Resellable') based on `receivedCondition` or business rules.
                *   The `costAtTransaction` for a return can be complex: it might be the original COGS, current cost, or zero if written off. This needs a business decision. If original COGS is used, `order_management` might need to provide it.
            *   The core inventory quantity for `InventoryItem` (and batch) increases.
    3.  **Quality Inspection & Re-Stocking (Inventory & potentially Quality Module):**
        *   Items with `qualityStatus` 'Pending Inspection' need a separate process.
        *   After inspection, another inventory transaction (Type: `QUALITY_STATUS_CHANGE` or an adjustment) might be needed to move items from 'Pending Inspection' to 'Available/Good' or 'Damaged/Quarantined'.
        *   Only 'Available/Good' stock should become available for new sales.
    4.  **Order Management Update:**
        *   `order_management` updates the return status, processes refunds/credits based on the outcome (including inspection results).
*   **Foolproof Notes:**
    *   **Quarantine by Default:** It's often best practice to receive all returns into a non-sellable (e.g., 'Pending Inspection') status/location by default until explicitly cleared.
    *   **Batch Identification:** Accurately identifying the original batch of a returned item can be challenging if not tracked well. If unknown, it might be treated as a new batch with an unknown cost basis for returns.
    *   **Cost of Returns:** Define how returned items are valued when they re-enter inventory.
*   **Verification:**
    *   Unit tests for `ProcessCustomerReturnUseCase`.
    *   Integration Test: Return processed in `order_management` -> Inventory creates inbound movement with appropriate quality status.
    *   Test subsequent quality inspection process and re-classification of returned stock.
    *   Verify stock levels increase correctly.

---

### Step 3.5: API/Service Layer Definition & Implementation

*   **Task:** Define and implement clear API contracts or service layer methods in both Inventory and Order Management modules for the interactions described above.
*   **Modules Involved:** `inventory`, `order_management`
*   **Implementation Details:**
    1.  **Inventory Module Services Exposed:**
        *   `reserveStock(OrderDetails)`: Returns reservation status.
        *   `getPickSuggestions(OrderId)`: Returns list of items/locations/batches.
        *   `confirmShipment(ShipmentDetails)`: Returns success/failure, COGS.
        *   `processReturn(ReturnDetails)`: Returns success/failure.
    2.  **Order Management Module Services Exposed (or events published):**
        *   Event: `OrderConfirmedEvent(OrderDetails)` (Inventory subscribes or OM calls Inventory service).
        *   Event: `ShipmentConfirmedEvent(ShipmentDetails)`.
        *   Event: `ReturnReceivedEvent(ReturnDetails)`.
    3.  **Data Transfer Objects (DTOs):** Define clear DTOs for requests and responses to ensure consistent data exchange.
*   **Foolproof Notes:**
    *   **Versioning:** Consider API versioning if significant changes are expected in the future.
    *   **Error Handling:** Implement robust error handling and clear error messages for API calls.
    *   **Authentication/Authorization:** Secure inter-module communication if necessary (though likely internal within the same application).
*   **Verification:**
    *   API contracts reviewed and agreed upon by both module teams.
    *   Service methods are testable independently.

---

### Step 3.6: Comprehensive Testing & Quality Assurance

*   **Task:** Conduct thorough testing of all new integrations and functionalities.
*   **Implementation Details:**
    1.  **Unit Tests:** For all new UseCases and service methods in both modules.
    2.  **Integration Tests (Inter-Module):**
        *   Order Confirmation -> Stock Reservation.
        *   Picking List Generation based on Reservations.
        *   Shipment Confirmation -> Inventory Depletion & COGS Calculation.
        *   Return Processing -> Stock Increase & Quality Status Update.
    3.  **End-to-End (E2E) Scenarios:**
        *   Full sales order lifecycle: Create Order -> Confirm (Stock Reserved) -> Pick -> Ship (Inventory Depleted, COGS recorded) -> (Optional) Return (Inventory Updated).
        *   Scenarios with partial shipments, backorders (if reservations fail).
        *   Scenarios with picking discrepancies.
    4.  **User Acceptance Testing (UAT):**
        *   Involve sales/order processing team, warehouse/logistics team, and finance team.
*   **Foolproof Notes:**
    *   Focus on data consistency between `inventory` and `order_management` at each step.
*   **Verification:**
    *   All test cases passed, UAT sign-off.

---

### Step 3.7: Documentation Updates & Team Training

*   **Task:** Update documentation and train relevant teams.
*   **Implementation Details:**
    1.  **Technical Documentation:** API contracts, sequence diagrams for integrations, data flow diagrams.
    2.  **User Documentation:** Updated SOPs for order processing, picking, shipping, and returns handling, highlighting inventory interactions.
    3.  **Team Training:** For sales, warehouse, and finance teams on new workflows.
*   **Verification:** Documentation reviewed, training completed.

---

### Step 3.8: Deployment & Post-Deployment Monitoring

*   **Task:** Plan and execute deployment, and monitor post-deployment.
*   **Implementation Details:**
    1.  **Deployment Plan:** Coordinate deployment of changes in both `inventory` and `order_management` modules (potentially simultaneously or in a defined sequence).
    2.  **Monitoring:** Monitor order processing times, inventory accuracy, reservation success rates, and any errors in the integration points.
*   **Verification:** Successful deployment, stable operation, key metrics monitored.

## 4. Definition of Done (DoD) for Order Management Integration

*   Inventory reservation/allocation for sales orders is implemented and functional.
*   Picking processes are successfully guided by inventory data (reservations, locations, FEFO).
*   Inventory is accurately depleted upon shipment confirmation, and COGS (if Phase 1 done) is communicated.
*   Customer returns are processed back into inventory with appropriate quality status and valuation.
*   All new APIs/services for inter-module communication are implemented, tested, and documented.
*   Comprehensive E2E testing and UAT are completed and signed off.
*   All relevant documentation is updated, and teams are trained.
*   Changes are successfully deployed, and the integration is operating stably.

## 5. Roles & Responsibilities (Example - To be filled by Project Lead)

*   **Project Lead/Manager:** (Name)
*   **Lead Developer (Inventory):** (Name)
*   **Lead Developer (Order Management):** (Name)
*   **Inventory Module Team:** (Names)
*   **Order Management Module Team:** (Names)
*   **Logistics Module Team Lead (if applicable):** (Name)
*   **QA Lead/Team:** (Name/s)
*   **Stakeholders (Sales, Warehouse, Finance):** (Names) - UAT participation.

## 6. Communication Plan

*   Regular joint meetings between Inventory and Order Management development teams.
*   Weekly sync-ups with broader stakeholders.
*   Shared documentation and issue tracking.

---

This plan provides a detailed guide for integrating the Inventory and Order Management modules. Effective collaboration between the teams responsible for these modules will be key to success.
