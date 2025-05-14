# Industrial-Level Inventory Management Master Plan

**Current Date:** May 9, 2025

## Overarching Principles:

1.  **Single Source of Truth:** Inventory module is the definitive source for all stock quantities, locations, batches, and statuses.
2.  **Real-Time Data Flow:** Changes in related modules (e.g., sales order, PO receipt) must reflect in inventory immediately.
3.  **End-to-End Traceability:** Track items from raw material receipt (e.g., `milk_reception`) through any internal processes to final customer shipment (`order_management`, `logistics`).
4.  **Financial Accuracy:** Implement robust costing and valuation that can feed into financial reporting.
5.  **Proactive & Demand-Driven:** Utilize `forecasting` and `CRM` insights for intelligent stock planning.
6.  **Operational Efficiency:** Streamline warehouse operations through integration with `logistics`.
7.  **Comprehensive Quality Management:** Integrate quality checks at critical inventory touchpoints.
8.  **Scalability & Performance:** Design for high transaction volumes and large SKU counts.

## Strategic Plan:

### Phase 1: Core Inventory Excellence & Financial Integrity

*   **Focus:** Solidify the inventory module's internal capabilities and establish accurate financial tracking.
*   **Actions:**
    1.  **Implement True FIFO/LIFO Costing (Inventory Core):**
        *   **Goal:** Accurate inventory valuation and COGS.
        *   **Steps:**
            *   Modify `InventoryMovementItemModel`: Add `double? costAtTransaction`.
            *   Update Inventory Data Layer: Capture `costAtTransaction` for inbound movements (especially from `procurement` receipts and `milk_reception`).
            *   Implement FIFO/LIFO logic for valuing outbound movements (to `order_management` fulfillment, internal consumption).
            *   Define the role of `InventoryItem.cost` (e.g., latest, standard, or weighted average, updated based on receipts).
            *   Develop robust inventory valuation reports.
        *   **Integration:**
            *   **Procurement/Milk Reception:** Must provide item cost at the time of receipt to populate `costAtTransaction`.
    2.  **Refine Batch/Lot & Expiry Date Management (Inventory Core):**
        *   **Goal:** Flawless tracking of perishable and batch-controlled items.
        *   **Steps:**
            *   Ensure `batchLotNumber`, `productionDate`, `expirationDate` are mandatory and accurately captured for relevant items on *all* `InventoryMovementItemModel` instances.
            *   Strengthen `CalculateInventoryAgingUsecase` and `GetLowStockAlertsUseCase` (for expiring items) to be highly accurate.
            *   Implement strict FEFO (First-Expired, First-Out) logic for picking suggestions if not already present.
        *   **Integration:**
            *   **Milk Reception:** Critical source for batch/expiry data of raw materials.
            *   **Order Management:** Picking processes must respect FEFO based on inventory data.
    3.  **Strengthen Core Inventory Transactions & Auditability (Inventory Core):**
        *   **Goal:** Ensure every stock movement is accurately recorded, justified, and auditable.
        *   **Steps:**
            *   Review `InventoryMovementType` enum: Ensure it covers all possible scenarios (Receipts, Issues, Sales, Returns, Adjustments-Damage, Adjustments-CycleCount, Transfers, Quality Status Changes, Production Consumption, Production Output).
            *   Enforce mandatory `reasonNotes` and `referenceDocuments` (e.g., PO number, Sales Order number, Transfer ID) for all adjustments and relevant movements.
            *   Ensure `initiatingEmployeeId` is captured for all manual interventions.

#### Technical Implementation Notes (Phase 1)
- **State Management:** Use Riverpod providers for all inventory state and business logic. Each inventory entity (items, movements, batches) will have its own provider.
- **Data Layer:** Use Firebase Firestore for persistent storage. All inventory transactions will use batched writes or transactions for atomicity. Security rules will be updated to protect sensitive inventory data.
- **Model Management:** Use Freezed for immutable models and JsonSerializable for (de)serialization. All inventory models will be generated and kept in sync.
- **Testing:** Implement unit and integration tests for FIFO/LIFO, FEFO, and audit logic using Flutter's test framework.
- **Error Handling:** All async operations will use robust error handling, with user feedback and retry mechanisms as needed.

### Phase 2: Seamless Integration with Sales, Procurement & Production

