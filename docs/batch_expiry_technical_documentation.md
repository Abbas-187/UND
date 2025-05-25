# Batch/Lot & Expiry Date Management - Technical Documentation

**Version:** 1.0
**Last Updated:** May 17, 2025

## Overview

This document provides technical details on the implementation of batch/lot tracking and expiry date management in the industrial inventory system. This functionality is critical for ensuring proper FEFO (First-Expired, First-Out) management of perishable goods and batch-tracked materials.

## Key Components

### 1. Data Models

#### 1.1 Core Fields

The following models have been enhanced to support batch/lot and expiry tracking:

- **ProductModel**:
  - `isBatchTracked` (boolean) - Indicates if the product requires batch/lot tracking
  - `isPerishable` (boolean) - Indicates if the product has an expiration date

- **InventoryMovementItemModel**:
  - `batchLotNumber` (String?) - Batch or lot number identifier
  - `productionDate` (DateTime?) - Date of production/manufacturing
  - `expirationDate` (DateTime?) - Date of expiration
  - `costAtTransaction` (double?) - Cost captured at transaction time for accurate costing

- **InventoryItem**:
  - `batchNumber` (String?) - Current batch/lot number
  - `expiryDate` (DateTime?) - Current expiration date
  
### 2. Validation Logic

Validation logic has been implemented to ensure:

1. If a product's `isBatchTracked` flag is true, `batchLotNumber` is required for all movements.
2. If a product's `isPerishable` flag is true, `expirationDate` is required for all movements.
3. The helper method `hasRequiredBatchInfo(isPerishable, requiresBatchTracking)` checks these conditions.

### 3. Key Use Cases

#### 3.1 CalculateInventoryAgingUsecase

This use case categorizes inventory items based on their expiration status:

- **expiredItems**: Already expired
- **critical**: 0-7 days until expiry
- **warning**: 8-30 days until expiry
- **upcoming**: 31-90 days until expiry
- **good**: 91+ days until expiry
- **noExpiry**: Items without expiry dates

Key methods:
- `execute()`: Returns inventory categorized by age brackets
- `getItemsExpiringWithin(days)`: Returns items expiring within the specified days
- `calculateExpiryRiskPercentage(daysThreshold)`: Calculates percentage of inventory value at risk of expiry

#### 3.2 GetLowStockAlertsUseCase

Enhanced to provide detailed expiry alerts:

- **EXPIRED**: Items that have already expired
- **CRITICAL_EXPIRY**: Items expiring within 7 days
- **WARNING_EXPIRY**: Items expiring between 8-30 days
- **UPCOMING_EXPIRY**: Items expiring between 31-90 days

Alerts include severity levels (high, medium, low) to help prioritize attention.

### 4. FEFO Implementation

FEFO logic ensures items expiring soonest are picked first:

1. When retrieving available stock for picking, items are sorted by `expirationDate` in ascending order.
2. For items with the same expiry date, secondary sorting by `productionDate` or `receivedDate` (FIFO) is applied.
3. The inventory picking suggestions in order fulfillment prioritize items with the earliest expiry dates.

### 5. Integration Points

#### 5.1 Milk Reception Module

The `milk_reception` module captures and validates batch/expiry information:
- Batch/lot numbers are mandatorily captured for incoming milk
- Expiry dates are calculated based on product shelf life or explicitly entered
- This data is passed to the inventory module when creating movement records

#### 5.2 Order Management Module

The `order_management` module now:
- Queries inventory with FEFO sorting when generating picking suggestions
- Displays batch/lot and expiry information for warehouse staff
- Records the actual batch picked in fulfillment operations

## Usage Guidelines

### Batch/Lot Number Format

- Format: [Product Code]-[YYMMDD]-[Batch Sequence]
- Example: `MILK-230517-001`

### Expiry Date Handling

- For products with variable shelf life, expiry date is explicitly entered
- For products with fixed shelf life, expiry date is auto-calculated from production date

### Reports and Analytics

The following reports use the batch/expiry data:
- **Inventory Aging Report**: Shows value and quantity of inventory by age bracket
- **Expiry Risk Report**: Highlights items approaching expiration
- **Batch Traceability Report**: Track movements of specific batches

## Error Handling

Common validation errors and their resolutions:
- **Missing Batch Number**: Ensure batch number is provided for batch-tracked items
- **Missing Expiry Date**: Ensure expiry date is provided for perishable items
- **Invalid Date Format**: Use YYYY-MM-DD format for dates

## Testing

Unit and integration tests cover:
- Validation of mandatory batch/expiry fields
- FEFO sorting logic
- Expiry-based alerts generation
- E2E tests for the complete lifecycle of batch-tracked and perishable items

---

## Future Enhancements

Planned enhancements for future iterations:
1. Batch-specific quality attributes tracking
2. Automated disposal process for expired items
3. ML-based expiry predictions based on historical data
4. Mobile scanning for batch verification during picking
