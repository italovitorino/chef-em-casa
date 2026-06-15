import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data.dart';
import '../features/briefing/data/briefing_dto.dart';
import '../features/briefing/presentation/briefings_list_provider.dart';
import '../theme.dart';
import 'briefing_detail_screen.dart';

enum _Tab { active, concluded, expired }

class BriefingsScreen extends ConsumerStatefulWidget {
  final VoidCallback onCreate;

  const BriefingsScreen({super.key, required this.onCreate});

  @override
  ConsumerState<BriefingsScreen> createState() => _BriefingsScreenState();
}

class _BriefingsScreenState extends ConsumerState<BriefingsScreen> {
  _Tab _tab = _Tab.active;

  List<BriefingListItem> _filter(List<BriefingListItem> all) => switch (_tab) {
        _Tab.active => all.where((b) => b.isActive).toList(),
        _Tab.concluded => all.where((b) => b.isConcluded).toList(),
        _Tab.expired => all.where((b) => b.isExpiredAuto).toList(),
      };

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final async = ref.watch(briefingsListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: topPad + 16),
        // ── header ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seus pedidos',
                      style: AppText.spaceMono(
                        fontSize: 10.5,
                        letterSpacing: 2,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Meus briefings',
                      style: AppText.cormorant(fontSize: 32, height: 1.0),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: widget.onCreate,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.terra,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xCCC8462A),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                        spreadRadius: -8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // ── tabs ────────────────────────────────────────────────────
        async.when(
          loading: () => _buildTabRow(null),
          error: (e, _) => _buildTabRow(null),
          data: (all) => _buildTabRow(all),
        ),
        const SizedBox(height: 4),
        // ── content ─────────────────────────────────────────────────
        Expanded(
          child: async.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.terra),
            ),
            error: (e, _) => _ErrorState(
              onRetry: () =>
                  ref.read(briefingsListProvider.notifier).refresh(),
            ),
            data: (all) {
              final list = _filter(all);
              if (list.isEmpty) {
                return _EmptyState(tab: _tab, onCreate: widget.onCreate);
              }
              return RefreshIndicator(
                color: AppColors.terra,
                backgroundColor: AppColors.surface,
                onRefresh: () =>
                    ref.read(briefingsListProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 120),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            BriefingDetailScreen(briefingId: list[i].id),
                      ),
                    ),
                    child: _BriefingCard(b: list[i]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabRow(List<BriefingListItem>? all) {
    final activeCount = all?.where((b) => b.isActive).length;
    final concludedCount = all?.where((b) => b.isConcluded).length;
    final expiredCount = all?.where((b) => b.isExpiredAuto).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          _TabPill(
            label: 'Ativos',
            count: activeCount,
            active: _tab == _Tab.active,
            onTap: () => setState(() => _tab = _Tab.active),
          ),
          const SizedBox(width: 8),
          _TabPill(
            label: 'Concluídos',
            count: concludedCount,
            active: _tab == _Tab.concluded,
            onTap: () => setState(() => _tab = _Tab.concluded),
          ),
          const SizedBox(width: 8),
          _TabPill(
            label: 'Encerrados',
            count: expiredCount,
            active: _tab == _Tab.expired,
            onTap: () => setState(() => _tab = _Tab.expired),
          ),
        ],
      ),
    );
  }
}

// ── Tab Pill ─────────────────────────────────────────────────────────────────

