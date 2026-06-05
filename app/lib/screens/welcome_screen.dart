import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/app_button.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // hero area
          Positioned.fill(
            child: Column(
              children: [
                Expanded(child: _HeroArea()),
                const SizedBox(height: 330),
              ],
            ),
          ),
          // bottom copy + actions
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _BottomSection(
              onRegister: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
              onLogin: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _HeroArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2A1C12), Color(0xFF15100B)],
            ),
          ),
        ),
        // warm radial glows
        Positioned(
          right: -40, top: -60,
          width: 300, height: 300,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                const Color(0xFF4A2A18).withAlpha(180),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          left: -40, bottom: 60,
          width: 250, height: 250,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                const Color(0xFF3A2214).withAlpha(140),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        // diagonal hairlines
        CustomPaint(painter: _DiagonalPainter()),
        // center plate mark
        Center(
          child: Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.line2),
            ),
            child: Center(
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line),
                ),
                child: const Center(
                  child: Icon(Icons.restaurant, size: 40, color: AppColors.gold),
                ),
              ),
            ),
          ),
        ),
        // placeholder label
        Positioned(
          left: 14, bottom: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0x4D000000),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'foto · prato assinatura',
              style: AppText.spaceMono(
                fontSize: 9.5,
                color: const Color(0x80F4EFE6),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        // bottom fade
        Positioned(
          left: 0, right: 0, bottom: 0,
          height: 180,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xFF15100B), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomSection extends StatelessWidget {
  final VoidCallback onRegister;
  final VoidCallback onLogin;
  const _BottomSection({required this.onRegister, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 48),
      child: Column(
        children: [
          Text(
            'Chef em casa',
            style: AppText.spaceMono(
              fontSize: 11,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Alta gastronomia\nna sua mesa',
            textAlign: TextAlign.center,
            style: AppText.cormorant(fontSize: 44, height: 1.02, letterSpacing: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Descreva seu evento e receba propostas de chefs particulares prontos para cozinhar onde você estiver.',
            textAlign: TextAlign.center,
            style: AppText.manrope(
              fontSize: 15,
              color: AppColors.muted,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 28),
          AppButton(label: 'Começar agora', onTap: onRegister),
          const SizedBox(height: 12),
          AppButton(
            label: 'Já tenho conta',
            onTap: onLogin,
            variant: AppButtonVariant.ghost,
          ),
        ],
      ),
    );
  }
}

class _DiagonalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x0CF4EFE6)
      ..strokeWidth = 1.0;
    const step = 15.0;
    final diag = size.height;
    for (double x = -diag; x < size.width + diag; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x + diag, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
