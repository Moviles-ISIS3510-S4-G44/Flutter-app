import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:marketplace_flutter_application/config/app_config.dart';
import 'package:marketplace_flutter_application/data/dtos/auth_dto.dart';

class AuthService {
  final http.Client _httpClient = http.Client();
  final String _baseUrl = AppConfig.apiBaseUrl;

  Future<List<authDto>> getauths() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/auths'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;

      return jsonList
          .map((json) => authDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      debugPrint('Failed to load auths: ${response.statusCode} - ${response.body}'); 
      throw Exception('Failed to load auths');
    }
  }
}