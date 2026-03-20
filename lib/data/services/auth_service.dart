import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:marketplace_flutter_application/config/app_config.dart';

import 'package:marketplace_flutter_application/data/dtos/auth/signup_dto.dart';
import 'package:marketplace_flutter_application/data/dtos/auth/user_dto.dart';
import 'package:marketplace_flutter_application/data/dtos/auth/token_dto.dart';

class AuthService {
  final http.Client _httpClient = http.Client();
  final String _baseUrl = AppConfig.apiBaseUrl;

  Future<UserDto> signup(SignupDto dto) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/auth/signup'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 201) {
      return UserDto.fromJson(jsonDecode(response.body));
    } 
    else {
      debugPrint('Failed to signup: ${response.statusCode} - ${response.body}'); 
      throw Exception('Failed to signup');
    }
  }

  Future<TokenDto> login({required String email, required String password}) 
  async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return TokenDto.fromJson(jsonDecode(response.body));
    } 
    else {
      debugPrint('Failed to login: ${response.statusCode} - ${response.body}'); 
      throw Exception('Failed to login');
    }
  }

    Future<UserDto> getCurrentUser(String token) async {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
  
      if (response.statusCode == 200) {
        return UserDto.fromJson(jsonDecode(response.body));
      } 
      else {
        debugPrint('Failed to fetch current user: ${response.statusCode} - ${response.body}'); 
        throw Exception('Failed to fetch current user');
      }
    }
}