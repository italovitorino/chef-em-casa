import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  factory AppException.fromDioException(DioException e) {
    final code = e.response?.statusCode;
    final body = e.response?.data;
    final apiMessage = body is Map ? body['message'] as String? : null;
    return AppException(
      apiMessage ?? _defaultMessage(code),
      statusCode: code,
    );
  }

  static String _defaultMessage(int? code) => switch (code) {
        400 => 'Dados inválidos.',
        401 => 'E-mail ou senha incorretos.',
        409 => 'E-mail já cadastrado.',
        422 => 'Dados inválidos.',
        null => 'Sem conexão. Verifique sua internet.',
        _ => 'Erro no servidor. Tente novamente.',
      };

  @override
  String toString() => 'AppException($statusCode): $message';
}
