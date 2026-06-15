import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/briefing/presentation/briefings_list_provider.dart';
import '../theme.dart';
import '../widgets/app_button.dart';
import 'home_screen.dart';

class SuccessScreen extends ConsumerStatefulWidget {
  const SuccessScreen({super.key});

  @override
  ConsumerState<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends ConsumerState<SuccessScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _visible = true);
    });
  }

  void _goToBriefings() {
    ref.invalidate(briefingsListProvider);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen(initialTab: 1)),
      (_) => false,
    );
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(30, 0, 30, bottomPad + 16),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: _visible ? 1.0 : 0.5,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        child: AnimatedOpacity(
                          opacity: _visible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 400),
                          child: Container(
                            width: 104, height: 104,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.terraSoft,
                              border: Border.all(color: AppColors.terra, width: 1.5),
                            ),
                            child: Center(
                              child: Container(
                                width: 72, height: 72,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.terra,
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 38),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'BRIEFING ENVIADO',
                        textAlign: TextAlign.center,
                        style: AppText.spaceMono(fontSize: 10.5, letterSpacing: 2.5),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Seu pedido\nestá no ar',
                        textAlign: TextAlign.center,
                        style: AppText.cormorant(fontSize: 38, height: 1.1),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Os chefs da sua região já podem ver o briefing e vão abrir uma conversa para negociar menu e valores. Você recebe um aviso a cada proposta.',
                        textAlign: TextAlign.center,
                        style: AppText.manrope(
                          fontSize: 15,
                          color: AppColors.muted,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppButton(
                label: 'Acompanhar meus briefings',
                onTap: _goToBriefings,
                icon: Icons.description,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Voltar para a home',
                onTap: _goHome,
                variant: AppButtonVariant.ghost,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
