# Inventory Costing Implementation Guide

## 1. Overview

This document describes the implementation of inventory costing methods in the UND application. The system implements three costing methods:

1. **FIFO** (First-In, First-Out): The first items added to inventory are the first ones sold or used
2. **LIFO** (Last-In, First-Out): The most recently added items are the first ones sold or used
3. **WAC** (Weighted Average Cost): Average cost of all items currently in inventory

## 2. Role of `InventoryItem.cost` Field

The `cost` field in the `InventoryItem` entity represents the current **weighted average cost** of the item across all available cost layers in a specific warehouse. This ensures that:

- The field provides a quick reference for general reporting without needing to calculate from cost layers
- It serves as a fallback value when detailed cost layer information is not available
- It represents the accounting value that would be used in a weighted average cost accounting method

### How `InventoryItem.cost` is Updated

The `InventoryItem.cost` field is automatically updated by the `CalculateWeightedAverageCostUseCase` whenever:

1. New items are received into inventory
2. Items are issued or consumed from inventory
3. Inventory adjustments are made

The weighted average is calculated using the formula:

```
New WAC = (Previous Quantity × Previous WAC + New Quantity × New Cost) ÷ (Previous Quantity + New Quantity)
```

### Cost Reconciliation Process

When inventory transactions occur:

1. For inbound movements:
   - New cost layers are created with the specific cost at time of transaction
   - The weighted average cost is recalculated and updated in `InventoryItem.cost`

2. For outbound movements:
   - Cost layers are consumed according to the FIFO/LIFO method as configured
   - The weighted average cost remains unchanged during outbound movement, as the average per unit doesn't change

3. For inventory adjustments:
   - Cost layers may be created or reduced
   - The weighted average cost is recalculated based on the new total quantity and value

## 3. Relationship Between Costing Methods

While the system tracks individual cost layers to support FIFO and LIFO costing, the `InventoryItem.cost` field always represents the weighted average cost, regardless of which costing method is used for reporting or outbound transactions. This allows for:

1. Consistent reporting across the system
2. Support for multiple costing methods without changing the underlying data model
3. Proper valuation in financial reports regardless of which method is preferred

## 4. Reporting Implications

When generating inventory valuation reports:

- For FIFO/LIFO valuation reports, the system uses available cost layers to calculate the total value based on the specific costing method
- For weighted average reports, the system uses the `InventoryItem.cost` field multiplied by the quantity
- For comparative reports, the system shows the valuation under each method to support decision making

## 5. Maintenance and Reconciliation

For accounting accuracy and auditing purposes:

1. The system maintains all cost layers regardless of which costing method is used
2. The `InventoryItem.cost` field should be periodically reconciled against the weighted average of all existing cost layers
3. Financial reports should clearly indicate which costing method is being used

## 6. Technical Implementation Notes

In the codebase:

- `CalculateWeightedAverageCostUseCase` is responsible for updating the WAC whenever inventory levels change
- `CalculateOutboundMovementCostUseCase` determines costs for outbound movements using FIFO/LIFO
- `GenerateInventoryValuationReportUseCase` provides reports using any of the costing methods
- `ComparativeInventoryValuationReport` shows the valuation differences between methods

The system ensures that regardless of which costing method is selected for reporting, all necessary data is maintained to support any method at any time.
