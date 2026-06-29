import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_repository.dart';
import '../domain/auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthInitial();

  Future<void> login({required String email, required String password}) async {
    state = const AuthLoading();
    try {
      final tokens = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      final userName = _nameFromJwt(tokens.accessToken);
      final userRole = _roleFromJwt(tokens.accessToken);
      await ref.read(tokenStorageProvider).save(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
            userName: userName,
            userRole: userRole,
          );
      state = const AuthAuthenticated();
    } on Exception catch (e) {
      state = AuthError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Map<String, dynamic>? _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1];
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      final decoded = utf8.decode(base64Url.decode(payload));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  String? _nameFromJwt(String token) => _decodeJwt(token)?['name'] as String?;

  String? _roleFromJwt(String token) => _decodeJwt(token)?['role'] as String?;

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String role = 'CLIENT',
  }) async {
    state = const AuthLoading();
    try {
      await ref
          .read(authRepositoryProvider)
          .register(name: name, email: email, password: password, role: role);
      // Auto-login após cadastro
      final tokens = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      final userName = _nameFromJwt(tokens.accessToken);
      final userRole = _roleFromJwt(tokens.accessToken);
      await ref.read(tokenStorageProvider).save(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
            userName: userName,
            userRole: userRole,
          );
      state = const AuthAuthenticated();
    } on Exception catch (e) {
      state = AuthError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clear();
    state = const AuthUnauthenticated();
  }

  void forceLogout() {
    ref.read(tokenStorageProvider).clear(); // fire-and-forget
    state = const AuthUnauthenticated();
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
