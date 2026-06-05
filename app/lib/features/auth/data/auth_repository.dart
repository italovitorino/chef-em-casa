import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/network/dio_client.dart';
import 'auth_dto.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<TokenResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        '/api/auth/login',
        data: LoginRequest(email: email, password: password).toJson(),
      );
      return TokenResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  Future<UserResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        '/api/auth/register',
        data: RegisterRequest(name: name, email: email, password: password)
            .toJson(),
      );
      return UserResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.read(dioClientProvider)),
);
