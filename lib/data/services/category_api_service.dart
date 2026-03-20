import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:marketplace_flutter_application/config/app_config.dart';
import 'package:marketplace_flutter_application/data/dtos/categories/category_dto.dart';

class CategoryApiService {
  final http.Client _httpClient = http.Client();
  final String _baseUrl = AppConfig.apiBaseUrl;

  Future<List<CategoryDto>> getCategories() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/categories'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;

      return jsonList
          .map((json) => CategoryDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      debugPrint(
        'Failed to load categories: ${response.statusCode} - ${response.body}',
      );
      throw Exception('Failed to load categories');
    }
  }
}