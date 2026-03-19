import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:marketplace_flutter_application/models/app_user.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

/// Facade pattern - hides all the firebase sdk complexity behind simple methods
/// so the rest of the app doesnt need to know about firebase internals
class FirebaseService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // ---- auth stuff ----

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUp(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  // ---- firestore users ----

  Future<void> createUserDoc(AppUser user) {
    return _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromMap(doc.data()!, uid);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) {
    return _firestore.collection('users').doc(uid).update(data);
  }

  // ---- firestore products ----

  Future<String> createProduct(Map<String, dynamic> data) async {
    final ref = await _firestore.collection('products').add(data);
    return ref.id;
  }

  Future<List<ListingSummary>> getProducts() async {
    final snap = await _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      return ListingSummary(
        id: d.id,
        title: data['title'] ?? '',
        price: '\$${data['price'] ?? 0}',
        category: data['category'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        averageRating: (data['averageRating'] ?? 0).toDouble(),
      );
    }).toList();
  }

  Future<List<ListingSummary>> searchProducts(String query) async {
    // firestore doesnt have full text search so we do prefix match
    final snap = await _firestore
        .collection('products')
        .orderBy('title')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      return ListingSummary(
        id: d.id,
        title: data['title'] ?? '',
        price: '\$${data['price'] ?? 0}',
        category: data['category'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        averageRating: (data['averageRating'] ?? 0).toDouble(),
      );
    }).toList();
  }

  // ---- storage ----

  // uplod image to firebase storage and get the download url
  Future<String> uploadImage(File file, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<String> uploadProfilePhoto(File file, String uid) {
    return uploadImage(file, 'profiles/$uid.jpg');
  }

  Future<String> uploadProductImage(File file, String productId) {
    return uploadImage(file, 'products/$productId.jpg');
  }
}
