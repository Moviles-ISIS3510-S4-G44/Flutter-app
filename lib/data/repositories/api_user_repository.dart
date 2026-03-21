import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:marketplace_flutter_application/core/constants/api_constants.dart';
import 'package:marketplace_flutter_application/models/app_user.dart';

class ApiUserRepository {
  AppUser? _currentUser;
  String? _token;

  AppUser? get currentUser => _currentUser;
  String? get token => _token;

  Future<AppUser?> getCurrentUser() async {
    if (_token == null) return null;

    final url = Uri.parse('${ApiConstants.baseUrl}/users/me');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      _currentUser = AppUser.fromJson(jsonDecode(response.body));
      return _currentUser;
    }
    return null;
  }

  Future<AppUser?> login(String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['access_token'];
      return await getCurrentUser();
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
  }

  // placeholder until multipart uplod is done
  Future<String> updateProfilePhoto(File image) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'https://via.placeholder.com/150';
  }
}
