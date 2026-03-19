import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketplace_flutter_application/models/app_user.dart';

class ProfileViewModel extends ChangeNotifier {
  final dynamic _userRepo;
  final dynamic _analytics;
  final ImagePicker _picker = ImagePicker();

  ProfileViewModel(this._userRepo, this._analytics);

  AppUser? user;
  bool isLoading = false;
  String? error;

  Future<void> loadProfile() async {
    isLoading = true;
    notifyListeners();

    try {
      user = await _userRepo.getCurrentUser();
      if (user != null) {
        await _analytics.logViewProfile(user!.uid);
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
      final url = await _userRepo.updateProfilePhoto(file);
      user = user?.copyWith(photoUrl: url);
      await _analytics.logUploadPhoto();
    } catch (e) {
      error = 'Failed to upload photo: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _userRepo.logout();
    user = null;
    notifyListeners();
  }
}
