import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/auth_provider.dart';
import '../features/auth/presentation/user_provider.dart';
import '../features/negotiation/presentation/chef_negotiations_provider.dart';
import '../theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameAsync = ref.watch(currentUserNameProvider);
    final roleAsync = ref.watch(currentUserRoleProvider);
    final name = nameAsync.valueOrNull ?? '';
    final role = roleAsync.valueOrNull ?? 'CLIENT';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Perfil', style: AppText.cormorant(fontSize: 32)),
              const SizedBox(height: 24),
              if (name.isNotEmpty) ...[
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      center: Alignment(-0.4, -0.5),
                      colors: [Color(0xFF3D2A1A), Color(0xFF2A1F15)],
                    ),
                    border: Border.all(color: AppColors.line2),
                  ),
                  child: Center(
                    child: Text(
                      name[0].toUpperCase(),
                      style: AppText.cormorant(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(name,
                    style: AppText.manrope(
                        fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 24),
              ],
              const Divider(color: AppColors.line),
              const SizedBox(height: 24),
              if (role == 'CHEF') const _ChefStatsSection(),
              const Spacer(),
              GestureDetector(
                onTap: () =>
                    ref.read(authNotifierProvider.notifier).logout(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.terra.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout,
                          color: AppColors.terra, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Sair da conta',
                        style: AppText.manrope(
                          color: AppColors.terra,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChefStatsSection extends ConsumerWidget {
  const _ChefStatsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final negs = ref.watch(chefNegotiationsProvider).valueOrNull ?? [];
    final completed = negs.where((n) => n.isCompleted).toList();
    final totalEarnings = completed.fold(
        0.0, (sum, n) => sum + (n.currentProposal?.totalAmount ?? 0.0));
    final formattedEarnings =
        'R\$ ${totalEarnings.toStringAsFixed(2).replaceAll('.', ',')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Seu desempenho', style: AppText.cormorant(fontSize: 22)),
        const SizedBox(height: 14),
        Row(
          children: [
            _StatCard(
              icon: Icons.check_circle_outline,
              label: 'Eventos concluídos',
              value: '${completed.length}',
            ),
            const SizedBox(width: 12),
            _StatCard(
              icon: Icons.attach_money,
              label: 'Total recebido',
              value: formattedEarnings,
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A1A0E), Color(0xFF1A1108)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.terra, size: 20),
            const SizedBox(height: 10),
            Text(value, style: AppText.cormorant(fontSize: 22)),
            const SizedBox(height: 4),
            Text(label,
                style:
                    AppText.manrope(color: AppColors.muted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
