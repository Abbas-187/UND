# Purchase Order Numbering System Plan
**For Multi-Location Dairy Company Operations**

## 1. PO Number Format Specification

### Format Structure
```
LOC-DEPT-YYMM-NNNN
```

### Components
- **LOC**: Location code (3 letters)
- **DEPT**: Department code (3 letters)
- **YYMM**: Year and month (2-digit year, 2-digit month)
- **NNNN**: Sequential number (4 digits with leading zeros)

### Example
`NYC-ING-2506-0042` represents:
- NYC: New York City location
- ING: Ingredients department
- 2506: June 2025 
- 0042: 42nd purchase order of the month for this department at this location

## 2. Location Codes

| Code | Location Name | Address |
|------|--------------|---------|
| NYC | New York City | 123 Dairy Way, New York, NY |
| CHI | Chicago | 456 Milk Avenue, Chicago, IL |
| DAL | Dallas | 789 Cream Boulevard, Dallas, TX |
| LAX | Los Angeles | 321 Yogurt Drive, Los Angeles, CA |
| MIA | Miami | 654 Cheese Lane, Miami, FL |

## 3. Department Codes

| Code | Department Name | Description |
|------|----------------|-------------|
| ING | Ingredients | Raw materials for dairy production |
| MNT | Maintenance | Equipment parts and maintenance supplies |
| PRD | Production | Production line materials and consumables |
| PKG | Packaging | Packaging materials and supplies |
| LOG | Logistics | Transportation and warehouse supplies |
| QAL | Quality | Quality control and lab supplies |
| ADM | Administration | Office supplies and equipment |
| MKT | Marketing | Marketing materials and promotional items |
| RND | Research & Development | R&D equipment and supplies |

## 4. Counter System

### Key Principles
- Counters reset monthly
- Each location-department-month combination has its own counter
- Counters start at 0001 for each new month
- Leading zeros are maintained for all numbers (e.g., 0001, 0012, 0123)

### Example Counter IDs
- `NYC_ING_2506`: Counter for NYC Ingredients in June 2025
- `CHI_MNT_2506`: Counter for Chicago Maintenance in June 2025

## 5. Example PO Numbers

| PO Number | Description |
|-----------|-------------|
| NYC-ING-2506-0042 | New York City, Ingredients (e.g., Chocolate Powder), June 2025, 42nd PO |
| CHI-MNT-2506-0157 | Chicago, Maintenance (e.g., Pasteurizer Parts), June 2025, 157th PO |
| DAL-ADM-2506-0093 | Dallas, Administration (e.g., Office Chairs), June 2025, 93rd PO |
| LAX-PKG-2506-0021 | Los Angeles, Packaging (e.g., Milk Cartons), June 2025, 21st PO |
| MIA-RND-2506-0007 | Miami, Research & Development (e.g., Lab Equipment), June 2025, 7th PO |

## 6. Implementation Guidelines

### Governance
- Corporate Procurement: Maintains master reference data (locations, departments)
- Finance: Approves changes to PO numbering system
- IT: Implements and maintains the technical solution

### System Rules
1. **Uniqueness**: All PO numbers must be unique across the organization
2. **Completeness**: All components are mandatory
3. **Validation**: System must validate location and department codes against master data
4. **Automation**: PO numbers are system-generated, not manually created
5. **Audit**: All PO number creation is logged for audit purposes

### Access Control
- Users can only create POs for their authorized locations and departments
- Regional managers may have cross-location access
- Corporate roles may have access to all locations

## 7. Technical Implementation

### Database Schema
- Locations collection: Stores all location data
- Departments collection: Stores all department data
- Counters collection: Manages sequential numbering
- Purchase Orders collection: Stores all PO data with the generated PO numbers

### Counter Management
- Implemented as atomic operations in the database
- Uses transactions to prevent duplicate numbers
- Automatically creates new counters for new month periods

### Integration Requirements
- Interface with ERP systems (e.g., SAP)
- API endpoints for third-party system access
- Real-time validation of master data

## 8. Training & Change Management

### User Training
- Location-specific training sessions
- Department-specific training modules
- Quick reference guides for all users

### Rollout Plan
1. Pilot in one location with all departments
2. Review and adjust based on feedback
3. Phased rollout to remaining locations
4. Post-implementation review

## 9. Maintenance

### System Updates
- Annual review of numbering system effectiveness
- Change management process for adding/modifying locations or departments

### Data Management
- Archive policy for historical PO data
- Backup procedures for counter database

## 10. Reporting

### Standard Reports
- PO Issuance by Location/Department
- Cross-location spending analysis
- Monthly procurement volumes

### Analytics
- Spending patterns by location and department
- Seasonal procurement analysis
- Budget vs. actual by PO category 