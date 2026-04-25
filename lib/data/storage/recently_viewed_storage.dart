import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class RecentlyViewedStorage {
  static const _key = 'recently_viewed_listings';
  static const int maxSize = 8;

  /// Agrega un listing al frente de la lista LRU.
  /// Si ya existía, lo mueve al frente. Si supera [maxSize], elimina el último.
  Future<void> add(ListingSummary listing) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = await _read(prefs);

      // Remover si ya existe (evita duplicados)
      current.removeWhere((l) => l.id == listing.id);

      // Insertar al frente
      current.insert(0, listing);

      // Recortar al límite
      final trimmed = current.take(maxSize).toList();

      await prefs.setString(_key, jsonEncode(trimmed.map(_toJson).toList()));
    } catch (e) {
      debugPrint('RecentlyViewedStorage.add error: $e');
    }
  }

  Future<List<ListingSummary>> getAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await _read(prefs);
    } catch (e) {
      debugPrint('RecentlyViewedStorage.getAll error: $e');
      return [];
    }
  }

  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      debugPrint('RecentlyViewedStorage.clear error: $e');
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<List<ListingSummary>> _read(SharedPreferences prefs) async {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => _fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> _toJson(ListingSummary l) => {
        'id': l.id,
        'sellerId': l.sellerId,
        'title': l.title,
        'price': l.price,
        'category': l.category,
        'imageUrl': l.imageUrl,
        'location': l.location,
      };

  ListingSummary _fromJson(Map<String, dynamic> json) => ListingSummary(
        id: json['id'] as String,
        sellerId: (json['sellerId'] as String?) ?? '',
        title: json['title'] as String,
        price: json['price'] as int,
        category: json['category'] as String,
        imageUrl: json['imageUrl'] as String,
        location: json['location'] as String?,
      );
}