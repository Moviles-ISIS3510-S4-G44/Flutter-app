import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:marketplace_flutter_application/config/app_config.dart';
import 'package:marketplace_flutter_application/data/dtos/ratings/user_ratings_dto.dart';

class RatingsService {
  final http.Client _client = http.Client();
  final String _baseUrl = AppConfig.apiBaseUrl;

  /// Ratings del usuario autenticado (como vendedor).
  Future<UserRatingsDto> getMyRatings(String token) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/users/me/ratings'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return UserRatingsDto.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      throw Exception('Error fetching ratings: ${response.statusCode}');
    } on TimeoutException {
      throw Exception('Connection timeout fetching ratings.');
    } catch (e) {
      debugPrint('RatingsService.getMyRatings error: $e');
      rethrow;
    }
  }

  /// Ratings de cualquier vendedor por ID (para ver el perfil de otro usuario).
  Future<UserRatingsDto> getRatingsForUser(String userId, String token) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/users/$userId/ratings'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return UserRatingsDto.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      throw Exception('Error fetching ratings: ${response.statusCode}');
    } on TimeoutException {
      throw Exception('Connection timeout fetching ratings.');
    } catch (e) {
      debugPrint('RatingsService.getRatingsForUser error: $e');
      rethrow;
    }
  }

  Future<void> rateSeller({
    required String purchaseId,
    required int score,        // 1–5
    required String token,
  }) async {
    final response = await _client.patch(
      Uri.parse('$_baseUrl/purchases/$purchaseId/rate-seller'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'rating': score}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Error al calificar: ${response.statusCode}');
    }
  }
}