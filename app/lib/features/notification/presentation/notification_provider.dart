import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notification_dto.dart';
import '../data/notification_repository.dart';

class NotificationNotifier extends AsyncNotifier<List<NotificationDTO>> {
  Timer? _timer;

  @override
  Future<List<NotificationDTO>> build() async {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
    ref.onDispose(() => _timer?.cancel());
    return ref.read(notificationRepositoryProvider).getNotifications();
  }

  Future<void> _refresh() async {
    final list = await ref.read(notificationRepositoryProvider).getNotifications();
    state = AsyncData(list);
  }

  Future<void> markRead(String id) async {
    await ref.read(notificationRepositoryProvider).markRead(id);
    await _refresh();
  }
}

final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, List<NotificationDTO>>(
        NotificationNotifier.new);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).valueOrNull?.where((n) => !n.read).length ?? 0;
});
