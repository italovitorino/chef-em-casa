import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  final FlutterSecureStorage _store;

  TokenStorage([FlutterSecureStorage? store])
      : _store = store ?? const FlutterSecureStorage();

  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _store.write(key: _accessKey, value: accessToken),
      _store.write(key: _refreshKey, value: refreshToken),
    ]);
  }

  Future<String?> get accessToken => _store.read(key: _accessKey);
  Future<String?> get refreshToken => _store.read(key: _refreshKey);

  Future<bool> hasToken() async =>
      (await _store.read(key: _accessKey)) != null;

  Future<void> clear() async {
    await Future.wait([
      _store.delete(key: _accessKey),
      _store.delete(key: _refreshKey),
    ]);
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());
