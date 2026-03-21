import 'dart:io';
import 'package:marketplace_flutter_application/data/services/mock_firebase_service.dart';
import 'package:marketplace_flutter_application/models/app_user.dart';

// mock user repo for testing without firebase
// delete when firebase is configured
class MockUserRepository {
  final MockFirebaseService _mockService;

  MockUserRepository(this._mockService);

  Future<AppUser?> getCurrentUser() async {
    return _mockService.currentUser;
  }

  Future<AppUser?> login(String email, String password) async {
    return _mockService.signIn(email, password);
  }

  Future<void> logout() => _mockService.signOut();

  Future<String> updateProfilePhoto(File image) async {
    final user = _mockService.currentUser;
    if (user == null) throw Exception('not logged in');
    final url = await _mockService.uploadProfilePhoto(image, user.uid);
    await _mockService.updateUser(user.uid, {'photoUrl': url});
    return url;
  }
}
