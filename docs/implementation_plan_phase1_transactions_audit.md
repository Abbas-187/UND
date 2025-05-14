# Implementation Plan: Industrial Inventory - Phase 1: Core Transactions & Auditability

**Document Version:** 1.0
**Date:** May 9, 2025
**Focus:** Ensure every stock movement is accurately recorded, justified, and auditable.

## 1. Introduction

This document details the implementation steps for Phase 1's action on strengthening core inventory transactions and auditability. The primary objective is to ensure that all inventory movements are comprehensive, carry necessary justifications, are linked to responsible personnel, and can be easily traced for audit and operational review purposes.

## 2. Prerequisites

*   **Familiarity with Core Models:** Deep understanding of `InventoryMovementModel`, `InventoryMovementItemModel`, and the `InventoryMovementType` enum.
*   **Authentication System:** An existing system to identify the `initiatingEmployeeId`.
*   **Development Environment:** Standard Flutter development environment and access to the codebase.
*   **Version Control:** All changes managed via Git.

## 3. Detailed Implementation Steps

---

### Step 3.1: Review and Enhance `InventoryMovementType` Enum

*   **Task:** Ensure the `InventoryMovementType` enum comprehensively covers all possible inventory transaction scenarios.
*   **File:** `lib/features/inventory/models/inventory_movement_model.dart` (or where `InventoryMovementType` is defined, e.g., `lib/features/inventory/domain/entities/inventory_movement_type.dart`).
*   **Implementation Details:**
    1.  **Audit Existing Types:** List all current values in the `InventoryMovementType` enum.
    2.  **Compare with Master Plan:** Cross-reference with the types mentioned in the `industrial_inventory_master_plan.md`:
        *   Receipts (e.g., `PO_RECEIPT`, `PRODUCTION_OUTPUT`, `SALES_RETURN`, `TRANSFER_IN`)
        *   Issues (e.g., `PRODUCTION_ISSUE`, `TRANSFER_OUT`)
        *   Sales (e.g., `SALE_SHIPMENT`)
        *   Adjustments (e.g., `ADJUSTMENT_DAMAGE`, `ADJUSTMENT_CYCLE_COUNT_GAIN`, `ADJUSTMENT_CYCLE_COUNT_LOSS`, `ADJUSTMENT_OTHER`)
        *   Quality Status Changes (e.g., `QUALITY_STATUS_UPDATE`)
    3.  **Add Missing Types:** Introduce new enum values for any identified gaps. Ensure clear and descriptive names.
    4.  **Review Usage:** Check where each existing type is used to ensure it aligns with its intended meaning.
*   **Foolproof Notes:**
    *   Consider if any existing types are ambiguous or could be split for clarity (e.g., a generic `ADJUSTMENT` vs. specific types).
    *   Ensure a consistent naming convention for enum values.
*   **Verification:**
    *   Code review of the enum changes.
    *   A quick search through the codebase to identify all places where `InventoryMovementType` is set, ensuring they use appropriate and existing values after the update.

---

### Step 3.2: Enforce Mandatory `reasonNotes` and `referenceDocuments`

*   **Task:** Make `reasonNotes` and `referenceDocuments` fields conditionally mandatory in `InventoryMovementModel` based on the `InventoryMovementType`.
*   **File:** `lib/features/inventory/models/inventory_movement_model.dart`
*   **Implementation Details:**
    1.  **Identify Mandatory Scenarios:** For each `InventoryMovementType`, determine if `reasonNotes` and/or `referenceDocuments` should be mandatory.
        *   `reasonNotes`: Likely mandatory for all `ADJUSTMENT_*` types, `QUALITY_STATUS_UPDATE`.
        *   `referenceDocuments`: Likely mandatory for `PO_RECEIPT` (PO Number), `SALE_SHIPMENT` (Sales Order Number), `SALES_RETURN` (RMA Number/Original SO), `TRANSFER_*` (Transfer ID).
    2.  **Model Fields:** Ensure `reasonNotes` (String?) and `referenceDocuments` (List<String>? or Map<String, String>?) exist in `InventoryMovementModel`.
    3.  **Validation Logic:**
        *   In the constructor or `copyWith` method of `InventoryMovementModel`, or in the UseCases that create instances of it (e.g., `AddInventoryMovementUseCase`):
            *   Implement logic to check for the presence of these fields based on the `movementType`.
            *   If a required field is missing, throw a validation error or prevent saving.
    4.  **UI/Service Layer Updates:**
        *   Ensure UIs or service layers responsible for initiating these types of movements collect this information from the user or system.
