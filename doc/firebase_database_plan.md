# Firestore Database Plan

This document outlines the proposed Firestore database structure for the application based on the identified entities and relationships.

## Core Principles

1.  **Collections for Top-Level Entities:** Each major distinct entity gets its own top-level collection.
2.  **Documents Represent Instances:** Each document within a collection represents a specific instance of that entity.
3.  **Use Meaningful Document IDs:** Where possible, use natural unique identifiers as document IDs. Otherwise, let Firestore auto-generate IDs.
4.  **Denormalization for Read Efficiency:** Include some data from related entities directly within a document if it's frequently needed for display (e.g., storing `supplierName` on a `purchaseOrder`). Requires careful updates (often via Cloud Functions).
5.  **Subcollections for Complex Nested Data:** Use subcollections for lists of related items that might need independent querying (like purchase order items).
6.  **Timestamps:** Use Firestore `Timestamp` for date/time fields.
7.  **References:** Consider using Firestore `DocumentReference` type for linking documents, although storing just the ID as a String is also common.
8.  **Consistent Tracking Fields:** All collections should include `createdAt` and `updatedAt` timestamp fields for audit and tracking purposes.

## Proposed Firestore Structure

```text
/suppliers/{supplierId}
  - name: String
  - contactPerson: String
  - email: String
  - phone: String
  - address: Map
    - street: String
    - city: String
    - state: String
    - zipCode: String
    - country: String
  - productCategories: Array<String>
  - isActive: Boolean
  - rating: Number (double)
  - notes: String
  - taxId: String
  - paymentTerms: String
  - website: String
  - lastOrderDate: Timestamp
  - lastUpdated: Timestamp
  - searchTerms: Array<String>  // For efficient searching (lowercase keywords)
  - metrics: Map
    - onTimeDeliveryRate: Number
    - qualityScore: Number
    - responseTime: Number // (Consider units, e.g., hours)
  - additionalAttributes: Map<String, dynamic> (optional)

/purchaseOrders/{purchaseOrderId}  // ID could be auto-generated or the PO number
  - poNumber: String             // Store PO number explicitly if using auto-ID
  - supplierId: String           // ID of the supplier document in /suppliers
  - supplierName: String         // Denormalized for display
  - requestDate: Timestamp
  - expectedDeliveryDate: Timestamp
  - status: String               // e.g., "pending_approval", "approved", "ordered", "shipped", "partially_received", "received", "cancelled"
  - totalAmount: Number
  - shippingAddress: Map         // Similar structure to supplier address
  - billingAddress: Map          // Similar structure to supplier address
  - paymentTerms: String         // Can be copied from supplier or specific to PO
  - notes: String
  - createdBy: String            // User ID or name
  - createdAt: Timestamp
  - updatedAt: Timestamp
  - approvedBy: String (optional)
  - approvedAt: Timestamp (optional)
  // Subcollection for items:
  /purchaseOrders/{purchaseOrderId}/items/{poItemId} // Auto-generated ID for line item
    - materialId: String         // ID of the material/product in /materials
    - materialName: String       // Denormalized
    - description: String        // Optional, more details
    - quantity: Number
    - unit: String               // e.g., "kg", "liters", "units"
    - unitPrice: Number
    - totalPrice: Number         // quantity * unitPrice
    - itemStatus: String         // Optional: e.g., "pending", "received"
    - expectedItemDeliveryDate: Timestamp // Optional: if different from main PO date

/materials/{materialId}          // Represents products/raw materials you procure/manage
  - materialCode: String         // Your internal code
  - name: String
  - description: String
  - unitOfMeasure: String        // Default UOM
  - category: String             // e.g., "Dairy", "Packaging", "Cleaning"
  - supplierIds: Array<String>   // List of supplier IDs who provide this
  - qualityRequirements: Map     // e.g., { "fatContent": { "min": 3.5, "max": 4.5 }, "protein": { "min": 3.0 } }
  - storageConditions: String
  - isActive: Boolean
  - lastUpdated: Timestamp
  - searchTerms: Array<String>   // For efficient searching (lowercase keywords)

/inventory/{inventoryItemId}     // Represents specific batches/lots in stock
  - materialId: String           // ID from /materials
  - materialName: String         // Denormalized
  - batchNumber: String          // Unique identifier for this batch
  - quantity: Number             // Current quantity in stock
  - unitOfMeasure: String
  - location: String             // e.g., "Warehouse A", "Silo 3", "Fridge 1"
  - receivedDate: Timestamp
  - expiryDate: Timestamp (optional)
  - supplierId: String (optional) // ID from /suppliers
  - purchaseOrderId: String (optional) // ID from /purchaseOrders
  - receptionId: String (optional) // ID from /milkReceptions (if applicable)
  - status: String               // e.g., "available", "quarantined", "allocated", "consumed", "expired"
  - qualityCheckId: String (optional) // Link to a relevant quality check
  - additionalAttributes: Map<String, dynamic> // As seen in reception_inventory_provider
  - lastUpdated: Timestamp

/milkReceptions/{receptionId}    // Specific to milk reception process
  - receptionTimestamp: Timestamp
  - supplierId: String           // ID from /suppliers
  - supplierName: String         // Denormalized
  - vehicleNumber: String
  - driverName: String
  - grossWeight: Number
  - tareWeight: Number
  - netWeight: Number            // Calculated: gross - tare
  - temperature: Number
  - status: String               // e.g., "pending_qc", "accepted", "rejected", "processed"
  - rejectionReason: String (optional)
  - notes: String
  - qualityCheckId: String (optional) // Link to the quality check for this reception
  - inventoryItemId: String (optional) // Link to the inventory item created from this reception
  - createdAt: Timestamp

/qualityChecks/{qualityCheckId}  // Records of internal quality tests
  - checkType: String            // e.g., "incoming_milk", "supplier_audit", "inventory_spot"
  - referenceId: String          // ID of the related item (e.g., receptionId, inventoryItemId, purchaseOrderId)
  - referenceType: String        // "milkReception", "inventory", "purchaseOrder", "supplierQualityLog"
  - materialId: String (optional) // ID from /materials
  - materialName: String (optional) // Denormalized
  - supplierId: String (optional) // ID from /suppliers
  - testDate: Timestamp
  - testerName: String
  - status: String               // e.g., "pass", "fail", "conditional_pass", "pending"
  - parameters: Map              // Detailed results, e.g., { "fatContent": 3.8, "protein": 3.2, "bacteria": 50000 }
  - notes: String
  - createdAt: Timestamp

/supplierQualityLogs/{logId}     // Logs specifically from supplier quality reports/inspections
  - supplierId: String           // ID from /suppliers
  - supplierName: String         // Denormalized
  - purchaseOrderId: String (optional) // ID from /purchaseOrders
  - materialId: String           // ID from /materials
  - materialName: String         // Denormalized
  - lotNumber: String (optional)
  - inspectionDate: Timestamp    // Date provided by supplier or your inspection of their delivery
  - inspectorName: String (optional)
  - status: String               // "passed", "failed", "conditional" (as per SupplierQualityLog entity)
  - parameters: Array<Map>       // [{ name: "fat", criteria: ">3.5%", value: "3.7%", isPassed: true, notes: "" }, ...]
  - defectDescription: String (optional)
  - actionTaken: String (optional)
  - notes: String
  - createdAt: Timestamp

// Optional collections based on ProcurementQualityIntegration:
/qualityAlerts/{alertId}
  - materialId: String
  - issueDescription: String
  - severity: String             // "low", "medium", "high", "critical"
  - purchaseOrderId: String (optional)
  - lotNumber: String (optional)
  - timestamp: Timestamp
  - status: String               // "new", "investigating", "resolved", "closed"
  - affectedDepartments: Array<String>
  - resolutionDetails: String (optional)
  - resolvedBy: String (optional)
  - resolvedAt: Timestamp (optional)
  - createdAt: Timestamp

/samplingPlans/{planId}
  - purchaseOrderId: String
  - generatedAt: Timestamp
  // Subcollection for item-specific plans:
  /samplingPlans/{planId}/items/{samplingItemId}
    - materialId: String
    - materialName: String       // Denormalized
    - quantityReceived: Number
    - uom: String
    - sampleSize: Number
    - sampleUnit: String
    - samplingMethod: String
    - requiredTests: Array<String>
    - handlingInstructions: String
    - inspectionStatus: String   // "pending", "in_progress", "completed"
    - qualityCheckId: String (optional) // Link to the resulting quality check

## Security Rules Planning

When implementing this database structure, consider the following security rule principles:

1. **Role-Based Access Control:** Define clear roles (admin, manager, operator, quality-checker) with specific read/write permissions for each collection.

2. **Data Validation:** Enforce schema validation in security rules to ensure data integrity (e.g., required fields, field types, value ranges).

3. **Cross-Document Security:** Validate references between documents (e.g., ensuring a quality check can only be created for a valid reception).

4. **Time-Based Rules:** Consider time-based restrictions (e.g., purchase orders can only be edited within X days of creation).

5. **User-Specific Access:** Limit certain operations to document creators or assigned personnel.

## Flutter Implementation Notes

When implementing these data models in Flutter:

1. **Immutable Classes:** Create immutable classes rather than freezed models for all Firestore entities to ensure data integrity.

2. **Serialization/Deserialization:** Include proper `toJson()` and `fromJson()` methods for each model class.

3. **Type Safety:** Use strong typing throughout the application to prevent runtime errors.

4. **Validation:** Implement validation logic within the model classes to ensure data consistency.

5. **Repository Pattern:** Consider using the repository pattern to abstract Firestore operations from the UI layer.
