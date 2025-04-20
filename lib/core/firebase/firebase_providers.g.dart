// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseAuthHash() => r'd2937e12c126966002abcfbb2954b34626998def';

/// See also [firebaseAuth].
@ProviderFor(firebaseAuth)
final firebaseAuthProvider = AutoDisposeProvider<AuthInterface>.internal(
  firebaseAuth,
  name: r'firebaseAuthProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$firebaseAuthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseAuthRef = AutoDisposeProviderRef<AuthInterface>;
String _$firestoreHash() => r'af5f85a7b7728ee4af8397c9c97ea611519f5e46';

/// See also [firestore].
@ProviderFor(firestore)
final firestoreProvider = AutoDisposeProvider<FirestoreInterface>.internal(
  firestore,
  name: r'firestoreProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$firestoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirestoreRef = AutoDisposeProviderRef<FirestoreInterface>;
String _$storageHash() => r'4ed320f1cc6910af41614dfe5779f35d1701a50e';

/// See also [storage].
@ProviderFor(storage)
final storageProvider = AutoDisposeProvider<StorageInterface>.internal(
  storage,
  name: r'storageProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$storageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StorageRef = AutoDisposeProviderRef<StorageInterface>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
