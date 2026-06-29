import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/notification/data/notification_dto.dart';
import '../features/notification/presentation/notification_provider.dart';
import '../theme.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
              child: Text('Notificações', style: AppText.cormorant(fontSize: 28)),
            ),
            Expanded(
              child: notifAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.terra)),
                error: (_, _) => Center(
                    child: Text('Erro ao carregar',
                        style: AppText.manrope(color: AppColors.muted))),
                data: (items) => items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.notifications_none,
                                size: 48, color: AppColors.muted),
                            const SizedBox(height: 12),
                            Text('Nenhuma notificação',
                                style: AppText.manrope(color: AppColors.muted)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 8),
                        itemCount: items.length,
                        separatorBuilder: (_, _) =>
                            const Divider(color: AppColors.line, height: 1),
                        itemBuilder: (_, i) => _NotificationTile(
                          notification: items[i],
                          onTap: () => ref
                              .read(notificationProvider.notifier)
                              .markRead(items[i].id),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationDTO notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        color: notification.read ? Colors.transparent : AppColors.terraSoft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 5, right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: notification.read ? Colors.transparent : AppColors.terra,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: AppText.manrope(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: notification.read ? AppColors.muted : AppColors.cream,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: AppText.manrope(
                        fontSize: 13, color: AppColors.muted, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
