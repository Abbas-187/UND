# Order Management Module Plan

## 1. Data Model & Domain

- **Order**
  - id, customer, items, location, status, createdBy, createdAt, updatedAt
  - justification (for edits/cancellations)
  - cancellationReason, cancellationBy, cancellationAt
  - productionStatus, procurementStatus, recipeId
- **OrderDiscussion**
  - id, orderId, participants, messages, createdAt, closedAt, status
- **OrderAuditTrail**
  - id, orderId, action, userId, timestamp, justification
- **User/Role**
  - id, name, role (SalesSupervisor, BranchManager, etc.), location

---

## 2. Workflow & Lifecycle

1. **Order Creation**
   - Sales Supervisor creates order.
   - System checks inventory for recipe ingredients/packaging.
   - If sufficient: reserve materials, status → ReadyForProduction.
   - If not: status → AwaitingProcurement, notify procurement.

2. **Procurement Review**
   - Procurement reviews and decides:
     - If can fulfill: status → ReadyForProduction, notify production.
     - If not: status → Rejected, notify creator, open discussion.

3. **Production**
   - Once in production: status → InProduction.
   - Discussion room is locked/hidden.

4. **Order Editing/Cancellation**
   - Allowed only before production.
   - Requires justification.
   - Branch Manager can edit/cancel subordinates’ orders.
   - All actions logged (audit trail).

5. **Order Visibility**
   - Sales Supervisor: only own orders.
   - Branch Manager: all orders in their location.
   - Higher roles: all orders, all locations.

---

## 3. Permissions & Access Control

- Role-based access in backend and frontend.
- UI elements/actions shown/hidden based on permissions.

---

## 4. Discussion Room

- Each order has a discussion room (chat/messages).
- Open until production starts or order is rejected.
- Only relevant users can participate.
- Locked/hidden once production starts.

---

## 5. UI/UX

- **Order List Screen:** Filtered by user role/location, status indicators.
- **Order Detail Screen:** Info, status, actions (edit/cancel with justification), discussion tab.
- **Order Creation/Edit Screen:** Form for order details, validation, submission.
- **Discussion Room Screen:** Chat interface, participants, message history.
- **Notifications:** For order status changes, procurement decisions, discussion updates.

---

## 6. Backend/API

- Endpoints for creating, editing, cancelling orders (with justification).
- Fetching orders (with filters for role/location).
- Managing discussions.
- Inventory check and allocation.
- Procurement review and decision.
- Soft delete: orders are never removed, only status updated.

---

## 7. Audit Trail

- Log all edits, cancellations, and justifications.
- Track who performed each action and when.

---

## 8. Integration Points

- **Inventory:** Use inventory APIs for material reservation and consumption.
- **Production:** On ReadyForProduction, trigger production execution.
- **Procurement:** If inventory is insufficient, trigger procurement workflow.
- **Notifications:** Integrate with notification system for all key events.

---

## 9. Extensibility

- Models and APIs support more locations/roles.
- Use enums/configs for roles and statuses.

---

## 10. Folder Structure Suggestion

- `lib/features/order_management/`
  - models/
  - providers/
  - screens/
  - services/
  - widgets/

---

## 11. Implementation Steps

1. Define data models.
2. Set up providers/services for order and discussion management.
3. Implement role-based UI and permission checks.
4. Build order creation, editing, cancellation, and discussion features.
5. Integrate inventory and procurement logic.
6. Add audit trail and notification system.
7. Write unit, widget, and integration tests.

---

*Last updated: April 22, 2025*
