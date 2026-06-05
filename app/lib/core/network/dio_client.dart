import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/token_storage.dart';
import 'api_config.dart';
import 'token_interceptor.dart';

/// Sinaliza que a sessão expirou (emitido pelo [TokenInterceptor] após falha
/// no refresh). Observado em [ChefEmCasaApp] para acionar navegação.
final sessionExpiredProvider = StateProvider<bool>((ref) => false);

final dioClientProvider = Provider<Dio>((ref) {
  final storage = ref.read(tokenStorageProvider);

  final interceptor = TokenInterceptor(
    storage: storage,
    onSessionExpired: () async {
      await storage.clear();
      ref.read(sessionExpiredProvider.notifier).state = true;
    },
  );

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  interceptor.init(dio);
  dio.interceptors.add(interceptor);

  return dio;
});
