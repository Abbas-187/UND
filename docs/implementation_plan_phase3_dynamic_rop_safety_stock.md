# Implementation Plan: Industrial Inventory - Phase 3: Dynamic ROP & Safety Stock

**Document Version:** 1.0
**Date:** May 9, 2025
**Focus:** Implementing dynamic calculation of Reorder Points (ROP) and Safety Stock for inventory items, leveraging data from forecasting and supplier modules to optimize stock levels.

## 1. Introduction

This document details the implementation steps for a key component of Phase 3: Dynamic Reorder Point (ROP) & Safety Stock calculation. This initiative aims to move from static ROP/Safety Stock levels to dynamic values that respond to changes in demand forecasts and supplier lead times. This will help optimize inventory levels, reduce holding costs, and minimize stockouts.

**The primary goals are to enable the Inventory module to automatically calculate ROP and Safety Stock for items, use these values for triggering reorder alerts, and notify the Procurement module accordingly.**

## 2. Prerequisites

*   **Phase 1 (Core Inventory Excellence) Completion:** Stable `InventoryItemModel`, `InventoryMovementModel`, and basic inventory operations.
*   **Phase 2 Integrations (Procurement/Supplier):** Access to supplier lead time data from the `supplier` or `procurement` module is essential (as outlined in `implementation_plan_phase2_procurement_supplier_integration.md`).
*   **Forecasting Module (`forecasting`):** A functional `forecasting` module capable of providing demand forecasts (e.g., average daily usage, demand variability) per item.
*   **Defined Data Models:**
    *   `InventoryItemModel` (assumed path: `lib/features/inventory/domain/models/inventory_item_model.dart` or similar) will need to be enhanced.
*   **API/Service Layer Design:** Clear service contracts for inter-module communication (Inventory, Forecasting, Supplier/Procurement).

## 3. Detailed Implementation Steps

---

### Step 3.1: Enhance `InventoryItemModel`

*   **Task:** Add fields to `InventoryItemModel` to store calculated ROP, Safety Stock, and related parameters.
*   **Module Involved:** `inventory`
*   **Implementation Details:**
    1.  Modify `InventoryItemModel` (e.g., in `lib/features/inventory/domain/models/inventory_item_model.dart`) to include:
        *   `double? safetyStockLevel` (calculated safety stock quantity)
        *   `double? reorderPointLevel` (calculated reorder point quantity)
        *   `String? preferredSupplierId` (if not already present, to fetch specific lead times)
        *   `DateTime? lastRopSafetyStockCalculation` (timestamp of the last calculation)
        *   (Optional) Fields to store inputs used in the last calculation, for traceability: `double? avgDailyUsageSnapshot`, `double? demandVariabilitySnapshot`, `double? avgLeadTimeSnapshot`, `double? leadTimeVariabilitySnapshot`, `double? serviceLevelFactorSnapshot`.
*   **Foolproof Notes:**
    *   Ensure data types are appropriate. Nullable fields allow for items where calculation might not be applicable or pending.
*   **Verification:** `InventoryItemModel` updated and new fields are usable.

---

### Step 3.2: Develop ROP & Safety Stock Calculation Service/UseCase