*   **Foolproof Notes:**
    *   `referenceDocuments` could be a simple `String?` if only one reference is typical, or a `List<String>?` if multiple are possible (e.g. PO number and Delivery Note number).
    *   Be clear about what constitutes a valid reference for each type.
*   **Verification:**
    *   Unit tests for `InventoryMovementModel` validation logic or relevant UseCase validation.
    *   Manual testing of UI flows that create movements, ensuring users are prompted for required information.
    *   Check that movements created without required fields (if attempted programmatically) are rejected.

---

### Step 3.3: Capture `initiatingEmployeeId` for All Movements

*   **Task:** Ensure `initiatingEmployeeId` is captured for all inventory movements, distinguishing between manual interventions and system-driven actions.
*   **File:** `lib/features/inventory/models/inventory_movement_model.dart`
*   **Implementation Details:**
    1.  **Model Field:** Ensure `initiatingEmployeeId` (String?) field exists in `InventoryMovementModel`.
    2.  **Population Logic:**
        *   **Manual Movements:** For movements initiated directly by a user (e.g., manual adjustments, cycle counts, possibly some transfers), the UseCase handling the action must retrieve the current authenticated user's ID and populate this field.
        *   **System-Driven Movements:** For movements triggered by other modules or automated processes (e.g., `SALE_SHIPMENT` triggered by `order_management` fulfillment, `PO_RECEIPT` triggered by `procurement`):
            *   Decide on a convention: either a specific system user ID (e.g., "SYSTEM_ORDER_MGMT") or leave it null if the context is clear from `referenceDocuments` and `movementType`.
            *   The calling module/service should provide this information or it should be inferred by the inventory UseCase.
*   **Foolproof Notes:**
    *   Ensure the user authentication system provides a stable and unique ID for employees.
*   **Verification:**
    *   Code review of UseCases creating movements to ensure `initiatingEmployeeId` is populated.
    *   Test various movement creation scenarios (manual adjustment, sales order fulfillment) and verify the `initiatingEmployeeId` in the persisted `InventoryMovementModel` data.

---

### Step 3.4: Develop/Enhance Audit Trail Reporting/Viewing Capabilities

*   **Task:** Provide robust, user-friendly, and performant capabilities to view, filter, and analyze inventory movement history for audit and operational analysis.
*   **Files:**
    *   New or existing UseCase: e.g., `GetInventoryMovementHistoryUseCase.dart` in `lib/features/inventory/domain/usecases/`.
    *   New or existing UI components/screens for displaying audit trails (e.g., `InventoryAuditTrailScreen`).
*   **Implementation Details:**
    1.  **`GetInventoryMovementHistoryUseCase`:**
        *   **Input Parameters:** Allow filtering by:
            *   `itemId` (String)
            *   `batchLotNumber` (String)
            *   Date range (`startDate`, `endDate`)
            *   `InventoryMovementType`
            *   `initiatingEmployeeId` (String)
            *   `referenceDocument` (String - partial match or specific key-value if structured)
            *   `locationId` (String)
        *   **Output:** A list of `InventoryMovementModel` (or a summarized view model) matching the criteria, sorted by timestamp.
        *   **Performance:**
            *   Optimize repository queries for large datasets (e.g., Firestore composite indexes, server-side filtering where possible).
            *   Paginate results for very large audit trails.
    2.  **Repository Method:** The `InventoryRepository` will need a corresponding method to query Firestore based on these filters. Ensure queries are efficient and indexed.
    3.  **UI/UX:**
        *   Develop a dedicated screen (e.g., `InventoryAuditTrailScreen`) where users (admins/managers/auditors) can:
            *   Apply multiple filters (all above fields) with a clear, responsive form.
            *   View results in a sortable, paginated table or list.
            *   See key information: Timestamp, Item, Batch, Type, Quantity, From/To Location, Employee, Reason, References.
            *   Click into a movement for full details (drill-down modal or detail page).
            *   Export filtered results to CSV/Excel for offline analysis or sharing with auditors.
            *   Print or generate PDF reports of filtered audit trails.
        *   Ensure the UI is accessible and usable on both desktop and mobile devices.
        *   Provide loading indicators, error handling, and empty state messages.
    4.  **Security & Access Control:**
        *   Restrict access to audit trail features to authorized roles (e.g., admin, audit, finance).
        *   Log all access to audit trail data for compliance.
    5.  **Testing & Verification:**
        *   Unit tests for the `GetInventoryMovementHistoryUseCase` with various filter combinations.
        *   Integration tests for the repository method querying Firestore.
        *   UI tests for the audit trail screen, including filter application, export, and navigation.
        *   Manual testing of the audit trail screen with realistic data.
        *   UAT with finance/audit teams to validate usability and completeness.
    6.  **Documentation:**
        *   Update user and technical documentation to cover new audit trail features, filters, and export/reporting options.

