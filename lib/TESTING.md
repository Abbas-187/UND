# Testing Your App Without Firebase

This guide explains how to test your application without requiring a real Firebase backend.

## Setting Up Mock Firebase

The application has been configured to work with a mock implementation of Firebase services. To enable it:

1. Open `lib/core/firebase/firebase_module.dart` and ensure `useMockFirebase` is set to `true`:

   ```dart
   /// Toggle this flag to switch between real and mock Firebase
   const bool useMockFirebase = true;
   ```

2. Run the app as normal - it will use the mock implementation instead of real Firebase.

## Visual Indicator

When using the mock implementation, the app will display an orange "MOCK" banner in the corner to indicate you're using mock Firebase services.

## Features Available in Mock Mode

In mock mode, you can:

- Create and sign in users with any email/password (stored in memory)
- Add, update, and query documents (stored in memory)
- Upload and download files (simulated)
- Test the entire application flow without internet connectivity

## Limitations of Mock Mode

Be aware of these limitations:

- Data is not persisted between app restarts
- Complex queries might not behave exactly like real Firebase
- Real-time updates are simulated and might not perfectly match Firebase behavior

## Testing Different Scenarios

### Testing Authentication

The mock implementation allows you to register and sign in with any email/password:

```dart
// Example sign-up
await authRepository.register('test@example.com', 'password123', 'Test User');

// Example sign-in
await authRepository.login('test@example.com', 'password123');
```

### Testing Data Operations

You can create and query data just like with real Firebase:

```dart
// Add a supplier
final supplier = Supplier(
  name: 'Test Supplier',
  address: 'Test Address',
  phone: '123456789',
  email: 'supplier@example.com',
  productCategories: ['Milk'],
);
await supplierRepository.addSupplier(supplier);

// Query suppliers
final suppliers = await supplierRepository.getAllSuppliers();
```

### Testing File Operations

File uploads and downloads are simulated:

```dart
// Upload a file (simulated)
final url = await storageRepository.uploadFile(bytes, 'test.jpg');

// The URL will be a mock URL like: https://mock-storage.example.com/files/test.jpg
```

## Writing Automated Tests

The mock implementation works great with automated tests. See the examples in the `test/` directory.

For example, to test authentication:

```dart
test('should register a new user', () async {
  final container = FirebaseTestHelper.createTestContainer();
  final authRepository = container.read(authRepositoryProvider);
  
  final user = await authRepository.register(
    'test@example.com', 
    'password123', 
    'Test User'
  );
  
  expect(user.email, 'test@example.com');
  expect(user.name, 'Test User');
});
```

## Switching Back to Real Firebase

When you're ready to use real Firebase again:

1. Open `lib/core/firebase/firebase_module.dart` and set `useMockFirebase` to `false`:

   ```dart
   /// Toggle this flag to switch between real and mock Firebase
   const bool useMockFirebase = false;
   ```

2. Run the app - it will connect to the real Firebase backend.

## Troubleshooting

If you encounter issues with the mock implementation:

1. Check if any repositories need updates to handle mock interfaces
2. Look for places in the code where real Firebase APIs are being used directly
3. Run the test cases to verify the mock implementation is working 