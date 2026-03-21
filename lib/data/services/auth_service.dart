import 'dart:async';
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
    try {
      final response = await _httpClient
          .post(
            Uri.parse('$_baseUrl/auth/signup'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(dto.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('Signup successful');
        return UserDto.fromJson(data);
      }

      //Manejo de errores específicos
      if (response.statusCode == 400) {
        throw Exception(data['detail'] ?? 'Invalid signup data');
      }

      if (response.statusCode == 409) {
        throw Exception(data['detail'] ?? 'Email already registered');
      }

      if (response.statusCode == 422) {
        throw Exception(data['detail'] ?? 'Invalid input data');
      }

      // Error genérico
      throw Exception(data['detail'] ?? 'Unexpected error occurred');

    } on TimeoutException {
      throw Exception('Connection timeout. Try again.');
    } catch (e) {
      debugPrint('Failed to signup: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<TokenDto> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpClient
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {
              'username': email,
              'password': password,
            },
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        debugPrint('Login successful');
        return TokenDto.fromJson(data);
      }

      //Manejo de errores específicos
      if (response.statusCode == 401) {
        throw Exception(data['detail'] ?? 'Incorrect email or password');
      }

      if (response.statusCode == 404) {
        throw Exception('User not found');
      }

      if (response.statusCode == 422) {
        throw Exception('Invalid input data');
      }

      // Error genérico del servidor
      throw Exception(data['detail'] ?? 'Unexpected error occurred');

    } on TimeoutException {
      throw Exception('Connection timeout. Try again.');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
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