import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:marketplace_flutter_application/config/app_config.dart';
import 'package:marketplace_flutter_application/data/dtos/interactions/interaction_dto.dart';

class InteractionService {
  final http.Client _httpClient = http.Client();
  final String _baseUrl = AppConfig.apiBaseUrl;

  Future<void> registerInteraction({
    required String userId,
    required String listingId,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/interactions'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'listing_id': listingId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      throw Exception('Failed to register interaction');
    } on TimeoutException {
      throw Exception('Connection timeout');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<List<InteractionDto>> getTopUserInteractions(String userId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/interactions/users/$userId/top'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((item) => InteractionDto.fromJson(item))
            .toList();
      }

      throw Exception('Failed to get top interactions');
    } on TimeoutException {
      throw Exception('Connection timeout');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}