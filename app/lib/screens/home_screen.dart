import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/user_provider.dart';
import '../features/briefing/presentation/briefings_list_provider.dart';
import '../theme.dart';
import '../widgets/app_placeholder.dart';
import 'briefing_screen.dart';
import 'briefings_screen.dart';

enum HomeVariant { editorial, grid, immersive }

class HomeScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const HomeScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _activeTab;
  HomeVariant _variant = HomeVariant.editorial;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  void _goToBriefing() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BriefingScreen()),
    );
  }

  void _switchVariant() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _VariantPicker(
        current: _variant,
        onSelect: (v) {
          setState(() => _variant = v);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          _buildContent(),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _BottomTabBar(
              activeIndex: _activeTab,
              onTab: (i) {
                if (i == 1 && _activeTab != 1) {
                  ref.invalidate(briefingsListProvider);
                }
                setState(() => _activeTab = i);
              },
              onCreate: _goToBriefing,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_activeTab == 1) {
      return BriefingsScreen(onCreate: _goToBriefing);
    }
    return switch (_variant) {
      HomeVariant.editorial => _HomeEditorial(
          onCreateBriefing: _goToBriefing,
          onSwitchVariant: _switchVariant,
        ),
      HomeVariant.grid => _HomeGrid(
          onCreateBriefing: _goToBriefing,
          onSwitchVariant: _switchVariant,
        ),
      HomeVariant.immersive => _HomeImmersive(
          onCreateBriefing: _goToBriefing,
          onSwitchVariant: _switchVariant,
        ),
    };
  }
}

// ── Variant picker sheet ─────────────────────────────────────────────────────
class _VariantPicker extends StatelessWidget {
  final HomeVariant current;
  final ValueChanged<HomeVariant> onSelect;

