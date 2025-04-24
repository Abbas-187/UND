# Petty Cash Module Plan

## 1. Data Models

### PettyCashTransfer
- **Fields:** id, amount, date, fromAccount, toAccount, proofUrl, status (pending/approved/rejected), createdBy, approvedBy, createdAt, updatedAt
- **Relationships:** Linked to users (requester, approver)

### PettyCashPurchase
- **Fields:** id, amount, date, items, invoiceUrl, status, createdBy, approvedBy, createdAt, updatedAt
- **Relationships:** Linked to users, transfer, and balance

### PettyCashBalance
- **Fields:** id, currentBalance, currency, lastUpdated, location/department

### AuditLog
- **Fields:** id, action, userId, timestamp, details
- **Retention:** Define retention policy (e.g., 1 year)

---

## 2. Services / Repositories
- Methods for creating, approving, and listing transfers and purchases
- Methods for uploading proofs/invoices and updating balances
- Error handling and validation (amount, duplicates, file type/size)
- API endpoints with authentication and rate limiting

---

## 3. UI / UX
- **Transfer Screen:** Request/record a petty cash transfer (with proof upload, validation)
- **Purchase Screen:** Record a purchase (amount, items, invoice upload, validation)
- **Balance Display:** Show current petty cash balance (with multi-currency support if needed)
- **Transaction History Screen:**
  - TabBar with tabs for: All Transactions, Transfers, Purchases, Reconciliations
  - Each tab shows a filtered, searchable, and exportable (CSV/PDF) list
- **Approval Screens:** For managers to approve/reject with comments
- **Notifications:** In-app, email, and push notifications for approvals, rejections, low balance; customizable settings
- **Accessibility:** Responsive and accessible design

---

## 4. Business Logic & Controls
- Require proof for transfers and invoice for purchases
- Update balance after each approved transfer/purchase
- Prevent purchases that exceed available balance
- Notify users/admins on approvals, rejections, or low balance
- Maintain audit trail for all actions
- Support multi-currency and localization
- Offline support and data sync (if mobile)

---

## 5. Permissions
- Only authorized users can request/record transfers and purchases
- Only managers/admins can approve/reject
- Role-based access control

---

## 6. Reporting & Reconciliation
- Generate reports of all petty cash activity (search, filter, export)
- Allow periodic reconciliation (user/admin confirms physical cash matches app balance)
- User activity dashboard for admins

---

## 7. Testing
- Unit tests for all business logic
- Widget/integration/end-to-end/regression tests for workflows
- Data backup, recovery, and migration testing

---

## 8. Additional Considerations
- Define audit log structure and retention
- Specify API security and error handling
- Plan for data backup, recovery, and migration
- Document all endpoints and workflows