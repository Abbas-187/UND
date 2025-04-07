import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';

// Abstract interfaces for Firebase services

abstract class AuthInterface {
  Stream<firebase_auth.User?> authStateChanges();
  Future<firebase_auth.UserCredential> signInWithEmailAndPassword(
      {required String email, required String password});
  Future<firebase_auth.UserCredential> createUserWithEmailAndPassword(
      {required String email, required String password});
  Future<void> signOut();
  firebase_auth.User? get currentUser;
  Future<firebase_auth.IdTokenResult> getIdTokenResult(
      firebase_auth.User user, bool forceRefresh);
  Future<void> sendPasswordResetEmail({required String email});
}

abstract class FirestoreInterface {
  CollectionReference collection(String path);
  DocumentReference doc(String path);
  Future<void> runTransaction(TransactionHandler<void> updateFunction);
  WriteBatch batch();
}

abstract class StorageInterface {
  Reference ref([String? path]);
  Future<ListResult> listAll();
}

// Real Firebase implementations
class FirebaseAuthReal implements AuthInterface {
  final firebase_auth.FirebaseAuth _auth;

  FirebaseAuthReal({firebase_auth.FirebaseAuth? auth})
      : _auth = auth ?? firebase_auth.FirebaseAuth.instance;

  @override
  Stream<firebase_auth.User?> authStateChanges() => _auth.authStateChanges();

  @override
  Future<firebase_auth.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  @override
  Future<firebase_auth.UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  firebase_auth.User? get currentUser => _auth.currentUser;

  @override
  Future<firebase_auth.IdTokenResult> getIdTokenResult(
          firebase_auth.User user, bool forceRefresh) =>
      user.getIdTokenResult(forceRefresh);

  @override
  Future<void> sendPasswordResetEmail({required String email}) =>
      _auth.sendPasswordResetEmail(email: email);
}

class FirestoreReal implements FirestoreInterface {
  final FirebaseFirestore _firestore;

  FirestoreReal({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  CollectionReference collection(String path) => _firestore.collection(path);

  @override
  DocumentReference doc(String path) => _firestore.doc(path);

  @override
  Future<void> runTransaction(TransactionHandler<void> updateFunction) =>
      _firestore.runTransaction(updateFunction);

  @override
  WriteBatch batch() => _firestore.batch();
}

class StorageReal implements StorageInterface {
  final FirebaseStorage _storage;

  StorageReal({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  @override
  Reference ref([String? path]) =>
      path != null ? _storage.ref(path) : _storage.ref();

  @override
  Future<ListResult> listAll() => _storage.ref().listAll();
}
