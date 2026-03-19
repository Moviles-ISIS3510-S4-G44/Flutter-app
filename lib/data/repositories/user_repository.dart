import 'dart:io';
import 'package:marketplace_flutter_application/data/services/firebase_service.dart';
import 'package:marketplace_flutter_application/models/app_user.dart';

// single source of truth for user data
class UserRepository {
  final FirebaseService _firebaseService;

  UserRepository(this._firebaseService);

  Future<AppUser?> getCurrentUser() async {
    final fbUser = _firebaseService.currentUser;
    if (fbUser == null) return null;
    return _firebaseService.getUser(fbUser.uid);
  }

  Future<AppUser?> login(String email, String password) async {
    final cred = await _firebaseService.signIn(email, password);
    return _firebaseService.getUser(cred.user!.uid);
  }

  Future<void> logout() => _firebaseService.signOut();

  // upload photo and update user doc with new url
  Future<String> updateProfilePhoto(File image) async {
    final uid = _firebaseService.currentUser?.uid;
    if (uid == null) throw Exception('not logged in');
    final url = await _firebaseService.uploadProfilePhoto(image, uid);
    await _firebaseService.updateUser(uid, {'photoUrl': url});
    return url;
  }
}
