import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:marketplace_flutter_application/data/domains/auth/app_user.dart';

class AuthUserStorage {
  static const _keyUser = 'cached_user_profile';

  Future<void> saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'rating': user.rating,
    });
    await prefs.setString(_keyUser, payload);
  }

  Future<AppUser?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUser);
    if (raw == null || raw.isEmpty) return null;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return AppUser(
        id: data['id'] as String,
        name: data['name'] as String,
        email: data['email'] as String,
        rating: (data['rating'] as num).toInt(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }
}
