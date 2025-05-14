# Implementation Plan: Industrial Inventory - Phase 2: Procurement & Supplier Module Integration

**Document Version:** 1.0
**Date:** May 9, 2025
**Focus:** Deep integration between the Inventory module and the Procurement (`procurement`) and Supplier (`supplier`) modules for streamlined receiving, accurate stock updates, and leveraging supplier data.

## 1. Introduction

This document outlines the detailed implementation steps for a key component of Phase 2 of the Industrial-Level Inventory Management enhancement: the deep integration with the `procurement` and `supplier` modules. This integration is crucial for ensuring that inventory records accurately reflect inbound supply from purchase orders, for managing returns to suppliers, and for enabling the inventory system to access vital supplier information (like lead times) for better planning.

**The primary goals of this integration are to automate and improve the accuracy of the goods receiving process, maintain precise inventory levels based on procurement activities, and enhance inventory planning by incorporating supplier-specific data.**

## 2. Prerequisites

*   **Phase 1 (FIFO/LIFO Costing) Completion (Highly Recommended):** Accurate `costAtTransaction` capture during receiving is a core part of this integration and relies on Phase 1 foundations.
*   **Defined Procurement Lifecycle:** A clear understanding of the purchase order (PO) lifecycle within the `procurement` module (e.g., PO creation, approval, dispatch to supplier, goods receipt, invoice matching).
*   **Defined Supplier Data Model:** Clarity on what information is stored in the `supplier` module (e.g., supplier details, item-supplier catalogs, lead times, pricing agreements).
*   **Inventory Module Stability:** Core inventory functionalities (item master, stock balances, basic movements) should be stable.
*   **API/Service Layer Design:** Inventory, Procurement, and Supplier modules should ideally expose clear services or APIs for inter-module communication.
*   **Development Environment & Version Control:** Standard setup.

## 3. Detailed Implementation Steps

---

### Step 3.1: PO-Based Goods Receiving Process

*   **Task:** Implement the process where goods received against a Purchase Order in the `procurement` module trigger accurate updates in the Inventory module.
*   **Modules Involved:** `inventory`, `procurement`
*   **Implementation Details:**
    1.  **Goods Receipt Trigger (Responsibility: `procurement` module):**
        *   When warehouse staff record the receipt of goods against a specific PO line item in the `procurement` module (e.g., quantity received, delivery note reference).
    2.  **Data to be Passed from `procurement` to `inventory` (per received item/batch):**
        *   `poNumber` (or `poId`)
        *   `poLineItemId`
        *   `itemId` (the inventory item ID)
        *   `supplierId`
        *   `receivedQuantity`
        *   `batchLotNumber` (if applicable, captured at receiving)
        *   `expirationDate` (if applicable, captured at receiving)
        *   `productionDate` (if applicable, captured at receiving)
        *   `costAtTransaction` (actual cost per unit from PO/supplier invoice – critical for Phase 1 costing)
        *   `deliveryNoteReference` (optional, for audit)
        *   Initial `qualityStatus` (e.g., 'Pending Inspection', 'Received-Good'. Defaulting to 'Pending Inspection' is often best practice).
    3.  **Inventory Module Service/UseCase (`ProcessGoodsReceiptUseCase`):**
        *   Input: The data packet described above from `procurement`.
        *   Logic:
            *   Validate the `itemId`.
            *   Create an inbound `InventoryMovementModel` (Type: `PO_RECEIPT` or `GOODS_RECEIPT`).
            *   For each `InventoryMovementItemModel` created:
                *   Store all received details: `itemId`, `receivedQuantity`, `batchLotNumber`, `expirationDate`, `productionDate`, `costAtTransaction`, initial `qualityStatus`.
                *   Link to `poNumber` or `poLineItemId` in `referenceDocuments` or a dedicated field.
            *   The core inventory quantity for `InventoryItem` (and specific batch if tracked granularly) increases.
            *   Return success/failure status to `procurement`.
    4.  **Procurement Module Update:**
        *   Update PO status (e.g., 'Partially Received', 'Fully Received').
        *   Handle discrepancies (e.g., quantity received differs from quantity ordered).
*   **Foolproof Notes:**
    *   **Data Consistency:** Ensure `itemId` used in `procurement` maps correctly to `InventoryItem.id`.
    *   **Cost Source:** `costAtTransaction` must be the actual landed cost if possible, or at least the agreed PO price. `Procurement` is responsible for providing this.
    *   **Batch/Expiry Capture:** Make batch and expiry date capture mandatory at receiving for items configured as batch/expiry controlled in the Inventory module.
    *   **Error Handling:** If Inventory cannot process the receipt (e.g., invalid item), `procurement` needs a clear error and a way to rectify.
