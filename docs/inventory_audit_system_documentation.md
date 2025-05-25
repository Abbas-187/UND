# Inventory Audit System Documentation

**Document Version:** 1.0
**Last Updated:** May 17, 2025
**Status:** Complete

## 1. Overview

The Inventory Audit System provides comprehensive tracking and reporting of all actions performed within the inventory module. It serves as a complete audit trail for compliance, security monitoring, and operational troubleshooting. This document details the technical implementation, usage guidelines, and integration patterns.

## 2. Architecture

### 2.1 Core Components

1. **AuditMiddleware**: Central utility for logging audit events across the application.
2. **InventoryAuditLogModel**: Standardized schema for audit log entries.
3. **InventoryAuditLogRepository**: Data layer for storing and retrieving audit logs.
4. **Audit Use Cases**: Business logic for audit log operations.
5. **InventoryAuditLogScreen**: User interface for viewing and searching audit logs.

### 2.2 Data Flow

1. **Action Occurs**: An inventory action is performed (create, update, delete, etc.)
2. **Middleware Intercepts**: AuditMiddleware captures the event details
3. **Log Created**: A structured audit log entry is created
4. **Storage**: The log is stored in Firestore's `inventory_audit_logs` collection
5. **Retrieval**: Logs can be queried through the repository and viewed in the UI

## 3. Audit Log Schema

Each audit log contains the following information:

| Field | Type | Description |
|-------|------|-------------|
| id | String | Unique identifier for the audit log entry |
| userId | String | ID of the user who performed the action |
| userEmail | String? | Email of the user (if available) |
| userName | String? | Display name of the user (if available) |
| actionType | AuditActionType | Type of action performed (create, update, delete, etc.) |
| entityType | AuditEntityType | Type of entity being audited (inventoryItem, inventoryMovement, etc.) |
| entityId | String | ID of the entity being audited |
| timestamp | DateTime | When the action was performed |
| module | String | The module where the action was performed |
| description | String? | Human-readable description of the action |
| beforeState | Map<String, dynamic>? | Entity state before the action |
| afterState | Map<String, dynamic>? | Entity state after the action |
| ipAddress | String? | IP address of the user |
| deviceInfo | String? | Information about the device used |
| metadata | Map<String, dynamic>? | Additional contextual information |

### 3.1 AuditActionType Enum

Defines the type of action being performed:
- `create`: Creating a new entity
- `update`: Modifying an existing entity
- `delete`: Removing an entity
- `view`: Viewing an entity
- `export`: Exporting data
- `statusChange`: Changing an entity's status
- `qualityChange`: Changing quality-related attributes
- `locationChange`: Moving inventory between locations
- `quantityAdjustment`: Adjusting inventory quantities
- `batchAttributeChange`: Changing batch/lot attributes
- `costUpdate`: Updating cost information
- `other`: Miscellaneous actions

### 3.2 AuditEntityType Enum

Specifies the type of entity being audited:
- `inventoryItem`: Individual inventory items
- `inventoryMovement`: Movement of inventory
- `inventoryLocation`: Storage locations
- `costLayer`: Cost layer records
- `batchInfo`: Batch/lot information
- `qualityReport`: Quality testing reports
- `other`: Other entity types

## 4. Usage Guidelines

### 4.1 When to Audit

The following events MUST be audited:

1. **All inventory quantity changes**, regardless of source
2. **Status changes** (quality status, availability status)
3. **Cost updates** and financial revaluations
4. **Location changes** and transfers
5. **Batch/lot attribute changes** (expiry date, production date)
6. **Manual data exports** and report generation
7. **Configuration changes** (reorder points, safety stock levels)

### 4.2 Audit Detail Levels

Three levels of audit detail are supported:

1. **Basic**: Only capture the action, entity, user, and timestamp
2. **Standard**: Basic + description and metadata
3. **Comprehensive**: Standard + before/after states, device info, IP address

Use the appropriate level based on the sensitivity and importance of the action.

## 5. Integration Guide

### 5.1 Adding Audit Logging to New Features

To add audit logging to a new feature:

1. **Import the middleware**:
   ```dart
   import 'package:und/utils/audit_middleware.dart';
   ```

2. **Inject the middleware** into your repository or service:
   ```dart
   final AuditMiddleware _auditMiddleware;
   ```

3. **Log actions** at appropriate points:
   ```dart
   await _auditMiddleware.logAction(
     action: 'create',
     module: 'inventory',
     entityType: AuditEntityType.inventoryItem,
     entityId: newItem.id,
     description: 'Created new inventory item: ${newItem.name}',
     afterState: newItem.toJson(),
   );
   ```

### 5.2 Best Practices

1. **Log at the repository level** for consistency
2. **Include before/after state** for significant changes
3. **Use descriptive action types** from the AuditActionType enum
4. **Add meaningful descriptions** for complex operations
5. **Include related document IDs** in metadata 

## 6. Security and Access Control

1. **Audit logs are read-only**: Once created, audit logs cannot be modified or deleted.
2. **Access restrictions**: Only users with appropriate permissions can view audit logs.
3. **Data retention**: Audit logs are kept for a minimum of [7] years as per compliance requirements.
4. **Audit of audit**: Viewing audit logs is itself an audited action.

## 7. Reporting Capabilities

The audit system supports the following reporting capabilities:

1. **Filtering**: By user, date range, action type, entity type, and more
2. **CSV Export**: Export filtered logs to CSV format
3. **Detail View**: Examine specific events in detail, including before/after state
4. **Timeline View**: See a chronological sequence of events related to an entity

## 8. Troubleshooting

### 8.1 Common Issues

| Issue | Potential Cause | Solution |
|-------|----------------|----------|
| Missing audit logs | Action not wrapped in audit middleware | Add middleware call at repository level |
| Incomplete audit data | Optional fields not provided | Review integration and add missing fields |
| Poor audit log performance | Too many logs or inefficient queries | Implement date-based filtering and pagination |

### 8.2 Support Contacts

- **Technical Lead**: [Name] - [Email]
- **Compliance Officer**: [Name] - [Email]

## 9. Future Enhancements

1. **Advanced visualization**: Graphical representation of audit data
2. **AI-powered anomaly detection**: Identifying unusual patterns in audit logs
3. **Real-time alerting**: Notify stakeholders of critical audit events
4. **Integration with external audit tools**: Export to standard audit formats
