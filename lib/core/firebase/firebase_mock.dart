import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'firebase_interface.dart';

// Mock models
class MockUser implements firebase_auth.User {

  MockUser({
    required String uid,
    String? email,
    String? displayName,
  })  : _uid = uid,
        _email = email,
        _displayName = displayName;
  final String _uid;
  final String? _email;
  String? _displayName;

  @override
  String get uid => _uid;

  @override
  String? get email => _email;

  @override
  String? get displayName => _displayName;

  @override
  Future<void> updateDisplayName(String? displayName) async {
    _displayName = displayName;
  }

  @override
  Future<firebase_auth.IdTokenResult> getIdTokenResult(
      [bool forceRefresh = false]) async {
    return MockIdTokenResult(
      claims: {
        'role': 'user',
      },
      token: 'mock-token',
      authTime: DateTime.now(),
      expirationTime: DateTime.now().add(const Duration(hours: 1)),
      issuedAtTime: DateTime.now(),
      signInProvider: 'password',
    );
  }

  @override
  firebase_auth.UserMetadata get metadata => MockUserMetadata();

  // Implement the rest of the User interface with mock implementations
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockUserMetadata implements firebase_auth.UserMetadata {
  @override
  DateTime? get creationTime =>
      DateTime.now().subtract(const Duration(days: 30));

  @override
  DateTime? get lastSignInTime => DateTime.now();
}

class MockIdTokenResult implements firebase_auth.IdTokenResult {

  MockIdTokenResult({
    required this.claims,
    required this.token,
    required this.authTime,
    required this.expirationTime,
    required this.issuedAtTime,
    required this.signInProvider,
  });
  @override
  final Map<String, dynamic>? claims;

  @override
  final String token;

  @override
  final DateTime authTime;

  @override
  final DateTime expirationTime;

  @override
  final DateTime issuedAtTime;

  @override
  final String? signInProvider;
}

class MockUserCredential implements firebase_auth.UserCredential {

  MockUserCredential({this.user});
  @override
  final MockUser? user;

  @override
  final firebase_auth.AdditionalUserInfo? additionalUserInfo = null;

  @override
  final firebase_auth.AuthCredential? credential = null;
}

// Mock implementations of Firebase interfaces
class FirebaseAuthMock implements AuthInterface {
  final Map<String, String> _accounts = {};
  MockUser? _currentUser;
  final _authStateController = StreamController<MockUser?>.broadcast();

  @override
  Stream<MockUser?> authStateChanges() => _authStateController.stream;

  @override
  MockUser? get currentUser => _currentUser;

  @override
  Future<firebase_auth.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!_accounts.containsKey(email) || _accounts[email] != password) {
      throw firebase_auth.FirebaseAuthException(
        code: 'wrong-password',
        message:
            'The password is invalid or the user does not have a password.',
      );
    }

    final user = MockUser(
      uid: const Uuid().v4(),
      email: email,
      displayName: 'Mock User',
    );

    _currentUser = user;
    _authStateController.add(user);

    return MockUserCredential(user: user);
  }

  @override
  Future<firebase_auth.UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (_accounts.containsKey(email)) {
      throw firebase_auth.FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'The email address is already in use by another account.',
      );
    }

    _accounts[email] = password;

    final user = MockUser(
      uid: const Uuid().v4(),
      email: email,
      displayName: null,
    );

    _currentUser = user;
    _authStateController.add(user);

    return MockUserCredential(user: user);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<firebase_auth.IdTokenResult> getIdTokenResult(
      firebase_auth.User user, bool forceRefresh) async {
    return MockIdTokenResult(
      claims: {
        'role': 'user',
      },
      token: 'mock-token',
      authTime: DateTime.now(),
      expirationTime: DateTime.now().add(const Duration(hours: 1)),
      issuedAtTime: DateTime.now(),
      signInProvider: 'password',
    );
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    if (!_accounts.containsKey(email)) {
      throw firebase_auth.FirebaseAuthException(
        code: 'user-not-found',
        message: 'There is no user record corresponding to this identifier.',
      );
    }

    // In a real app, this would send an email
    debugPrint('Password reset email sent to $email');
  }
}

class MockDocumentReference implements DocumentReference<Map<String, dynamic>> {

  MockDocumentReference(this._path);
  final String _path;
  Map<String, dynamic> _data = {};

  @override
  String get id => _path.split('/').last;

