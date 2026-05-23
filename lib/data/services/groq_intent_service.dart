import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:marketplace_flutter_application/config/app_config.dart';
import 'package:marketplace_flutter_application/data/dtos/search/intent_filters.dart';
import 'package:marketplace_flutter_application/data/services/intent_parser.dart';

class GroqIntentService implements IntentParser {
  final http.Client _client;

  GroqIntentService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<IntentFilters> parseIntent(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return IntentFilters.empty;

    final uri = Uri.parse(AppConfig.groqApiUrl);
    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppConfig.groqApiKey}',
      },
      body: jsonEncode({
        'model': 'gemma2-9b-it',
        'temperature': 0.2,
        'messages': [
          {
            'role': 'system',
            'content':
                'You extract structured filters from marketplace search queries. '
                'Return ONLY valid JSON with keys: min_price, max_price, category, condition. '
                'Use null for missing values. condition must be one of: new, used, refurbished.',
          },
          {
            'role': 'user',
            'content': trimmed,
          }
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return IntentFilters.empty;
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) return IntentFilters.empty;
    final message = choices.first as Map<String, dynamic>;
    final content = (message['message'] as Map<String, dynamic>?)?['content'] as String? ?? '';

    final jsonPayload = _extractJson(content);
    if (jsonPayload == null) return IntentFilters.empty;

    try {
      final data = jsonDecode(jsonPayload) as Map<String, dynamic>;
      return _fromMap(data);
    } catch (_) {
      return IntentFilters.empty;
    }
  }

  IntentFilters _fromMap(Map<String, dynamic> data) {
    final minPrice = _asDouble(data['min_price']);
    final maxPrice = _asDouble(data['max_price']);
    final category = _normalizeString(data['category']);
    final condition = _normalizeCondition(data['condition']);
    return IntentFilters(
      minPrice: minPrice,
      maxPrice: maxPrice,
      category: category,
      condition: condition,
    );
  }

  String? _extractJson(String content) {
    final start = content.indexOf('{');
    final end = content.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;
    return content.substring(start, end + 1);
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value.toString());
    return parsed;
  }

  String? _normalizeString(dynamic value) {
    if (value == null) return null;
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;
    return raw;
  }

  String? _normalizeCondition(dynamic value) {
    final raw = _normalizeString(value)?.toLowerCase();
    if (raw == null) return null;
    if (raw.contains('new')) return 'new';
    if (raw.contains('used') || raw.contains('segunda')) return 'used';
    if (raw.contains('refurb')) return 'refurbished';
    return null;
  }
}