*   **Verification:**
    *   Unit tests for `ProcessGoodsReceiptUseCase`.
    *   Integration Test: `procurement` records a receipt -> `inventory` creates inbound movement with all correct details (batch, expiry, cost, quality status) and quantity updates.
    *   Test with partial receipts, over-receipts (if allowed by business rules).

---

### Step 3.2: Handling Returns to Suppliers

*   **Task:** Implement the process for recording inventory depletion when goods are returned to a supplier via the `procurement` module.
*   **Modules Involved:** `inventory`, `procurement`
*   **Implementation Details:**
    1.  **Return to Supplier Trigger (Responsibility: `procurement` module):**
        *   When `procurement` processes a return to a supplier (e.g., due to defects found during inspection, incorrect items received).
    2.  **Data to be Passed from `procurement` to `inventory` (per returned item/batch):**
        *   `returnToSupplierId` (or similar reference from `procurement`)
        *   `poNumber` (original PO if applicable)
        *   `itemId`
        *   `supplierId`
        *   `returnedQuantity`
        *   `batchLotNumber` (CRITICAL - must specify which batch is being returned)
        *   `reasonForReturn`
    3.  **Inventory Module Service/UseCase (`ProcessReturnToSupplierUseCase`):**
        *   Input: Data packet from `procurement`.
        *   Logic:
            *   Validate `itemId` and `batchLotNumber` to ensure stock exists.
            *   Determine the `costAtTransaction` of the batch being returned (this would be the original cost when it was received – requires querying historical inbound movements based on the batch).
            *   Create an outbound `InventoryMovementModel` (Type: `RETURN_TO_SUPPLIER`).
            *   The `InventoryMovementItemModel` should record `itemId`, `returnedQuantity`, `batchLotNumber`, and the determined `costAtTransaction` (for accurate reduction of inventory value).
            *   Link to `returnToSupplierId` in `referenceDocuments`.
            *   The core inventory quantity for `InventoryItem` (and specific batch) decreases.
            *   Return success/failure to `procurement`.
    4.  **Procurement Module Update:**
        *   Update status of the return process, manage credit notes, etc.
*   **Foolproof Notes:**
    *   **Batch Specificity:** Returns *must* be batch-specific if the item is batch-controlled to ensure correct stock and cost layer depletion.
    *   **Costing:** Accurately identifying the cost of the returned batch is important for correct inventory valuation adjustments.
    *   **Availability Check:** Ensure the specified batch and quantity are actually available in inventory before processing the return movement.
*   **Verification:**
    *   Unit tests for `ProcessReturnToSupplierUseCase`.
    *   Integration Test: `procurement` processes a return -> `inventory` creates outbound movement, depletes the correct batch, uses correct cost for valuation adjustment.
    *   Test returning items from different batches/costs.

---

### Step 3.3: Accessing Supplier Information for Inventory Planning

*   **Task:** Enable the Inventory module (or related planning services) to access supplier-specific data (e.g., lead times, supplier-item relationships) for improved planning (e.g., Dynamic ROP/Safety Stock in Phase 3).
*   **Modules Involved:** `inventory`, `supplier`, `procurement` (as it might link items to preferred suppliers from POs)
*   **Implementation Details:**
    1.  **Define Data Needs:** Inventory planning (specifically for Dynamic ROP/Safety Stock) needs:
        *   Default/Preferred Supplier per Item.
        *   Supplier-Specific Lead Time (average, variability) for an item.
    2.  **Supplier Module Service/API (`SupplierService`):**
        *   Expose methods like:
            *   `getSupplierDetails(supplierId)`
            *   `getItemSuppliers(itemId)`: Returns a list of suppliers for an item, potentially with preference flags.
            *   `getSupplierItemLeadTime(supplierId, itemId)`: Returns lead time information.
    3.  **Procurement Module Data (Optional Enhancement):**
        *   The `procurement` module could maintain data on actual lead times experienced from PO issue to receipt for specific supplier-item combinations. This historical data is more accurate than static lead times.
    4.  **Inventory Module/Planning Service Access:**
        *   The service responsible for calculating Dynamic ROP/Safety Stock (to be built in Phase 3) will call the `SupplierService` (and potentially `ProcurementService` for actual lead times) to fetch this data.
*   **Foolproof Notes:**
    *   **Data Maintenance:** Supplier lead times and item-supplier relationships must be accurately maintained in the `supplier` module (or `procurement` for actuals).
    *   **Default vs. Actual:** Differentiate between standard/contractual lead times and actual observed lead times.
*   **Verification:**
    *   API contracts for `SupplierService` reviewed and agreed.
    *   Test calls to `SupplierService` to ensure correct data retrieval.
    *   (For Phase 3) Verify that the ROP/Safety Stock calculations correctly use this supplier data.

---

### Step 3.4: API/Service Layer Definition & Implementation