  @override
  String get path => _path;

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return MockCollectionReference('$_path/$collectionPath');
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get(
      [GetOptions? options]) async {
    return MockDocumentSnapshot(_path, _data)
        as DocumentSnapshot<Map<String, dynamic>>;
  }

  @override
  Future<void> set(dynamic data, [SetOptions? options]) async {
    // This is a simple mock implementation that just replaces the data
    final Map<String, dynamic> castData = (data is! Map<String, dynamic>)
        ? (data as Map).cast<String, dynamic>()
        : data;

    if (options?.merge == true) {
      // If merge is true, we only add fields from castData to _data
      _data = {..._data, ...castData};
    } else {
      // Otherwise, we replace _data with castData
      _data = Map<String, dynamic>.from(castData);
    }
  }

  @override
  Future<void> update(Map<Object, Object?> data) async {
    // In update, we merge the data with existing data
    _data = {
      ..._data,
      ...Map<String, dynamic>.from(data.map(
        (key, value) => MapEntry(key.toString(), value),
      )),
    };
  }

  @override
  Future<void> delete() async {
    _data = {};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockDocumentSnapshot implements DocumentSnapshot {

  MockDocumentSnapshot(this._path, this._data);
  final String _path;
  final Map<String, dynamic> _data;

  @override
  bool exists = true;

  @override
  String get id => _path.split('/').last;

  @override
  Map<String, dynamic> data() => _data;

  @override
  dynamic get(Object field) => _data[field.toString()];

  @override
  DocumentReference get reference => MockDocumentReference(_path);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockCollectionReference
    implements CollectionReference<Map<String, dynamic>> {

  MockCollectionReference(this._path);
  final String _path;
  final Map<String, Map<String, dynamic>> _documents = {};

  @override
  Future<DocumentReference<Map<String, dynamic>>> add(
      Map<String, dynamic> data) async {
    final docId = const Uuid().v4();
    final docRef = MockDocumentReference('$_path/$docId')
        as DocumentReference<Map<String, dynamic>>;
    await docRef.set(data);
    _documents[docId] = data;
    return docRef;
  }

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    final docPath =
        path != null ? '$_path/$path' : '$_path/${const Uuid().v4()}';
    return MockDocumentReference(docPath)
        as DocumentReference<Map<String, dynamic>>;
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    final List<DocumentSnapshot<Map<String, dynamic>>> docs = [];
    _documents.forEach((key, value) {
      docs.add(MockDocumentSnapshot('$_path/$key', value)
          as DocumentSnapshot<Map<String, dynamic>>);
    });
    return MockQuerySnapshot(docs) as QuerySnapshot<Map<String, dynamic>>;
  }

  @override
  String get path => _path;

  @override
  Query<Map<String, dynamic>> where(Object field,
      {Object? isEqualTo,
      Object? isNotEqualTo,
      Object? isLessThan,
      Object? isLessThanOrEqualTo,
      Object? isGreaterThan,
      Object? isGreaterThanOrEqualTo,
      Object? arrayContains,
      Iterable<Object?>? arrayContainsAny,
      Iterable<Object?>? whereIn,
      Iterable<Object?>? whereNotIn,
      bool? isNull}) {
    // Simple implementation that returns self
    return this;
  }

  @override
  Query<Map<String, dynamic>> orderBy(Object field, {bool descending = false}) {
    // Simple implementation that returns self
    return this;
  }

  @override
  Query<Map<String, dynamic>> limit(int limit) {
    // Simple implementation that returns self
    return this;
  }

  @override
  CollectionReference<R> withConverter<R>(
      {required FromFirestore<R> fromFirestore,
      required ToFirestore<R> toFirestore}) {
    throw UnimplementedError('withConverter not implemented in mock');
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> snapshots(
      {bool includeMetadataChanges = false,
      ListenSource source = ListenSource.cache}) {
    return Stream.fromFuture(get());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockQueryDocumentSnapshot implements QueryDocumentSnapshot {

  MockQueryDocumentSnapshot(this._path, this._data);
  final String _path;
  final Map<String, dynamic> _data;

  @override
  bool exists = true;

  @override
  String get id => _path.split('/').last;

  @override
  Map<String, dynamic> data() => _data;

  @override
  dynamic get(Object field) => _data[field.toString()];

  @override
  DocumentReference get reference => MockDocumentReference(_path);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockQuerySnapshot implements QuerySnapshot<Map<String, dynamic>> {

  MockQuerySnapshot(this._docs);
  final List<DocumentSnapshot> _docs;

  @override
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get docs {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> result = [];
    for (var doc in _docs) {
      if (doc is MockDocumentSnapshot) {
        result.add(MockQueryDocumentSnapshot(doc.reference.path, doc.data())
            as QueryDocumentSnapshot<Map<String, dynamic>>);
      }
    }
    return result;
  }

  @override
  int get size => _docs.length;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class FirestoreMock implements FirestoreInterface {
  final Map<String, MockCollectionReference> _collections = {};

  @override
  CollectionReference collection(String path) {
    if (!_collections.containsKey(path)) {
      _collections[path] = MockCollectionReference(path);
    }
    return _collections[path]!;
  }

  @override
  DocumentReference doc(String path) {
    final segments = path.split('/');
    final collectionPath = segments.take(segments.length - 1).join('/');
    final docId = segments.last;
    return collection(collectionPath).doc(docId);
  }

  @override
  Future<void> runTransaction(TransactionHandler<void> updateFunction) async {
    final MockTransaction transaction = MockTransaction();
    await updateFunction(transaction);
  }

  @override
  WriteBatch batch() {
    return MockWriteBatch();
  }
}

class MockTransaction implements Transaction {
  @override
  Future<DocumentSnapshot<T>> get<T extends Object?>(
      DocumentReference<T> documentReference) async {
    final mockRef = documentReference as MockDocumentReference;
    return await mockRef.get() as DocumentSnapshot<T>;
  }

  @override
  Transaction set<T>(DocumentReference<T> documentReference, T data,
      [SetOptions? options]) {
    final mockRef = documentReference as MockDocumentReference;
    mockRef.set(data, options);
    return this;
  }

  @override
  Transaction update(
      DocumentReference<Object?> documentReference, Map<String, dynamic> data) {
    final mockRef = documentReference as MockDocumentReference;
    mockRef.update(data);
    return this;
  }

  @override
  Transaction delete(DocumentReference<Object?> documentReference) {
    final mockRef = documentReference as MockDocumentReference;
    mockRef.delete();
    return this;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockWriteBatch implements WriteBatch {
  final List<Function> _operations = [];

  @override
  void set<T>(DocumentReference<T> document, T data, [SetOptions? options]) {
    _operations.add(() => document.set(data, options));
  }

  @override
  void update(DocumentReference<Object?> document, Map<String, dynamic> data) {
    _operations.add(() => document.update(data));
  }

  @override
  void delete(DocumentReference<Object?> document) {
    _operations.add(() => document.delete());
  }

  @override
  Future<void> commit() async {
    for (final operation in _operations) {
      await operation();
    }
    _operations.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockUploadTask implements UploadTask {

  MockUploadTask(this._snapshot);
  final TaskSnapshot _snapshot;

  @override
  Stream<TaskSnapshot> get snapshotEvents => Stream.value(_snapshot);

  @override
  Future<TaskSnapshot> get future async => _snapshot;

  @override
  TaskState get state => TaskState.success;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockTaskSnapshot implements TaskSnapshot {
  @override
  Reference get ref => MockStorageReference('mock-ref', StorageMock());

  @override
  int get bytesTransferred => 100;

  @override
  int get totalBytes => 100;

  @override
  TaskState get state => TaskState.success;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockStorageReference implements Reference {

  MockStorageReference(this._path, this._storage);
  final String _path;
  final StorageMock _storage;

  @override
  String get bucket => 'mock-bucket';

  @override
  String get fullPath => _path;

  @override
  String get name => _path.split('/').last;

  @override
  FirebaseStorage get storage => FirebaseStorage.instance;

  @override
  Reference child(String path) =>
      MockStorageReference('$_path/$path', _storage);

  @override
  Future<String> getDownloadURL() async =>
      'https://mock-storage.example.com/$_path';

  @override
  UploadTask putData(Uint8List data, [SettableMetadata? metadata]) {
    return MockUploadTask(MockTaskSnapshot());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class StorageMock implements StorageInterface {
  @override
  Reference ref([String? path]) {
    return MockStorageReference(path ?? '', this);
  }

  @override
  Future<ListResult> listAll() async {
    return MockListResult([]);
  }
}

class MockListResult implements ListResult {

  MockListResult(this.items);
  @override
  final List<Reference> items;

  @override
  final List<Reference> prefixes = [];

  @override
  final String? nextPageToken = null;

  @override
  FirebaseStorage get storage => FirebaseStorage.instance;
}
