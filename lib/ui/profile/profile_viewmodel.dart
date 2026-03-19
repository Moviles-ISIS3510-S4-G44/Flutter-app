import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ProfileViewModel extends ChangeNotifier {
  final dynamic _userRepo;
  final dynamic _analytics;
  final ImagePicker _picker = ImagePicker();

  ProfileViewModel(this._userRepo, this._analytics);

  // using dynamic so the team can plug in their own user model later
  dynamic user;
  String? photoUrl;
  bool isLoading = false;
  String? error;

  Future<void> loadProfile() async {
    isLoading = true;
    notifyListeners();

    try {
      if (_userRepo != null) {
        user = await _userRepo.getCurrentUser();
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // pick image from gallery or camear and upload it
  Future<void> pickAndUploadPhoto({required bool fromCamera}) async {
    try {
      final source = fromCamera ? ImageSource.camera : ImageSource.gallery;
      final picked = await _picker.pickImage(source: source, maxWidth: 800);
      if (picked == null) return; // user cancled

      isLoading = true;
      notifyListeners();

      final file = File(picked.path);
      if (_userRepo != null) {
        photoUrl = await _userRepo.updateProfilePhoto(file);
      }
    } catch (e) {
      error = 'Failed to upload photo: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    if (_userRepo != null) await _userRepo.logout();
    user = null;
    notifyListeners();
  }
}
