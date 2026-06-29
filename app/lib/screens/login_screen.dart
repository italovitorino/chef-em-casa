import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/domain/auth_state.dart';
import '../features/auth/presentation/auth_provider.dart';
import '../theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'chef_home_screen.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    await ref.read(authNotifierProvider.notifier).login(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
  }

  Future<void> _navigateBasedOnRole() async {
    final role = await ref.read(tokenStorageProvider).userRole;
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            role == 'CHEF' ? const ChefHomeScreen() : const HomeScreen(),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authNotifierProvider, (_, next) {
      if (next is AuthAuthenticated) {
        _navigateBasedOnRole();
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.terra,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.cream,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bem-vinda\nde volta',
                      style: AppText.cormorant(fontSize: 38, height: 1.05),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Entre para acompanhar seus briefings e conversas.',
                      style: AppText.manrope(
                          fontSize: 14.5, color: AppColors.muted),
                    ),
                    const SizedBox(height: 30),
                    AppTextField(
                      icon: Icons.person_outline,
                      label: 'E-mail',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      icon: Icons.lock_outline,
                      label: 'Senha',
                      controller: _passCtrl,
                      obscure: true,
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Esqueci a senha',
                          style: AppText.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    AppButton(
                      label: isLoading ? 'Entrando…' : 'Entrar',
                      onTap: isLoading ? null : _login,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                            child: Divider(color: AppColors.line, thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OU CONTINUE COM',
                            style: AppText.spaceMono(
                              fontSize: 10.5,
                              color: AppColors.faint,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Expanded(
                            child: Divider(color: AppColors.line, thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Apple',
                            onTap: () {},
                            variant: AppButtonVariant.soft,
                            size: AppButtonSize.md,
                            icon: Icons.apple,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _GoogleButton(onTap: () {})),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 34, top: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Novo por aqui? ',
                    style:
                        AppText.manrope(fontSize: 13.5, color: AppColors.muted),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen()),
                    ),
                    child: Text(
                      'Criar conta',
                      style: AppText.manrope(
                          fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
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

class _GoogleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GoogleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceHi,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.muted, width: 1.5),
              ),
              child: Center(
                child: Text(
                  'G',
                  style: AppText.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cream,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 9),
            Text(
              'Google',
              style:
                  AppText.manrope(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
