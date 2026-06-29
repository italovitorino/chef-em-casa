import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/notification/presentation/notification_provider.dart';
import '../theme.dart';
import 'chef_briefing_list_tab.dart';
import 'chef_negotiation_list_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class ChefHomeScreen extends ConsumerStatefulWidget {
  const ChefHomeScreen({super.key});

  @override
  ConsumerState<ChefHomeScreen> createState() => _ChefHomeScreenState();
}

class _ChefHomeScreenState extends ConsumerState<ChefHomeScreen> {
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          _buildContent(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ChefTabBar(
              activeIndex: _activeTab,
              unreadCount: ref.watch(unreadCountProvider),
              onTab: (i) => setState(() => _activeTab = i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() => switch (_activeTab) {
        1 => const ChefNegotiationListScreen(),
        2 => const NotificationsScreen(),
        3 => const ProfileScreen(),
        _ => const ChefBriefingListTab(),
      };
}

class _ChefTabBar extends StatelessWidget {
  final int activeIndex;
  final int unreadCount;
  final ValueChanged<int> onTab;

  const _ChefTabBar({
    required this.activeIndex,
    required this.unreadCount,
    required this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding:
          EdgeInsets.only(bottom: bottomPad > 0 ? bottomPad : 16, top: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: [0.7, 1.0],
          colors: [Color(0xFA15100B), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _TabItem(
              icon: Icons.work_outline,
              label: 'Pedidos',
              active: activeIndex == 0,
              onTap: () => onTab(0)),
          _TabItem(
              icon: Icons.handshake_outlined,
              label: 'Negociações',
              active: activeIndex == 1,
              onTap: () => onTab(1)),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _TabItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notificações',
                  active: activeIndex == 2,
                  onTap: () => onTab(2)),
              if (unreadCount > 0)
                Positioned(
                  top: 0,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                        color: AppColors.terra, shape: BoxShape.circle),
                    child: Text(
                      '$unreadCount',
                      style:
                          AppText.manrope(fontSize: 9, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          _TabItem(
              icon: Icons.person_outline,
              label: 'Perfil',
              active: activeIndex == 3,
              onTap: () => onTab(3)),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 23,
                color: active ? AppColors.terra : AppColors.faint),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppText.manrope(
                fontSize: 10.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? AppColors.cream : AppColors.faint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
