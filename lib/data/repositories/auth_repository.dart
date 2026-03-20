import 'package:marketplace_flutter_application/data/dtos/auth/signup_dto.dart';
import 'package:marketplace_flutter_application/data/dtos/auth/user_dto.dart';
import 'package:marketplace_flutter_application/data/storage/auth_token_storage.dart';
import 'package:marketplace_flutter_application/data/services/auth_service.dart';

class AuthRepository {
  final AuthService authService;
  final TokenStorage tokenStorage;

  AuthRepository({
    required this.authService,
    required this.tokenStorage,
  });

  //Signup

  Future<UserDto> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final dto = SignupDto(
      name: name,
      email: email,
      password: password,
    );

    final userDto = await authService.signup(dto);

    return UserDto(
      id: userDto.id,
      name: userDto.name,
      email: userDto.email,
      rating: userDto.rating,
    );
  }

  //Login

  Future<UserDto> login({
    required String email,
    required String password,
  }) async {
    final tokenResponse = await authService.login(
      email: email,
      password: password,
    );

    await tokenStorage.saveToken(tokenResponse.accessToken);

    final userDto = await authService.getCurrentUser(tokenResponse.accessToken);

    return UserDto(
      id: userDto.id,
      name: userDto.name,
      email: userDto.email,
      rating: userDto.rating,
    );
  }

  // Restaurar sesión
  Future<UserDto?> tryRestoreSession() async {
    final token = await tokenStorage.getToken();
    if (token == null) return null;

    try {
      final userDto = await authService.getCurrentUser(token);

      return UserDto(
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

  Future<void> logout() async {
    await tokenStorage.clearToken();
  }
}