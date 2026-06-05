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
      await ref
          .read(tokenStorageProvider)
          .save(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
      state = const AuthAuthenticated();
    } on Exception catch (e) {
      state = AuthError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      await ref
          .read(authRepositoryProvider)
          .register(name: name, email: email, password: password);
      // Auto-login após cadastro
      final tokens = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref
          .read(tokenStorageProvider)
          .save(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
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
