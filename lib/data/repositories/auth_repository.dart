import 'package:marketplace_flutter_application/data/dtos/auth/signup_dto.dart';
import 'package:marketplace_flutter_application/data/storage/auth_token_storage.dart';
import 'package:marketplace_flutter_application/data/services/auth_service.dart';
import 'package:marketplace_flutter_application/data/domains/auth/app_user.dart';

class AuthRepository {
  final AuthService authService;
  final TokenStorage tokenStorage;

  AuthRepository({
    required this.authService,
    required this.tokenStorage,
  });

  Future<AppUser> signup({
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

    return AppUser(
      id: userDto.id,
      name: userDto.name,
      email: userDto.email,
      rating: userDto.rating,
    );
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final tokenResponse = await authService.login(
      email: email,
      password: password,
    );

    await tokenStorage.saveToken(tokenResponse.accessToken);

    final userDto = await authService.getCurrentUser(tokenResponse.accessToken);

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

  Future<void> logout() async {
    await tokenStorage.clearToken();
  }
}