# PO Numbering System Implementation Guide
**Technical Implementation with Firebase Backend**

## 1. System Architecture Overview

![System Architecture](https://via.placeholder.com/800x400?text=PO+Numbering+System+Architecture)

### Components
- **Frontend**: Web application for PO management
- **Backend**: Firebase (Firestore, Cloud Functions, Authentication)
- **Integration Layer**: APIs for ERP systems (e.g., SAP) and other applications
- **Reporting**: Analytics and reporting dashboard

## 2. Firebase Backend Setup

### Required Firebase Services
| Service | Purpose |
|---------|---------|
| **Firebase Authentication** | User management and access control |
| **Firestore** | NoSQL database for PO data and counters |
| **Cloud Functions** | Serverless functions for PO number generation |
| **Firebase Hosting** | (Optional) Host web application |
| **Firebase Storage** | (Optional) Store PO attachments |

### Environment Setup
1. Create Firebase project in Firebase Console
2. Enable required services
3. Set up development, staging, and production environments
4. Configure Firebase CLI for local development

## 3. Database Schema Design

### Firestore Collections

#### Locations Collection
```javascript
locations/{locationCode}
{
  name: string,          // "New York City"
  code: string,          // "NYC"
  address: string,       // "123 Dairy Way"
  city: string,          // "New York"
  state: string,         // "NY"
  country: string,       // "USA"
  active: boolean,       // true
  createdAt: timestamp,
  updatedAt: timestamp
}
```

#### Departments Collection
```javascript
departments/{departmentCode}
{
  name: string,          // "Ingredients"
  code: string,          // "ING"
  description: string,   // "Raw materials for dairy production"
  active: boolean,       // true
  availableLocations: [  // Array of location codes where this department exists
    "NYC", "CHI", "DAL"
  ],
  createdAt: timestamp,
  updatedAt: timestamp
}
```

#### Counters Collection
```javascript
counters/{locationCode}_{departmentCode}_{yearMonth}
{
  current: number,       // Current counter value
  locationCode: string,  // "NYC"
  departmentCode: string,// "ING"
  yearMonth: string,     // "2506"
  lastUpdated: timestamp
}
```

#### Purchase Orders Collection
```javascript
purchase_orders/{poId}
{
  poNumber: string,      // "NYC-ING-2506-0042"
  locationCode: string,  // "NYC"
  departmentCode: string,// "ING"
  yearMonth: string,     // "2506"
  sequence: number,      // 42
  createdBy: string,     // User ID
  createdAt: timestamp,
  status: string,        // "draft", "approved", "completed", etc.
  vendor: {
    id: string,
    name: string
  },
  items: [{
    description: string,
    quantity: number,
    unitPrice: number,
    totalPrice: number
  }],
  totalAmount: number,
  currency: string,
  approvals: [{
    approverId: string,
    status: string,
    timestamp: timestamp,
    comments: string
  }]
}
```

#### Users Collection
```javascript
users/{userId}
{
  displayName: string,
  email: string,
  role: string,
  authorizedLocations: [string],  // Location codes user can access
  authorizedDepartments: [string], // Department codes user can access
  defaultLocation: string,
  defaultDepartment: string
}
```

## 4. Cloud Functions Implementation

### PO Number Generator Function

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.generatePONumber = functions.https.onCall(async (data, context) => {
  // Authenticate user
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
  }
  
  const { locationCode, departmentCode } = data;
  
  // Input validation
  if (!locationCode || !departmentCode) {
    throw new functions.https.HttpsError('invalid-argument', 'Location and department codes are required');
  }
  
  // Validate location and department
  const db = admin.firestore();
  const locationRef = db.collection('locations').doc(locationCode);
  const departmentRef = db.collection('departments').doc(departmentCode);
  
  const [locationDoc, departmentDoc] = await Promise.all([
    locationRef.get(),
    departmentRef.get()
  ]);
  
  if (!locationDoc.exists) {
    throw new functions.https.HttpsError('invalid-argument', `Invalid location code: ${locationCode}`);
  }
  
  if (!departmentDoc.exists) {
    throw new functions.https.HttpsError('invalid-argument', `Invalid department code: ${departmentCode}`);
  }
  
  // Check if department is available at this location
  const department = departmentDoc.data();
  if (!department.availableLocations.includes(locationCode)) {
    throw new functions.https.HttpsError('invalid-argument', 
      `Department ${departmentCode} is not available at location ${locationCode}`);
  }
  
  // Get current year and month in YYMM format
  const now = new Date();
  const year = now.getFullYear().toString().substr(-2);
  const month = (now.getMonth() + 1).toString().padStart(2, '0');
  const yearMonth = `${year}${month}`;
  
  // Counter document ID
  const counterId = `${locationCode}_${departmentCode}_${yearMonth}`;
  
  // Get or create counter in a transaction to ensure atomicity
  const result = await db.runTransaction(async (transaction) => {
    const counterRef = db.collection('counters').doc(counterId);
    const counterDoc = await transaction.get(counterRef);
    
    let newCount = 1;
    if (counterDoc.exists) {
      newCount = counterDoc.data().current + 1;
      transaction.update(counterRef, { 
        current: newCount,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
      });
    } else {
      transaction.set(counterRef, { 
        current: newCount,
        locationCode,
        departmentCode,
        yearMonth,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
      });
    }
    
    // Format with leading zeros (4 digits)
    const sequenceNumber = newCount.toString().padStart(4, '0');
    
    // Create the PO number: LOC-DEPT-YYMM-NNNN
    const poNumber = `${locationCode}-${departmentCode}-${yearMonth}-${sequenceNumber}`;
    
    return { 
      poNumber,
      locationCode,
      departmentCode,
      yearMonth,
      sequence: newCount
    };
  });
  
  return result;
});
```

### Automated PO Creation Trigger

```javascript
exports.onPurchaseOrderCreate = functions.firestore
  .document('purchase_orders/{poId}')
  .onCreate(async (snapshot, context) => {
    const poData = snapshot.data();
    
    // If PO number is not already set, generate one
    if (!poData.poNumber) {
      try {
        const result = await generatePONumberInternal(
          poData.locationCode, 
          poData.departmentCode
        );
        
        // Update the PO with the generated number
        return snapshot.ref.update({
          poNumber: result.poNumber,
          yearMonth: result.yearMonth,
          sequence: result.sequence,
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      } catch (error) {
        console.error('Error generating PO number:', error);
        
        // Mark the PO as having an error
        return snapshot.ref.update({
          status: 'error',
          errorMessage: 'Failed to generate PO number',
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      }
    }
    
    return null;
  });

// Internal function for generating PO numbers
async function generatePONumberInternal(locationCode, departmentCode) {
  const db = admin.firestore();
  
  // Get current year and month in YYMM format
  const now = new Date();
  const year = now.getFullYear().toString().substr(-2);
  const month = (now.getMonth() + 1).toString().padStart(2, '0');
  const yearMonth = `${year}${month}`;
  
  // Counter document ID
  const counterId = `${locationCode}_${departmentCode}_${yearMonth}`;
  
  // Get or create counter in a transaction
  return db.runTransaction(async (transaction) => {
    const counterRef = db.collection('counters').doc(counterId);
    const counterDoc = await transaction.get(counterRef);
    
    let newCount = 1;
    if (counterDoc.exists) {
      newCount = counterDoc.data().current + 1;
      transaction.update(counterRef, { 
        current: newCount,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
      });
    } else {
      transaction.set(counterRef, { 
        current: newCount,
        locationCode,
        departmentCode,
        yearMonth,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
      });
    }
    
    // Format with leading zeros (4 digits)
    const sequenceNumber = newCount.toString().padStart(4, '0');
    
    // Create the PO number: LOC-DEPT-YYMM-NNNN
    const poNumber = `${locationCode}-${departmentCode}-${yearMonth}-${sequenceNumber}`;
    
    return { 
      poNumber,
      locationCode,
      departmentCode,
      yearMonth,
      sequence: newCount
    };
  });
}
```

## 5. Security Rules

```
// Firestore security rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isAdmin() {
      return isAuthenticated() && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }
    
    function canAccessLocation(locationCode) {
      let userData = getUserData();
      return userData.authorizedLocations.hasAny([locationCode]);
    }
    
    function canAccessDepartment(departmentCode) {
      let userData = getUserData();
      return userData.authorizedDepartments.hasAny([departmentCode]);
    }
    
    // Default deny all
    match /{document=**} {
      allow read, write: if false;
    }
    
    // Locations access rules
    match /locations/{locationId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }
    
    // Departments access rules
    match /departments/{departmentId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }
    
    // Counters access rules (only system functions should modify)
    match /counters/{counterId} {
      allow read: if isAuthenticated();
      allow write: if false; // Only modified via Cloud Functions
    }
    
    // PO access rules
    match /purchase_orders/{poId} {
      allow read: if isAuthenticated() && 
                  canAccessLocation(resource.data.locationCode);
      
      allow create: if isAuthenticated() && 
                    canAccessLocation(request.resource.data.locationCode) &&
                    canAccessDepartment(request.resource.data.departmentCode);
      
      allow update: if isAuthenticated() && 
                    canAccessLocation(resource.data.locationCode) &&
                    (canAccessDepartment(resource.data.departmentCode) ||
                     request.auth.uid in resource.data.approvals.approverIds);
      
      allow delete: if isAdmin();
    }
    
    // Users access rules
    match /users/{userId} {
      allow read: if isAuthenticated() && (request.auth.uid == userId || isAdmin());
      allow write: if isAdmin();
    }
  }
}
```

## 6. API Endpoints

### REST API for External Systems

Set up the following API endpoints using Firebase Cloud Functions:

1. **Generate PO Number**
   - `POST /api/po/generate`
   - Generates a new PO number for given location and department

2. **Create Purchase Order**
   - `POST /api/po`
   - Creates a new purchase order

3. **Get Purchase Order by PO Number**
   - `GET /api/po/{poNumber}`
   - Retrieves a purchase order by its PO number

4. **Search Purchase Orders**
   - `GET /api/po/search`
   - Searches purchase orders with various filters

5. **Update Purchase Order**
   - `PUT /api/po/{poId}`
   - Updates an existing purchase order

Example API Implementation:
```javascript
const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');

const app = express();
app.use(cors({ origin: true }));

// Get PO by PO Number
app.get('/api/po/byNumber/:poNumber', async (req, res) => {
  try {
    const poNumber = req.params.poNumber;
    
    const poSnapshot = await admin.firestore()
      .collection('purchase_orders')
      .where('poNumber', '==', poNumber)
      .limit(1)
      .get();
    
    if (poSnapshot.empty) {
      return res.status(404).json({ error: 'Purchase order not found' });
    }
    
    const poDoc = poSnapshot.docs[0];
    return res.status(200).json({
      id: poDoc.id,
      ...poDoc.data()
    });
  } catch (error) {
    console.error('Error:', error);
    return res.status(500).json({ error: error.message });
  }
});

// Export the API as a Cloud Function
exports.api = functions.https.onRequest(app);
```

## 7. Integration with SAP

### SAP Integration Options

1. **API-Based Integration**
   - Use SAP's OData services to exchange data with Firebase
   - Implement webhooks to notify SAP of new POs

2. **File-Based Integration**
   - Export PO data to CSV/XML files for import into SAP
   - Schedule regular data synchronization

### Sample SAP Integration Flow

1. PO created in Firebase system
2. Cloud Function triggered on PO creation
3. Format PO data for SAP
4. Send PO data to SAP API
5. Store SAP reference ID in Firebase

```javascript
exports.sendToSAP = functions.firestore
  .document('purchase_orders/{poId}')
  .onUpdate(async (change, context) => {
    const poData = change.after.data();
    const previousData = change.before.data();
    
    // Only proceed if status changed to "approved"
    if (poData.status === 'approved' && previousData.status !== 'approved') {
      try {
        // Format data for SAP
        const sapPayload = {
          PoNumber: poData.poNumber,
          Location: poData.locationCode,
          Department: poData.departmentCode,
          Vendor: poData.vendor.name,
          VendorId: poData.vendor.id,
          TotalAmount: poData.totalAmount,
          Currency: poData.currency,
          Items: poData.items.map(item => ({
            Description: item.description,
            Quantity: item.quantity,
            UnitPrice: item.unitPrice,
            TotalPrice: item.totalPrice
          }))
        };
        
        // Call SAP API (example)
        const sapResponse = await axios.post(
          'https://your-sap-api-endpoint/PurchaseOrders',
          sapPayload,
          {
            headers: {
              'Authorization': `Basic ${Buffer.from(
                `${functions.config().sap.username}:${functions.config().sap.password}`
              ).toString('base64')}`,
              'Content-Type': 'application/json'
            }
          }
        );
        
        // Update PO with SAP reference
        return change.after.ref.update({
          sapReferenceId: sapResponse.data.id,
          sapSyncStatus: 'success',
          sapSyncDate: admin.firestore.FieldValue.serverTimestamp()
        });
      } catch (error) {
        console.error('Error sending to SAP:', error);
        
        // Mark sync failure
        return change.after.ref.update({
          sapSyncStatus: 'failed',
          sapSyncError: error.message,
          sapSyncAttempts: admin.firestore.FieldValue.increment(1)
        });
      }
    }
    
    return null;
  });
```

## 8. Deployment Process

### Development Environment
1. Clone repository
2. Install dependencies
3. Configure Firebase CLI
4. Use Firebase emulator suite for local testing

### Staging Deployment
1. Set up staging Firebase project
2. Deploy Firestore rules and indexes
3. Deploy Cloud Functions
4. Run integration tests

### Production Deployment
1. Create deployment plan with rollback strategy
2. Schedule maintenance window if needed
3. Deploy to production Firebase project
4. Verify functionality
5. Monitor for any issues

## 9. Testing Strategy

### Unit Tests
- Test PO number generation logic
- Test validation rules
- Test database operations

```javascript
describe('PO Number Generator', () => {
  it('should generate a valid PO number', async () => {
    const result = await generatePONumberInternal('NYC', 'ING');
    expect(result.poNumber).toMatch(/^NYC-ING-\d{4}-\d{4}$/);
  });
  
  it('should increment the counter', async () => {
    const result1 = await generatePONumberInternal('NYC', 'ING');
    const result2 = await generatePONumberInternal('NYC', 'ING');
    expect(result2.sequence).toBe(result1.sequence + 1);
  });
});
```

### Integration Tests
- Test API endpoints
- Test SAP integration
- Test security rules

### Load Tests
- Simulate concurrent PO creation
- Verify counter integrity under load
- Test system performance with large data volumes

## 10. Documentation

### Developer Documentation
- API reference
- Database schema
- Code examples

### Administrator Documentation
- System configuration
- User management
- Troubleshooting

### User Documentation
- User guides
- Training materials
- FAQ

## 11. Monitoring and Analytics

### Key Metrics to Monitor
- PO creation rate by location/department
- API response times
- Error rates
- Firebase usage and costs

### Logging Strategy
- Structured logging for all operations
- Error tracking with context
- Audit logs for security events

## 12. Backup and Recovery

### Backup Procedures
- Scheduled Firestore exports
- Configuration backups
- Code repository backups

### Recovery Procedures
- Restore from backup
- Counter reconciliation process
- Data integrity verification 