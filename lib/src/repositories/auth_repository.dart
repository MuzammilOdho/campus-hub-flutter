import 'package:campus_hub/src/api/api_service.dart';
import 'package:campus_hub/src/models/models.dart';

class AuthRepository {
  final ApiService api;
  AuthRepository(this.api);

  Future<LoginResponse> login(String email, String password) => api.login(email, password);
  Future<String> signup(String name, String email, String password) => api.signup(name, email, password);
  Future<UserDto> getProfile() => api.getProfile();
  Future<void> saveToken(String token) => api.saveToken(token);
  Future<String?> getToken() => api.getToken();
  Future<void> clearToken() => api.clearToken();
  Future<void> verifyUser(String email, String code) => api.verifyUser(email, code);
  Future<void> resendVerificationCode(String email) => api.resendVerificationCode(email);
}

