import 'package:flutter/widgets.dart';
import 'package:marketplace_flutter_application/data/dtos/auth/signup_dto.dart';
import 'package:marketplace_flutter_application/data/dtos/auth/signup_response_dto.dart';
import 'package:marketplace_flutter_application/data/storage/auth_token_storage.dart';
import 'package:marketplace_flutter_application/data/services/auth_service.dart';
import 'package:marketplace_flutter_application/data/domains/auth/app_user.dart';

class AuthRepository {
  final AuthService authService;
  final TokenStorage tokenStorage;

  AuthRepository({required this.authService, required this.tokenStorage});

  Future<SignupResponseDto> signup({
  required String name,
  required String email,
  required String password,
}) async {
  final dto = SignupDto(name: name, email: email, password: password);

  final response = await authService.signup(dto);

  return response;
}

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final tokenResponse = await authService.login(
      email: email,
      password: password,
    );
    debugPrint('TOKEN: ${tokenResponse.accessToken}');

    await tokenStorage.saveToken(tokenResponse.accessToken);
    debugPrint('TOKEN GUARDADO');

    final userDto = await authService.getCurrentUser(tokenResponse.accessToken);
    debugPrint('ME OK: ${userDto.email}');

    return AppUser(
      id: userDto.id,
      name: userDto.name,
      email: userDto.email,
      rating: userDto.rating,
    );
  }

  Future<AppUser?> tryRestoreSession() async {
    final token = await tokenStorage.getToken();
    if (token == null) return null;

    try {
      final userDto = await authService.getCurrentUser(token);

      return AppUser(
        id: userDto.id,
        name: userDto.name,
        email: userDto.email,
        rating: userDto.rating,
      );
    } catch (_) {
      await tokenStorage.clearToken();
      return null;
    }
  }

  Future<AppUser> getMyProfile() async {
    final token = await tokenStorage.getToken();

    if (token == null) {
      throw Exception('No hay sesión activa');
    }

    final userDto = await authService.getCurrentUser(token);

    return AppUser(
      id: userDto.id,
      name: userDto.name,
      email: userDto.email,
      rating: userDto.rating,
    );
  }

  Future<void> logout() async {
    await tokenStorage.clearToken();
  }
}