  const _VariantPicker({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final options = [
      (HomeVariant.editorial, 'Editorial', 'Revista — chef do mês em destaque'),
      (HomeVariant.grid, 'Grade', 'Cards 2-col com fotos'),
      (HomeVariant.immersive, 'Imersivo', 'Hero cinematográfico de tela cheia'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estilo da Home', style: AppText.cormorant(fontSize: 26)),
          const SizedBox(height: 16),
          for (final (v, label, desc) in options)
            GestureDetector(
              onTap: () => onSelect(v),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: current == v ? AppColors.terraSoft : AppColors.surfaceHi,
                  border: Border.all(color: current == v ? AppColors.terra : AppColors.line),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: AppText.manrope(fontWeight: FontWeight.w700)),
                          Text(desc, style: AppText.manrope(fontSize: 12.5, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    if (current == v)
                      const Icon(Icons.check_circle, color: AppColors.terra, size: 20),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Greeting ─────────────────────────────────────────────────────────────────
class _Greeting extends ConsumerWidget {
  final bool overlay;
  const _Greeting({this.overlay = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameAsync = ref.watch(currentUserNameProvider);
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Bom dia' : hour < 18 ? 'Boa tarde' : 'Boa noite';
    final fullName = nameAsync.valueOrNull ?? '';
    final firstName = fullName.isNotEmpty ? fullName.split(' ').first : '';
    final displayGreeting = firstName.isNotEmpty ? '$greeting, $firstName' : greeting;
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';

    return Row(
      children: [
        Expanded(
          child: Text(
            displayGreeting,
            style: AppText.manrope(
              fontSize: 13,
              color: overlay ? Colors.white70 : AppColors.muted,
            ),
          ),
        ),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(-0.4, -0.5),
              colors: [Color(0xFF3D2A1A), Color(0xFF2A1F15)],
            ),
            border: Border.all(color: overlay ? Colors.white24 : AppColors.line2),
          ),
          child: Center(
            child: Text(initial, style: AppText.cormorant(fontSize: 20)),
          ),
        ),
      ],
    );
  }
}

// ── Create Card ───────────────────────────────────────────────────────────────
class _CreateCard extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFC8462A), Color(0xFFA5371F)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0xCCC8462A),
              blurRadius: 30,
              offset: Offset(0, 14),
              spreadRadius: -14,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -20, top: -20,
              child: Container(
                width: 130, height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
              ),
            ),
            Positioned(
              right: 6, bottom: -30,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x2EFFFFFF)),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOVO PEDIDO',
                  style: AppText.spaceMono(
                    fontSize: 10,
                    color: Colors.white70,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Criar briefing\ndo seu evento',
                  style: AppText.cormorant(
                    fontSize: 26,
                    color: Colors.white,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Conte os detalhes e receba propostas em minutos.',
                  style: AppText.manrope(
                    fontSize: 13,
                    color: const Color(0xD1FFFFFF),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Começar',
                        style: AppText.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.terraDeep,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 17, color: AppColors.terraDeep),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Tab Bar ────────────────────────────────────────────────────────────
class _BottomTabBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTab;
  final VoidCallback onCreate;

  const _BottomTabBar({
    required this.activeIndex,
    required this.onTab,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.only(bottom: bottomPad > 0 ? bottomPad : 16, top: 12),
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
          _TabItem(icon: Icons.home, label: 'Descobrir', active: activeIndex == 0, onTap: () => onTab(0)),
          _TabItem(icon: Icons.description, label: 'Briefings', active: activeIndex == 1, onTap: () => onTab(1)),
          GestureDetector(
            onTap: onCreate,
            child: Container(
              width: 58, height: 58,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.terra,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xCCC8462A),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                    spreadRadius: -6,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
          _TabItem(icon: Icons.chat_bubble_outline, label: 'Mensagens', active: activeIndex == 2, onTap: () => onTab(2)),
          _TabItem(icon: Icons.person_outline, label: 'Perfil', active: activeIndex == 3, onTap: () => onTab(3)),
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
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 23, color: active ? AppColors.terra : AppColors.faint),
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

// ── HOME — EDITORIAL ──────────────────────────────────────────────────────────
class _HomeEditorial extends StatelessWidget {
  final VoidCallback onCreateBriefing;
  final VoidCallback onSwitchVariant;

  const _HomeEditorial({
    required this.onCreateBriefing,
    required this.onSwitchVariant,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: topPad + 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                const Expanded(child: _Greeting()),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onSwitchVariant,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: const Icon(Icons.tune, color: AppColors.muted, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: _CreateCard(onTap: onCreateBriefing),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

// ── HOME — GRID ───────────────────────────────────────────────────────────────
class _HomeGrid extends StatelessWidget {
  final VoidCallback onCreateBriefing;
  final VoidCallback onSwitchVariant;

  const _HomeGrid({
    required this.onCreateBriefing,
    required this.onSwitchVariant,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: topPad + 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                const Expanded(child: _Greeting()),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onSwitchVariant,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: const Icon(Icons.tune, color: AppColors.muted, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: _CreateCard(onTap: onCreateBriefing),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

// ── HOME — IMMERSIVE ──────────────────────────────────────────────────────────
class _HomeImmersive extends StatelessWidget {
  final VoidCallback onCreateBriefing;
  final VoidCallback onSwitchVariant;

  const _HomeImmersive({
    required this.onCreateBriefing,
    required this.onSwitchVariant,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 460,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppPlaceholder(
                  label: 'foto · ambiente do jantar',
                  hue: 18,
                  height: 460,
                  radius: 0,
                  icon: Icons.wine_bar,
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: [0.06, 0.45, 1.0],
                      colors: [
                        Color(0xFF15100B),
                        Color(0x3315100B),
                        Color(0x8C15100B),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: topPad + 8, left: 22, right: 22,
                  child: Row(
                    children: [
                      const Expanded(child: _Greeting(overlay: true)),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: onSwitchVariant,
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0x4D000000),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(Icons.tune, color: Colors.white70, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 22, right: 22, bottom: 26,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CHEF EM CASA',
                        style: AppText.spaceMono(fontSize: 10.5, letterSpacing: 2.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Uma experiência\ngastronômica\ninesquecível',
                        style: AppText.cormorant(fontSize: 40, color: Colors.white, height: 1.0),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Encontre o chef perfeito para tornar seu evento inesquecível.',
                        style: AppText.manrope(fontSize: 14, color: Colors.white70, height: 1.5),
                      ),
                      const SizedBox(height: 18),
                      GestureDetector(
                        onTap: onCreateBriefing,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.terra,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xCCC8462A),
                                blurRadius: 22,
                                offset: Offset(0, 8),
                                spreadRadius: -8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Criar meu briefing',
                                style: AppText.manrope(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 9),
                              const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
