import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import 'chat_dto.dart';

class ChatRepository {
  final Dio _dio;

  ChatRepository(this._dio);

  Future<List<ChatMessageDTO>> getHistory(String negotiationId) async {
    final response =
        await _dio.get('/api/negotiations/$negotiationId/messages');
    final list = response.data as List<dynamic>;
    return list
        .whereType<Map<String, dynamic>>()
        .map(ChatMessageDTO.fromJson)
        .toList();
  }
}

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(ref.read(dioClientProvider)),
);
