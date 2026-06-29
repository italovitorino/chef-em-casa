import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import 'notification_dto.dart';

class NotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  Future<List<NotificationDTO>> getNotifications() async {
    final response = await _dio.get('/api/notifications');
    final list = response.data as List<dynamic>;
    return list
        .whereType<Map<String, dynamic>>()
        .map(NotificationDTO.fromJson)
        .toList();
  }

  Future<void> markRead(String notificationId) async {
    await _dio.put('/api/notifications/$notificationId/read');
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(ref.read(dioClientProvider)),
);
