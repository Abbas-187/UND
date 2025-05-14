const admin = require('firebase-admin');
const serviceAccount = require('./undapp-119cf-firebase-adminsdk-fbsvc-d5df10b000.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Function to create a department
async function createDepartment(departmentId, data) {
  await db.collection('departments').doc(departmentId).set({
    name: data.name,
    description: data.description,
    managerId: data.managerId || null,
    isActive: true,
    location: data.location || null,
    metadata: {
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    }
  });
  console.log(`Department created: ${departmentId}`);
}

// Function to create a user
async function createUser(userId, data) {
  await db.collection('users').doc(userId).set({
    uid: userId,
    email: data.email,
    name: data.name,
    phoneNumber: data.phoneNumber || null,
    profileImageUrl: data.profileImageUrl || null,
    department: data.department || null,
    role: data.role || 'employee',
    jobTitle: data.jobTitle || null,
    dateJoined: data.dateJoined || admin.firestore.FieldValue.serverTimestamp(),
    lastActive: admin.firestore.FieldValue.serverTimestamp(),
    isActive: true,
    permissions: data.permissions || [],
    preferences: {
      theme: 'light',
      language: 'en',
      notifications: true
    },
    metadata: {
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdBy: data.createdBy || null
    }
  });
  console.log(`User created: ${userId}`);

  // If department is specified, add user to department members subcollection
  if (data.department) {
    await db.collection('departments').doc(data.department).collection('members').doc(userId).set({
      uid: userId,
      role: data.departmentRole || data.role || 'member',
      joinedDepartmentDate: admin.firestore.FieldValue.serverTimestamp()
    });
    console.log(`User added to department: ${data.department}`);
  }
}

// Example usage - Create initial departments
async function createInitialData() {
  try {
    // Create departments
    const departments = [
      { id: 'dev001', name: 'Developers', description: 'Software Development Team', location: 'Floor 3' },
      { id: 'fac001', name: 'Factory', description: 'Main Production Facility', location: 'Building A' },
      { id: 'war001', name: 'Warehouse', description: 'Storage and Inventory', location: 'Building B' },
      { id: 'log001', name: 'Logistics', description: 'Transportation and Supply Chain', location: 'Floor 1' },
      { id: 'sal001', name: 'Sales', description: 'Sales and Marketing', location: 'Floor 2' },
      { id: 'it001', name: 'IT', description: 'Information Technology', location: 'Floor 3' },
      { id: 'hr001', name: 'HR', description: 'Human Resources', location: 'Floor 2' },
      { id: 'fin001', name: 'Finance', description: 'Financial Operations', location: 'Floor 4' },
      { id: 'frm001', name: 'Farm', description: 'Agricultural Operations', location: 'North Campus' },
      { id: 'wks001', name: 'Workshop', description: 'Repairs and Maintenance', location: 'Building C' }
    ];

    for (const dept of departments) {
      await createDepartment(dept.id, dept);
    }

    // Create a user with your authenticated user ID
    const yourAuthUserId = 'R6iidJrMN2Z2Eloa69avONsPZC82'; // Your Firebase Auth UID
    await createUser(yourAuthUserId, {
      email: 'admin@example.com', // Update with your actual email if needed
      name: 'Admin User',
      role: 'admin',
      department: 'dev001', // Placing admin in Developers department
      jobTitle: 'Administrator',
      permissions: ['full_access']
    });

    console.log('Firestore initialization completed successfully!');
  } catch (error) {
    console.error('Error initializing Firestore data:', error);
  }
}

// Run the initialization
createInitialData();