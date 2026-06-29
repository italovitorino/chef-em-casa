import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userNameKey = 'user_name';
  static const _roleKey = 'user_role';

  final FlutterSecureStorage _store;

  TokenStorage([FlutterSecureStorage? store])
      : _store = store ?? const FlutterSecureStorage();

  Future<void> save({
    required String accessToken,
    required String refreshToken,
    String? userName,
    String? userRole,
  }) async {
    await Future.wait([
      _store.write(key: _accessKey, value: accessToken),
      _store.write(key: _refreshKey, value: refreshToken),
      if (userName != null && userName.isNotEmpty)
        _store.write(key: _userNameKey, value: userName),
      if (userRole != null && userRole.isNotEmpty)
        _store.write(key: _roleKey, value: userRole),
    ]);
  }

  Future<String?> get accessToken => _store.read(key: _accessKey);
  Future<String?> get refreshToken => _store.read(key: _refreshKey);
  Future<String?> get userName => _store.read(key: _userNameKey);
  Future<String?> get userRole => _store.read(key: _roleKey);

  Future<bool> hasToken() async =>
      (await _store.read(key: _accessKey)) != null;

  Future<void> clear() async {
    await Future.wait([
      _store.delete(key: _accessKey),
      _store.delete(key: _refreshKey),
      _store.delete(key: _userNameKey),
      _store.delete(key: _roleKey),
    ]);
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());