*   **Focus:** Create a tight loop between demand, supply, and inventory operations.
*   **Actions:**
    1.  **Deep Integration with Order Management (`order_management`):**
        *   **Goal:** Real-time inventory reservation, allocation, and depletion based on sales orders.
        *   **Steps (Inventory & Order Management):**
            *   **Reservation:** When a sales order is confirmed in `order_management`, inventory should be ableto "reserve" or "allocate" stock (potentially a new status on `InventoryItem` or a separate `InventoryReservation` entity linked to `batchLotNumber`).
            *   **Picking:** `Order Management` picking process queries inventory for available stock (respecting FEFO, reservations, quality status).
            *   **Depletion:** On shipment confirmation in `order_management`/`logistics`, inventory records are depleted, triggering an `InventoryMovementModel` (Type: SALE/SHIPMENT).
            *   **Returns:** Customer returns processed in `order_management` trigger an inbound `InventoryMovementModel` (Type: SALES_RETURN), potentially with quality status checks.
    2.  **Deep Integration with Procurement (`procurement`) & Supplier Module:**
        *   **Goal:** Streamline the receiving process and ensure inventory reflects inbound supply accurately.
        *   **Steps (Inventory & Procurement):**
            *   **PO-Based Receiving:** When goods are received against a PO in `procurement`:
                *   Inventory module creates an inbound `InventoryMovementModel` (Type: PO_RECEIPT).
                *   `InventoryMovementItemModel` captures `batchLotNumber`, `expiryDate`, `costAtTransaction` (from PO/supplier invoice), and initial `qualityStatus` (e.g., "Pending Inspection").
            *   **Supplier Returns:** Returns to suppliers processed in `procurement` trigger an outbound `InventoryMovementModel`.
    3.  **(If Applicable) Integration with Production/Manufacturing Module (e.g., if `milk_reception` feeds into a production process before becoming sellable inventory):**
        *   **Goal:** Track consumption of raw materials/components and creation of finished goods.
        *   **Steps:**
            *   **Raw Material Consumption:** Production start triggers outbound `InventoryMovementModel` for raw materials (Type: PRODUCTION_ISSUE).
            *   **Finished Goods Creation:** Production completion triggers inbound `InventoryMovementModel` for finished goods (Type: PRODUCTION_OUTPUT), capturing new batch numbers, expiry dates, and production costs (if calculated).

#### Technical Implementation Notes (Phase 2)
- **State Management:** Use Riverpod providers to coordinate state between inventory, order management, and procurement modules. Use providers to expose reservation and allocation logic.
- **Data Layer:** Use Firestore transactions for cross-module updates (e.g., reservation, picking, shipment). Ensure all references (e.g., batchLotNumber) are indexed for efficient queries.
- **Model Management:** Extend Freezed models to include reservation and integration fields. Use JsonSerializable for all cross-module data exchange.
- **Testing:** Write integration tests for reservation, picking, and depletion flows, including edge cases (e.g., partial shipments, returns).
- **Error Handling:** Implement rollback and compensation logic for failed cross-module transactions.

### Phase 3: Advanced Planning, Optimization & Quality Control

*   **Focus:** Leveraging data for smarter inventory decisions and efficient warehouse operations.
*   **Actions:**
    1.  **Dynamic ROP & Safety Stock (Inventory, `forecasting`, `procurement`/`supplier`):**
        *   **Goal:** Optimize stock levels based on dynamic data.
        *   **Steps:**
            *   Inventory's `InventoryItem` stores `reorderPoint`, `safetyStock`.
            *   A dedicated service (in Inventory or shared) calculates these:
                *   Pulls demand forecasts (e.g., `averageDailyUsage`, `demandVariability`) from the `forecasting` module.
                *   Pulls supplier lead times (`averageLeadTimeDays`, `leadTimeVariability`) from the `procurement`/`supplier` module.
            *   Inventory alerts use these dynamic values. `Procurement` module is notified for reordering.
    2.  **Formal Cycle Counting & ABC Analysis (Inventory Core):**
        *   **Goal:** Improve accuracy and apply differentiated control.
        *   **Steps:**
            *   Implement `CycleCountPlan`, `CycleCountItem` entities and related use cases.
            *   Implement `PerformABCAnalysisUseCase`; store `abcCategory` on `InventoryItem`. Use this to prioritize cycle counts.
    3.  **Integrated Quality Management (Inventory, `milk_reception`, `procurement`, `order_management`):**
        *   **Goal:** Ensure quality throughout the inventory lifecycle.
        *   **Steps:**
            *   **Receiving Inspection:**
                *   `Milk Reception`: Perform quality tests; resulting quality status (e.g., "Approved", "Rejected", "Hold") updates the `InventoryMovementItemModel` and potentially the `InventoryItem` batch status.
                *   `Procurement` Receipts: Similar inspection process for other goods.
            *   **In-Stock Quality Status:** Allow changing `qualityStatus` of stored batches (e.g., from "Approved" to "Hold" due to later findings) via an `InventoryMovementModel` (Type: QUALITY_STATUS_CHANGE).
            *   **Pre-Shipment Checks:** `Order Management`/`Logistics` can query inventory for `qualityStatus` before picking/shipping to ensure only approved stock is sent.
    4.  **Advanced Location Management & Warehouse Optimization (Inventory, `logistics`):**
        *   **Goal:** Efficient storage and retrieval.
        *   **Steps:**
            *   Review `InventoryLocationModel`: If not already, define a hierarchical structure (Warehouse > Zone > Aisle > Rack > Bin).
            *   Store `InventoryItem` quantities at the most granular bin level.
            *   **Integration with `Logistics`:**
                *   `Logistics` module could provide optimal putaway suggestions to Inventory upon receipt.
                *   `Logistics` module could generate optimized picking paths based on order requirements and inventory bin locations.
                *   Inventory updates bin quantities based on `Logistics` driven movements.

