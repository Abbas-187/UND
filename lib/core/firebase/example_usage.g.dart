// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_usage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authExampleHash() => r'c689fce4ed8a59d36b7de57534f9efb06f568b15';

/// Example provider that uses Firebase auth interface
///
/// Copied from [AuthExample].
@ProviderFor(AuthExample)
final authExampleProvider =
    AutoDisposeAsyncNotifierProvider<AuthExample, void>.internal(
  AuthExample.new,
  name: r'authExampleProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authExampleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthExample = AutoDisposeAsyncNotifier<void>;
String _$firestoreExampleHash() => r'3aba711ad2629a43cc3ddeee27490ad19db4924a';

/// Example provider that uses Firestore interface
///
/// Copied from [FirestoreExample].
@ProviderFor(FirestoreExample)
final firestoreExampleProvider =
    AutoDisposeAsyncNotifierProvider<FirestoreExample, void>.internal(
  FirestoreExample.new,
  name: r'firestoreExampleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firestoreExampleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FirestoreExample = AutoDisposeAsyncNotifier<void>;
String _$storageExampleHash() => r'fd801b4ee2d63c91a2e54361ab7defd86b6e3aca';

/// Example provider that uses Storage interface
///
/// Copied from [StorageExample].
@ProviderFor(StorageExample)
final storageExampleProvider =
    AutoDisposeAsyncNotifierProvider<StorageExample, void>.internal(
  StorageExample.new,
  name: r'storageExampleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storageExampleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StorageExample = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
