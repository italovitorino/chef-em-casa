import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/format_utils.dart';
import '../features/auth/presentation/user_provider.dart';
import '../features/briefing/presentation/briefings_list_provider.dart';
import '../features/negotiation/presentation/chef_negotiations_provider.dart';
import '../features/notification/data/notification_dto.dart';
import '../features/notification/presentation/notification_provider.dart';
import '../theme.dart';
import 'briefing_detail_screen.dart';
import 'chef_briefing_detail_screen.dart';
import 'chef_negotiation_detail_screen.dart';
import 'negotiation_detail_screen.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(notificationProvider);
    final role = ref.watch(currentUserRoleProvider).valueOrNull ?? 'CLIENT';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
              child:
                  Text('Notificações', style: AppText.cormorant(fontSize: 28)),
            ),
            Expanded(
              child: notifAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.terra)),
                error: (e, _) => Center(
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
                                style:
                                    AppText.manrope(color: AppColors.muted)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(22, 4, 22, 100),
                        itemCount: items.length,
                        itemBuilder: (_, i) => _NotificationTile(
                          notification: items[i],
                          onTap: () =>
                              _handleTap(context, ref, items[i], role),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(
    BuildContext context,
    WidgetRef ref,
    NotificationDTO n,
    String role,
  ) {
    ref.read(notificationProvider.notifier).markRead(n.id);
    final rid = n.relatedId;
    if (rid == null) return;

    if (role == 'CHEF') {
      if (_isBriefingType(n.type)) {
        final matches = (ref.read(briefingsListProvider).valueOrNull ?? [])
            .where((b) => b.id == rid)
            .toList();
        if (matches.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChefBriefingDetailScreen(briefing: matches.first),
            ),
          );
        }
      } else {
        final matches = (ref.read(chefNegotiationsProvider).valueOrNull ?? [])
            .where((neg) => neg.id == rid)
            .toList();
        if (matches.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ChefNegotiationDetailScreen(negotiation: matches.first),
            ),
          );
        }
      }
    } else {
      if (_isBriefingType(n.type)) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => BriefingDetailScreen(briefingId: rid)),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => NegotiationDetailScreen(negotiationId: rid)),
        );
      }
    }
  }

  bool _isBriefingType(String type) =>
      type == 'NEW_BRIEFING' || type == 'INTEREST_EXPRESSED';
}

class _NotificationTile extends StatelessWidget {
  final NotificationDTO notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = !notification.read;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: unread
                ? AppColors.terra.withValues(alpha: 0.55)
                : AppColors.line,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 12, top: 2),
              decoration: BoxDecoration(
                color: unread ? AppColors.terraSoft : AppColors.bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _iconForType(notification.type),
                size: 18,
                color: unread ? AppColors.terra : AppColors.faint,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppText.manrope(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: unread ? AppColors.cream : AppColors.muted,
                          ),
                        ),
                      ),
                      if (unread)
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(left: 8, top: 5),
                          decoration: const BoxDecoration(
                            color: AppColors.terra,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: AppText.manrope(
                        fontSize: 12.5,
                        color: AppColors.muted,
                        height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatDate(notification.createdAt.toIso8601String()),
                    style: AppText.manrope(
                        fontSize: 11, color: AppColors.faint),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) => switch (type) {
        'NEW_BRIEFING' => Icons.work_outline,
        'INTEREST_EXPRESSED' => Icons.star_outline,
        'NEGOTIATION_STARTED' => Icons.handshake_outlined,
        'PROPOSAL_SENT' => Icons.send_outlined,
        'PROPOSAL_ACCEPTED' => Icons.check_circle_outline,
        'PROPOSAL_REJECTED' => Icons.cancel_outlined,
        'PROPOSAL_REVISION_REQUESTED' => Icons.edit_outlined,
        'NEGOTIATION_CANCELLED' => Icons.close,
        'SERVICE_COMPLETED' => Icons.celebration,
        _ => Icons.notifications_outlined,
      };
}
