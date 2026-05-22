import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marketplace_flutter_application/data/dtos/ratings/user_ratings_dto.dart';

class RatingsCacheStorage {
  static const Duration _ttl = Duration(minutes: 10);

  static String _dataKey(String userId) => 'ratings_data_$userId';
  static String _tsKey(String userId) => 'ratings_ts_$userId';

  Future<void> save(String userId, UserRatingsDto dto) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(dto.toJson());
      await Future.wait([
        prefs.setString(_dataKey(userId), encoded),
        prefs.setString(_tsKey(userId), DateTime.now().toIso8601String()),
      ]);
    } catch (e) {
      debugPrint('RatingsCacheStorage.save error: $e');
    }
  }

  Future<UserRatingsDto?> get(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_dataKey(userId));
      if (raw == null || raw.isEmpty) return null;
      if (_isExpired(prefs, userId)) return null;
      return await compute(_decode, raw);
    } catch (e) {
      debugPrint('RatingsCacheStorage.get error: $e');
      return null;
    }
  }

  Future<UserRatingsDto?> getStale(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_dataKey(userId));
      if (raw == null || raw.isEmpty) return null;
      return await compute(_decode, raw);
    } catch (e) {
      debugPrint('RatingsCacheStorage.getStale error: $e');
      return null;
    }
  }

  Future<DateTime?> lastUpdated(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_tsKey(userId));
      if (raw == null) return null;
      return DateTime.tryParse(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_dataKey(userId)),
        prefs.remove(_tsKey(userId)),
      ]);
    } catch (e) {
      debugPrint('RatingsCacheStorage.clear error: $e');
    }
  }

  bool _isExpired(SharedPreferences prefs, String userId) {
    final raw = prefs.getString(_tsKey(userId));
    if (raw == null) return true;
    final savedAt = DateTime.tryParse(raw);
    if (savedAt == null) return true;
    return DateTime.now().difference(savedAt) > _ttl;
  }

  static UserRatingsDto _decode(String raw) {
    return UserRatingsDto.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}