class _TabPill extends StatelessWidget {
  final String label;
  final int? count;
  final bool active;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.cream : Colors.transparent,
          border: Border.all(
            color: active ? AppColors.cream : AppColors.line2,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppText.manrope(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: active
                    ? const Color(0xFF231A0F)
                    : AppColors.muted,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 7),
              Text(
                '$count',
                style: AppText.spaceMono(
                  fontSize: 11,
                  color: active
                      ? const Color(0x99231A0F)
                      : AppColors.faint,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Briefing Card ─────────────────────────────────────────────────────────────

class _BriefingCard extends StatelessWidget {
  final BriefingListItem b;

  const _BriefingCard({required this.b});

  @override
  Widget build(BuildContext context) {
    final et = kEventTypes
        .where((e) => e.apiKey == b.eventType)
        .firstOrNull;
    final isDone = b.isConcluded || b.isExpiredAuto;

    return Opacity(
      opacity: isDone ? 0.82 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── top row: icon + name + status ──────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.goldSoft,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    et?.icon ?? Icons.event,
                    size: 23,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        et?.label ?? 'Evento',
                        style: AppText.cormorant(
                          fontSize: 22,
                          height: 1.15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      if (b.createdAt != null)
                        Text(
                          'criado ${_relativeDate(b.createdAt!)}',
                          style: AppText.spaceMono(
                            fontSize: 10.5,
                            color: AppColors.faint,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusPill(b: b),
              ],
            ),
            const SizedBox(height: 15),
            // ── meta row ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _MetaItem(
                    icon: Icons.calendar_today_outlined,
                    label: _formatEventDate(b.eventDate),
                  ),
                  _MetaItem(
                    icon: Icons.people_outline,
                    label: '${b.numberOfGuests} convidados',
                  ),
                  _MetaItem(
                    icon: Icons.schedule_outlined,
                    label: '${b.hours}h',
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.line, height: 1, thickness: 1),
            const SizedBox(height: 14),
            // ── footer: interests ───────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (b.interestCount > 0)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.goldSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.restaurant,
                                size: 13, color: AppColors.gold),
                            const SizedBox(width: 5),
                            Text(
                              '${b.interestCount} ${b.interestCount == 1 ? 'chef interessado' : 'chefs interessados'}',
                              style: AppText.manrope(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.cream,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Aguardando os primeiros chefs…',
                    style: AppText.manrope(
                      fontSize: 12.5,
                      color: AppColors.muted,
                    ),
                  ),
                const Icon(Icons.chevron_right,
                    size: 20, color: AppColors.faint),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status Pill ───────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final BriefingListItem b;

  const _StatusPill({required this.b});

  @override
  Widget build(BuildContext context) {
    final (label, color) = b.isActive
        ? ('Ativo', AppColors.gold)
        : b.isConcluded
            ? ('Concluído', AppColors.muted)
            : ('Encerrado', AppColors.faint);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x0FF4EFE6),
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppText.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Meta Item ─────────────────────────────────────────────────────────────────

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.gold),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppText.manrope(
            fontSize: 12.5,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final _Tab tab;
  final VoidCallback onCreate;

  const _EmptyState({required this.tab, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final isPast = tab != _Tab.active;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.line2),
              ),
              child: Icon(
                isPast ? Icons.check_circle_outline : Icons.description_outlined,
                size: 32,
                color: AppColors.faint,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              isPast ? 'Nada por aqui ainda' : 'Nenhum briefing ativo',
              style: AppText.cormorant(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isPast
                  ? 'Seus eventos ${tab == _Tab.concluded ? 'concluídos' : 'encerrados'} aparecerão aqui.'
                  : 'Crie um briefing e receba o interesse de chefs da sua região.',
              style: AppText.manrope(
                fontSize: 14,
                color: AppColors.muted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isPast) ...[
              const SizedBox(height: 22),
              GestureDetector(
                onTap: onCreate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.terra,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Criar briefing',
                        style: AppText.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 40, color: AppColors.faint),
            const SizedBox(height: 16),
            Text(
              'Não foi possível carregar',
              style: AppText.cormorant(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Verifique sua conexão e tente novamente.',
              style:
                  AppText.manrope(fontSize: 14, color: AppColors.muted, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.line2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Tentar novamente',
                  style: AppText.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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

// ── Helpers ───────────────────────────────────────────────────────────────────

String _formatEventDate(String isoDate) {
  final date = DateTime.tryParse(isoDate);
  if (date == null) return isoDate;
  const months = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];
  return '${date.day} ${months[date.month - 1]}';
}

String _relativeDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'há ${diff.inHours}h';
  if (diff.inDays == 1) return 'ontem';
  if (diff.inDays < 7) return 'há ${diff.inDays} dias';
  if (diff.inDays < 30) return 'há ${(diff.inDays / 7).floor()} sem.';
  return 'há ${(diff.inDays / 30).floor()} meses';
}