*   **Task:** Create a new service/use case within the Inventory module to calculate dynamic ROP and Safety Stock.
*   **Modules Involved:** `inventory`, `forecasting`, `supplier` (and/or `procurement`)
*   **Implementation Details:**
    1.  **Create `CalculateDynamicRopAndSafetyStockUseCase` (Inventory Module):**
        *   Input: `inventoryItemId` (or a list of item IDs for batch processing).
        *   Output: Updates the `safetyStockLevel` and `reorderPointLevel` (and optional snapshot fields) on the `InventoryItemModel` directly, or returns the calculated values.
    2.  **Data Fetching Logic within the UseCase:**
        *   **Get Demand Forecast:**
            *   Call a service in the `forecasting` module (e.g., `ForecastingService.getDemandForecast(itemId)`).
            *   **Assumption:** This service returns `{ averageDailyUsage, demandVariability, forecastPeriod }` for the given item.
            *   If no forecast data is available, log this and skip calculation for the item or use default/fallback values if defined by business rules.
        *   **Get Supplier Lead Time:**
            *   Determine the `preferredSupplierId` for the `inventoryItemId` (from `InventoryItemModel.preferredSupplierId` or by querying `SupplierService.getItemSuppliers(itemId)`).
            *   Call a service in the `supplier` module (e.g., `SupplierService.getSupplierItemLeadTime(supplierId, itemId)`).
            *   **Assumption:** This service returns `{ averageLeadTimeDays, leadTimeVariability }`.
            *   Alternatively, or as a fallback, query the `procurement` module for actual historical lead times if this data is captured and exposed.
            *   If no lead time data is available, log and skip or use defaults.
        *   **Get Service Level Factor (Z-score):** This value (e.g., 1.65 for 95% service level) should be configurable, potentially per item category or system-wide.
    3.  **Calculation Logic (to be defined precisely based on business requirements):**
        *   **Safety Stock Formula Example:**
            *   `SafetyStock = Z * sqrt((AvgLeadTime * DemandStdDev^2) + (AvgDemand^2 * LeadTimeStdDev^2))`
            *   A simpler alternative if variability data is limited: `SafetyStock = (MaxDailyUsage * MaxLeadTimeInDays) - (AvgDailyUsage * AvgLeadTimeInDays)` (requires `forecasting` and `supplier` modules to provide max values).
            *   **Decision Point:** The exact formula and the source/calculation of variability (StdDev) need to be finalized with business stakeholders.
        *   **Reorder Point Formula Example:**
            *   `ReorderPoint = (AvgDailyUsage * AvgLeadTimeInDays) + SafetyStock`
    4.  **Update `InventoryItemModel`:** Store the calculated `safetyStockLevel`, `reorderPointLevel`, `lastRopSafetyStockCalculation`, and any snapshot fields on the `InventoryItemModel` via its repository.
    5.  **Scheduling/Triggering the Calculation:**
        *   **Option A (Batch):** A scheduled background job (e.g., nightly) that runs `CalculateDynamicRopAndSafetyStockUseCase` for all relevant items or items due for recalculation.
        *   **Option B (Event-Driven):** Trigger recalculation for an item when:
            *   A new demand forecast is available from the `forecasting` module.
            *   Supplier lead time information is updated in the `supplier`/`procurement` module.
            *   Significant, unexpected consumption patterns are detected for an item.
*   **Foolproof Notes:**
    *   **Formula Selection:** The choice of ROP/Safety Stock formulas is critical and depends on data availability and desired accuracy. Consult with inventory management SMEs.
    *   **Data Quality:** The accuracy of calculations heavily depends on the quality of input data from `forecasting` (demand) and `supplier`/`procurement` (lead times).
    *   **Default/Fallback Values:** Define how to handle items with missing forecast or lead time data.
    *   **Service Level Configuration:** Make the Z-score or service level target easily configurable.
*   **Verification:**
    *   Unit tests for `CalculateDynamicRopAndSafetyStockUseCase` with various input data.
    *   Integration tests verifying data fetching from `forecasting` and `supplier`/`procurement` modules.
    *   Calculated ROP/Safety Stock values are correctly stored in `InventoryItemModel`.

---

### Step 3.3: Integrate with Inventory Alerting System

*   **Task:** Modify the existing low stock alert mechanism to use the dynamic `reorderPointLevel`.
*   **Module Involved:** `inventory`
*   **Implementation Details:**
    1.  Identify the existing low stock alert use case (e.g., `GetLowStockAlertsUseCase` or similar).
    2.  Modify its logic to compare `InventoryItem.quantityOnHand` against the new `InventoryItem.reorderPointLevel`.
    3.  Ensure alerts provide sufficient context for reordering (e.g., item ID, current quantity, ROP, preferred supplier, suggested reorder quantity).
*   **Foolproof Notes:** Ensure alerts are timely and actionable.
*   **Verification:** Low stock alerts are correctly triggered based on the dynamic `reorderPointLevel`.

---

