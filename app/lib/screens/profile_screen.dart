import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/auth_provider.dart';
import '../features/auth/presentation/user_provider.dart';
import '../theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameAsync = ref.watch(currentUserNameProvider);
    final name = nameAsync.valueOrNull ?? '';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
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
                Text(name, style: AppText.manrope(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 24),
              ],
              const Divider(color: AppColors.line),
              const Spacer(),
              GestureDetector(
                onTap: () => ref.read(authNotifierProvider.notifier).logout(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.terra.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, color: AppColors.terra, size: 18),
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