*   **Foolproof Notes:**
    *   Optimize Firestore queries for performance, especially with multiple filters and large datasets. Consider indexing strategies and pagination.
    *   Ensure the UI is user-friendly, accessible, and supports export/print for compliance needs.
    *   Document all new features and train users as needed.

*   **Verification:**
    *   All test cases pass, including filter, export, and access control scenarios.
    *   UAT sign-off from relevant stakeholders (finance, audit, operations).
    *   Documentation updated and users trained.

---

### Step 3.5: Comprehensive Testing & Quality Assurance

*   **Task:** Conduct thorough testing of all changes related to transaction recording and auditability.
*   **Implementation Details:**
    1.  **Unit Tests:** For enum changes, validation logic in models/UseCases, `initiatingEmployeeId` population, and audit trail UseCase.
    2.  **Integration Tests:** Test saving and retrieving `InventoryMovementModel` with all new enforcement rules.
    3.  **End-to-End (E2E) Scenarios:**
        *   Create various types of movements (adjustment, receipt, sale) ensuring all required fields (`reasonNotes`, `referenceDocuments`, `initiatingEmployeeId`) are captured correctly.
        *   Use the audit trail feature to find and verify these specific movements.
    4.  **User Acceptance Testing (UAT):**
        *   Involve finance/audit teams to validate the completeness and accuracy of the audit trail.
        *   Involve operations teams to confirm usability of reason/reference capture.
*   **Verification:** All test cases passed, UAT sign-off.

---

### Step 3.6: Documentation Updates & Team Training

*   **Task:** Update documentation and train relevant teams on new procedures.
*   **Implementation Details:**
    1.  **Technical Documentation:** Document `InventoryMovementType` changes, validation rules for `reasonNotes`/`referenceDocuments`, and `initiatingEmployeeId` capture.
    2.  **User Documentation:** Guide users on when and how to provide reasons/references. Explain how to use the audit trail feature.
    3.  **Training:** Sessions for developers, operations staff, and anyone involved in inventory transactions or auditing.
*   **Verification:** Documentation reviewed, training completed.

---

### Step 3.7: Deployment & Post-Deployment Monitoring

*   **Task:** Plan and execute deployment, and monitor post-deployment.
*   **Implementation Details:**
    1.  **Deployment Plan:** Standard deployment procedures.
    2.  **Data Migration (Consideration):** Existing `InventoryMovementModel` records will not have the new mandatory fields enforced. Decide if any backfilling is necessary or if rules apply strictly to new movements.
    3.  **Monitoring:** Monitor logs for any validation errors during movement creation. Periodically review audit trails for completeness.
*   **Verification:** Successful deployment, system stability, key features verified with live data.

## 4. Definition of Done (DoD)

*   `InventoryMovementType` enum is reviewed and updated to cover all scenarios.
*   `reasonNotes` and `referenceDocuments` are conditionally mandatory based on `InventoryMovementType`, and validation is enforced.
*   `initiatingEmployeeId` is captured for all inventory movements.
*   An audit trail/movement history feature is available with adequate filtering capabilities.
*   All related unit, integration, and E2E tests are passing.
*   UAT is completed and signed off by relevant stakeholders.
*   Documentation is updated, and teams are trained.
*   Changes are successfully deployed and monitored.

## 5. Roles & Responsibilities (Example - To be filled by Project Lead)

*   **Project Lead/Manager:** (Name)
*   **Lead Developer (Inventory):** (Name)
*   **Inventory Module Team:** (Names)
*   **QA Lead/Team:** (Name/s)
*   **Stakeholders (Finance/Audit, Operations):** (Name/s)

## 6. Communication Plan

*   Standard project communication channels (daily stand-ups, weekly syncs, shared documentation, issue tracker).

