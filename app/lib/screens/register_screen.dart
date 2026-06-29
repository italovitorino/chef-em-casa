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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _selectedRole = 'CLIENT';
  String? _localError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    setState(() => _localError = null);

    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty) {
      setState(() => _localError = 'Preencha todos os campos.');
      return;
    }
    if (_passCtrl.text.length < 8) {
      setState(() => _localError = 'Senha deve ter ao menos 8 caracteres.');
      return;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _localError = 'As senhas não conferem.');
      return;
    }

    await ref.read(authNotifierProvider.notifier).register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          role: _selectedRole,
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
                      'Criar\nconta',
                      style: AppText.cormorant(fontSize: 38, height: 1.05),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Preencha seus dados para começar.',
                      style:
                          AppText.manrope(fontSize: 14.5, color: AppColors.muted),
                    ),
                    const SizedBox(height: 30),
                    AppTextField(
                      icon: Icons.person_outline,
                      label: 'Nome completo',
                      controller: _nameCtrl,
                    ),
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.line),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          for (final (role, label) in [
                            ('CLIENT', 'Cliente'),
                            ('CHEF', 'Chef'),
                          ])
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedRole = role),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  decoration: BoxDecoration(
                                    color: _selectedRole == role
                                        ? AppColors.terra
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    style: AppText.manrope(
                                      fontWeight: FontWeight.w700,
                                      color: _selectedRole == role
                                          ? Colors.white
                                          : AppColors.muted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      icon: Icons.email_outlined,
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
                    const SizedBox(height: 18),
                    AppTextField(
                      icon: Icons.lock_outline,
                      label: 'Confirmar senha',
                      controller: _confirmCtrl,
                      obscure: true,
                    ),
                    if (_localError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _localError!,
                        style: AppText.manrope(
                            fontSize: 13, color: AppColors.terra),
                      ),
                    ],
                    const SizedBox(height: 26),
                    AppButton(
                      label: isLoading ? 'Criando conta…' : 'Criar conta',
                      onTap: isLoading ? null : _submit,
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
                    'Já tem conta? ',
                    style:
                        AppText.manrope(fontSize: 13.5, color: AppColors.muted),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Entrar',
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