### Step 3.4: Integrate with Procurement for Reordering Notification

*   **Task:** Notify the `procurement` module when an item's stock reaches its calculated reorder point, prompting reordering action.
*   **Modules Involved:** `inventory`, `procurement`
*   **Implementation Details:**
    1.  **Notification Mechanism (triggered when `quantityOnHand <= reorderPointLevel`):**
        *   **Option A (Event-Driven):** The Inventory module (e.g., via the alerting system or a dedicated service) publishes an event like `ReorderPointReachedEvent({itemId, currentQuantity, reorderPoint, safetyStock, preferredSupplierId, suggestedReorderQuantity})`.
The `procurement` module subscribes to this event.
        *   **Option B (Direct Service Call):** The Inventory module calls a service exposed by the `procurement` module, e.g., `ProcurementService.initiatePurchaseRequisition({itemId, quantityToOrder, preferredSupplierId})`.
    2.  **Data for Procurement:** Include `itemId`, `currentQuantity`, `reorderPointLevel`, `safetyStockLevel`, `preferredSupplierId`, and a calculated `suggestedReorderQuantity`. The `suggestedReorderQuantity` could be based on reaching an Economic Order Quantity (EOQ) or a simpler "target stock level" (e.g., ROP + Safety Stock, or up to a max stock level).
    3.  The `procurement` module then uses this information to initiate its internal Purchase Requisition or Purchase Order creation workflow.
*   **Foolproof Notes:**
    *   **Clear Contract:** Define a clear and stable contract (event schema or service signature) for communication with `procurement`.
    *   **Reorder Quantity Logic:** The logic for `suggestedReorderQuantity` needs to be defined (e.g., fixed reorder quantity, up to max level, EOQ if available).
*   **Verification:**
    *   When an item hits its ROP, the `procurement` module is correctly notified with all necessary data.
    *   Procurement can successfully initiate its reordering process based on this notification.

---

### Step 3.5: API/Service Layer Definition & Implementation

*   **Task:** Define and implement necessary API contracts or service layer methods.
*   **Modules Involved:** `inventory`, `forecasting`, `supplier`, `procurement`
*   **Implementation Details:**
    1.  **Inventory Module Services Exposed/Used:**
        *   `CalculateDynamicRopAndSafetyStockUseCase` (internal or exposed for schedulers).
        *   (Potentially) `InventoryAlertService` publishing `ReorderPointReachedEvent`.
    2.  **Forecasting Module Services (to be consumed by Inventory - **assumed**):**
        *   `ForecastingService.getDemandForecast(itemId)`: Returns `{ averageDailyUsage, demandVariability, forecastPeriod, maxDailyUsage (optional) }`.
    3.  **Supplier Module Services (to be consumed by Inventory - **partially defined in Phase 2**):**
        *   `SupplierService.getItemSuppliers(itemId)`: Returns list of suppliers, one marked preferred.
        *   `SupplierService.getSupplierItemLeadTime(supplierId, itemId)`: Returns `{ averageLeadTimeDays, leadTimeVariability, maxLeadTimeDays (optional) }`.
    4.  **Procurement Module Services (to be consumed by Inventory or to subscribe to events - **assumed**):**
        *   `ProcurementService.initiatePurchaseRequisition({itemId, quantityToOrder, preferredSupplierId})` (if direct call method is chosen).
        *   Or, Procurement module needs an event listener for `ReorderPointReachedEvent`.
    5.  **Data Transfer Objects (DTOs):** Define for all inter-module communications.
*   **Foolproof Notes:** Ensure service contracts are robust and versioned if necessary.
*   **Verification:** API contracts reviewed, agreed upon, and testable.

---

### Step 3.6: Comprehensive Testing & Quality Assurance