#### Technical Implementation Notes (Phase 3)
- **State Management:** Use Riverpod providers for dynamic stock calculations, cycle count plans, and quality status updates. Providers will react to changes in forecasting and procurement modules.
- **Data Layer:** Store ROP, safety stock, and ABC category in Firestore. Use batch updates for cycle counts and quality status changes. Integrate with forecasting and procurement modules via shared Firestore collections or Cloud Functions.
- **Model Management:** Extend Freezed models for new fields (ROP, safety stock, abcCategory, qualityStatus). Use JsonSerializable for all new entities.
- **Testing:** Add tests for dynamic stock calculations, cycle counting, and quality management flows.
- **Error Handling:** Ensure all quality and cycle count updates are atomic and auditable.

### Phase 4: Comprehensive Analytics, Reporting & Continuous Improvement

*   **Focus:** Providing deep insights for strategic decision-making and ongoing optimization.
*   **Actions:**
    1.  **Advanced Inventory Analytics & Dashboards (Inventory, leveraging data from all integrated modules):**
        *   **Goal:** Provide actionable insights.
        *   **Steps:**
            *   Develop dashboards for:
                *   Inventory turnover rates (by item, category).
                *   Stockout rates and reasons (linked to `forecasting` accuracy).
                *   Excess and obsolete stock (E&O) analysis.
                *   Inventory aging details beyond basic expiry (e.g., slow-moving non-perishables).
                *   Supplier delivery performance impact on inventory (from `procurement`/`supplier`).
                *   Cost variance analysis (if standard costing is also used).
                *   Traceability reports (full history of a batch).
    2.  **Integration with CRM for Demand Insights (Inventory, `CRM`, `forecasting`):**
        *   **Goal:** Refine demand signals.
        *   **Steps:**
            *   `CRM` data (e.g., sales pipeline, promotional activities) can be fed into the `forecasting` module.
            *   Inventory can then consume these more refined forecasts.
            *   (Optional) Functionality for reserving stock for key CRM opportunities.
    3.  **Feedback Loops for Continuous Improvement:**
        *   **Inventory to Forecasting:** Provide actual consumption data and stockout incidents to help the `forecasting` module refine its models.
        *   **Inventory to Procurement/Supplier:** Share data on receiving discrepancies, quality issues on arrival, and actual lead times to improve supplier collaboration and performance.

#### Technical Implementation Notes (Phase 4)
- **State Management:** Use Riverpod providers to aggregate and expose analytics data to the UI. Use providers to trigger dashboard updates on data changes.
- **Data Layer:** Use Firestore aggregations and/or Cloud Functions for analytics calculations. Store dashboard data in dedicated collections for fast access.
- **Model Management:** Use Freezed for analytics models and reporting entities. Use JsonSerializable for dashboard data.
- **Testing:** Implement tests for analytics calculations and dashboard rendering.
- **Error Handling:** Ensure analytics and reporting gracefully handle missing or inconsistent data.

### Cross-Cutting Concerns (Applicable to all Phases):

1.  **Security & Permissions (Integrate with HR/User Management):**
    *   Implement role-based access control for all inventory functions.
    *   Ensure actions are logged with user identity.
2.  **Scalability & Performance (Firebase & Application Architecture):**
    *   Optimize Firebase queries.
    *   Consider data denormalization strategies carefully.
    *   Implement robust error handling and retry mechanisms for inter-module communication.
    *   Plan for data archiving.
3.  **Documentation & Training:**
    *   Thoroughly document all new features, integration points, and data flows.
    *   Develop training materials.
