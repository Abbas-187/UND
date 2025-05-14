# Testing Your App

This guide explains how to test your application using the real Firebase backend.

## Setup

1. Ensure you have configured your Firebase project credentials in `firebase.json`.
2. Enable Firebase services (Auth, Firestore, Storage) in your Firebase console.
3. Run code generation if using Riverpod: `flutter pub run build_runner build --delete-conflicting-outputs`.

## Running Tests

- Run all tests: `flutter test`
- Run specific tests: `flutter test test/features/auth/auth_test.dart`

## Tips

- Use real Firestore emulator for faster, isolated tests: `firebase emulators:start --only firestore`
- Use integration tests for end-to-end flows.