*   **Task:** Conduct thorough testing of the dynamic ROP/Safety Stock functionality.
*   **Implementation Details:**
    1.  **Unit Tests:** For `CalculateDynamicRopAndSafetyStockUseCase`, alert modifications, and procurement notification logic.
    2.  **Integration Tests:**
        *   Inventory fetching data from `forecasting` and `supplier` modules.
        *   Inventory correctly updating `InventoryItemModel` with calculated values.
        *   Alerts triggering based on dynamic ROP.
        *   Procurement notification upon ROP being hit.
    3.  **End-to-End (E2E) Scenarios:**
        *   Simulate changes in demand forecast -> Verify ROP/Safety Stock recalculation -> Verify alert behavior changes.
        *   Simulate changes in supplier lead times -> Verify ROP/Safety Stock recalculation.
        *   Full cycle: Item consumption -> ROP hit -> Alert -> Procurement notification -> (Manual) PO creation.
    4.  **User Acceptance Testing (UAT):** Involve inventory planners, procurement team, and finance (to understand impact on stock holding).
*   **Foolproof Notes:** Test with edge cases: new items, items with no historical data, items with highly variable demand/lead times.
*   **Verification:** All test cases passed, UAT sign-off.

---

### Step 3.7: Documentation Updates & Team Training

*   **Task:** Update documentation and train relevant teams.
*   **Implementation Details:**
    1.  **Technical Documentation:** Formulas used, service APIs, data flow diagrams, scheduling/trigger mechanisms for calculations.
    2.  **User Documentation:** How to interpret dynamic ROP/Safety Stock, how alerts work, impact on procurement process, configuration options (e.g., service levels).
    3.  **Team Training:** For inventory planners, procurement staff.
*   **Verification:** Documentation reviewed, training completed.

---

### Step 3.8: Deployment & Post-Deployment Monitoring

*   **Task:** Plan and execute deployment, and monitor post-deployment.
*   **Implementation Details:**
    1.  **Deployment Plan:** Coordinate deployment of changes in `inventory`, and any necessary interface changes/updates in `forecasting`, `supplier`, `procurement`.
    2.  **Initial Calculation Run:** Plan for an initial run of the calculation service for all relevant items.
    3.  **Monitoring:**
        *   Accuracy of ROP/Safety Stock calculations (compare with manual checks or previous methods initially).
        *   Frequency and accuracy of reorder alerts.
        *   Impact on stockout rates and inventory holding levels over time.
        *   Performance of the calculation service and data fetching processes.
*   **Verification:** Successful deployment, stable operation, key metrics monitored and show expected behavior/improvement.

## 4. Definition of Done (DoD) for Dynamic ROP & Safety Stock

*   `InventoryItemModel` is enhanced to store dynamic ROP, Safety Stock, and related parameters.
*   The `CalculateDynamicRopAndSafetyStockUseCase` is implemented, correctly fetching data from `forecasting` and `supplier`/`procurement` modules, and accurately calculating ROP/Safety Stock based on agreed formulas.
*   Inventory alerts are triggered based on these dynamic `reorderPointLevel` values.
*   The `procurement` module is effectively notified when items reach their reorder points.
*   All new APIs/services are implemented, tested, and documented.
*   Comprehensive E2E testing and UAT are completed and signed off.
*   Relevant documentation is updated, and teams are trained.
*   The system is successfully deployed and monitored, with mechanisms for ongoing review and tuning of calculation parameters.

## 5. Roles & Responsibilities (Example - To be filled by Project Lead)

*   **Project Lead/Manager:** (Name)
*   **Lead Developer (Inventory):** (Name)
*   **Lead Developer (Forecasting):** (Name) - For providing forecast data APIs.
*   **Lead Developer (Supplier/Procurement):** (Name) - For providing lead time data APIs and reorder notification handling.
*   **Inventory Module Team:** (Names)
*   **QA Lead/Team:** (Name/s)
*   **Stakeholders (Inventory Planners, Procurement, Finance):** (Names) - UAT, formula validation.

## 6. Communication Plan

*   Regular joint meetings between Inventory, Forecasting, and Supplier/Procurement development teams.
*   Workshops with SMEs to define and validate calculation formulas and service levels.
*   Shared documentation and issue tracking.

---

This plan provides a detailed guide for implementing Dynamic ROP & Safety Stock. Success hinges on the quality of data from integrated modules and careful selection/validation of the underlying statistical formulas.
