import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class ListingCacheStorage {
  static const _keyListings = 'cached_listings';
  static const _keyLastUpdated = 'cached_listings_updated_at';

  /// Guarda la lista de listings en disco como JSON.
  Future<void> saveListings(List<ListingSummary> listings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        listings.map((l) => _summaryToJson(l)).toList(),
      );
      await prefs.setString(_keyListings, encoded);
      await prefs.setString(
        _keyLastUpdated,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('ListingCacheStorage.saveListings error: $e');
    }
  }

  /// Devuelve los listings cacheados o lista vacía si no hay nada.
  Future<List<ListingSummary>> getListings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyListings);
      if (raw == null || raw.isEmpty) return [];

      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => _summaryFromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('ListingCacheStorage.getListings error: $e');
      return [];
    }
  }

  /// Devuelve el DateTime de la última actualización o null si no hay caché.
  Future<DateTime?> getLastUpdated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyLastUpdated);
      if (raw == null) return null;
      return DateTime.tryParse(raw);
    } catch (_) {
      return null;
    }
  }

  /// Limpia el caché completamente.
  Future<void> clearListings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyListings);
      await prefs.remove(_keyLastUpdated);
    } catch (e) {
      debugPrint('ListingCacheStorage.clearListings error: $e');
    }
  }

  // Serialización

  Map<String, dynamic> _summaryToJson(ListingSummary l) => {
        'id': l.id,
        'sellerId': l.sellerId,
        'title': l.title,
        'price': l.price,
        'category': l.category,
        'imageUrl': l.imageUrl,
        'location': l.location,
      };

  ListingSummary _summaryFromJson(Map<String, dynamic> json) => ListingSummary(
        id: json['id'] as String,
        sellerId: (json['sellerId'] as String?) ?? '',
        title: json['title'] as String,
        price: json['price'] as int,
        category: json['category'] as String,
        imageUrl: json['imageUrl'] as String,
        location: json['location'] as String?,
      );
}