*   **Task:** Define and implement clear API contracts or service layer methods in Inventory, Procurement, and Supplier modules for the interactions described.
*   **Modules Involved:** `inventory`, `procurement`, `supplier`
*   **Implementation Details:**
    1.  **Inventory Module Services Exposed:**
        *   `processGoodsReceipt(ReceiptDetails)`: Returns success/failure.
        *   `processReturnToSupplier(ReturnToSupplierDetails)`: Returns success/failure.
    2.  **Procurement Module Services Exposed (or events published):**
        *   Event: `GoodsReceivedAgainstPOEvent(ReceiptDetails)` (Inventory subscribes or Procurement calls Inventory service).
        *   Event: `ItemsReturnedToSupplierEvent(ReturnToSupplierDetails)`.
        *   (Optional) Service: `getActualItemLeadTimes(itemId, supplierId)`.
    3.  **Supplier Module Services Exposed:**
        *   `getItemSuppliers(itemId)`.
        *   `getSupplierItemLeadTime(supplierId, itemId)`.
    4.  **Data Transfer Objects (DTOs):** Define clear DTOs for requests and responses.
*   **Foolproof Notes:** Versioning, error handling, security as per previous plans.
*   **Verification:** API contracts reviewed, services testable independently.

---

### Step 3.5: Comprehensive Testing & Quality Assurance

*   **Task:** Conduct thorough testing of all new integrations and functionalities.
*   **Implementation Details:**
    1.  **Unit Tests:** For all new UseCases and service methods in all involved modules.
    2.  **Integration Tests (Inter-Module):**
        *   PO Goods Receipt in `procurement` -> Inventory Update.
        *   Return to Supplier in `procurement` -> Inventory Update.
        *   Inventory Planning Service -> `supplier` module data retrieval.
    3.  **End-to-End (E2E) Scenarios:**
        *   Full PO lifecycle: Create PO -> Approve PO -> Dispatch -> Receive Goods (Inventory updated with cost, batch, etc.) -> (Optional) Return to Supplier (Inventory updated).
    4.  **User Acceptance Testing (UAT):**
        *   Involve procurement team, warehouse receiving team, and finance team (for cost verification).
*   **Foolproof Notes:** Focus on data accuracy (quantities, costs, batches, dates) across modules.
*   **Verification:** All test cases passed, UAT sign-off.

---

### Step 3.6: Documentation Updates & Team Training

*   **Task:** Update documentation and train relevant teams.
*   **Implementation Details:**
    1.  **Technical Documentation:** API contracts, sequence diagrams, data flow for procurement-inventory and supplier-inventory interactions.
    2.  **User Documentation:** Updated SOPs for goods receiving, returns to suppliers.
    3.  **Team Training:** For procurement, warehouse, and finance teams.
*   **Verification:** Documentation reviewed, training completed.

---

### Step 3.7: Deployment & Post-Deployment Monitoring

*   **Task:** Plan and execute deployment, and monitor post-deployment.
*   **Implementation Details:**
    1.  **Deployment Plan:** Coordinate deployment of changes in `inventory`, `procurement`, and `supplier` modules.
    2.  **Monitoring:** Monitor PO processing, goods receipt accuracy, inventory level updates, and any errors in integration points.
*   **Verification:** Successful deployment, stable operation, key metrics monitored.

## 4. Definition of Done (DoD) for Procurement & Supplier Integration

*   Goods receipts from `procurement` accurately update inventory, including quantities, batch/lot, expiry dates, `costAtTransaction`, and initial quality status.
*   Returns to suppliers processed in `procurement` accurately deplete the correct inventory batches and adjust valuation.
*   Inventory module (or related planning services) can successfully access necessary item-supplier linkage and lead time data from the `supplier` (and optionally `procurement`) module.
*   All new APIs/services for inter-module communication are implemented, tested, and documented.
*   Comprehensive E2E testing and UAT are completed and signed off.
*   All relevant documentation is updated, and teams are trained.
*   Changes are successfully deployed, and the integration is operating stably.

## 5. Roles & Responsibilities (Example - To be filled by Project Lead)

*   **Project Lead/Manager:** (Name)
*   **Lead Developer (Inventory):** (Name)
*   **Lead Developer (Procurement):** (Name)
*   **Lead Developer (Supplier):** (Name)
*   **Inventory Module Team:** (Names)
*   **Procurement Module Team:** (Names)
*   **Supplier Module Team:** (Names)
*   **QA Lead/Team:** (Name/s)
*   **Stakeholders (Procurement, Warehouse, Finance):** (Names) - UAT participation.

## 6. Communication Plan

*   Regular joint meetings between Inventory, Procurement, and Supplier development teams.
*   Weekly sync-ups with broader stakeholders.
*   Shared documentation and issue tracking.

---

This plan provides a detailed guide for integrating the Inventory, Procurement, and Supplier modules. Clear communication and collaboration across these module teams are essential for a successful implementation.
