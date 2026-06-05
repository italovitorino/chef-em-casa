import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'api_config.dart';

class TokenInterceptor extends Interceptor {
  final TokenStorage _storage;
  final Future<void> Function() _onSessionExpired;
  late final Dio _dio;

  static const _retryKey = 'isRetry';

  TokenInterceptor({
    required TokenStorage storage,
    required Future<void> Function() onSessionExpired,
  })  : _storage = storage, // ignore: prefer_initializing_formals
        _onSessionExpired = onSessionExpired; // ignore: prefer_initializing_formals

  /// Call once after the parent [Dio] instance is created.
  void init(Dio dio) => _dio = dio;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.accessToken;
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isRetry = err.requestOptions.extra[_retryKey] == true;
    if (err.response?.statusCode != 401 || isRetry) return handler.next(err);

    final refresh = await _storage.refreshToken;
    if (refresh == null) {
      await _onSessionExpired();
      return handler.next(err);
    }

    try {
      // Use a fresh Dio to avoid interceptor loop during refresh
      final refreshDio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
      final res = await refreshDio.post(
        '/api/auth/refresh',
        data: {'refreshToken': refresh},
      );
      final newAccess = res.data['accessToken'] as String;
      final newRefresh = res.data['refreshToken'].toString();
      await _storage.save(accessToken: newAccess, refreshToken: newRefresh);

      // Retry original request with new token
      final opts = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newAccess'
        ..extra[_retryKey] = true;
      final retryResponse = await _dio.fetch(opts);
      return handler.resolve(retryResponse);
    } catch (_) {
      await _onSessionExpired();
      return handler.next(err);
    }
  }
}
