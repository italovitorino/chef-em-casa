import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data.dart';
import '../features/briefing/data/briefing_dto.dart';
import '../features/briefing/presentation/briefing_detail_provider.dart';
import '../features/negotiation/data/negotiation_dto.dart';
import '../theme.dart';
import 'negotiation_detail_screen.dart';

class BriefingDetailScreen extends ConsumerWidget {
  final String briefingId;

  const BriefingDetailScreen({super.key, required this.briefingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(briefingDetailProvider(briefingId));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.terra),
        ),
        error: (e, _) => _ErrorBody(
          message: e is Exception ? e.toString() : 'Erro desconhecido',
          onRetry: () =>
              ref.read(briefingDetailProvider(briefingId).notifier).refresh(),
        ),
        data: (state) => _Body(
          briefing: state.briefing,
          negotiations: state.negotiations,
          briefingId: briefingId,
        ),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _Body extends ConsumerWidget {
  final BriefingDetailResponse briefing;
  final List<NegotiationListItem> negotiations;
  final String briefingId;

  const _Body({
    required this.briefing,
    required this.negotiations,
    required this.briefingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPad = MediaQuery.of(context).padding.top;
    final et =
        kEventTypes.where((e) => e.apiKey == briefing.eventType).firstOrNull;

    return CustomScrollView(
      slivers: [
        // ── App bar ──────────────────────────────────────────────────
        SliverAppBar(
          backgroundColor: AppColors.bg,
          surfaceTintColor: Colors.transparent,
          pinned: true,
          expandedHeight: 180,
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.cream, size: 20),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.surface, AppColors.bg],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.fromLTRB(22, topPad + 56, 22, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalhes do pedido',
                          style: AppText.spaceMono(
                            fontSize: 10,
                            letterSpacing: 2,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          et?.label ?? 'Evento',
                          style: AppText.cormorant(fontSize: 30, height: 1.1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Status badge ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
            child: _StatusBadge(isActive: briefing.isActive),
          ),
        ),

        // ── Info section ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle('Informações do evento'),
                const SizedBox(height: 12),
                _InfoCard(children: [
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Data',
                    value: _formatDate(briefing.eventDate),
                  ),
                  _InfoRow(
                    icon: Icons.people_outline,
                    label: 'Convidados',
                    value: '${briefing.numberOfGuests} pessoas',
                  ),
                  _InfoRow(
                    icon: Icons.schedule_outlined,
                    label: 'Duração',
                    value: '${briefing.hours}h',
                  ),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Local',
                    value:
                        '${briefing.street}, ${briefing.number} – ${briefing.city}/${briefing.state}',
                  ),
                  if (briefing.notes != null && briefing.notes!.isNotEmpty)
                    _InfoRow(
                      icon: Icons.notes_outlined,
                      label: 'Observações',
                      value: briefing.notes!,
                    ),
                ]),
              ],
            ),
          ),
        ),

        // ── Interests section ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
            child: _SectionTitle(
              briefing.interests.isEmpty
                  ? 'Nenhum chef interessado ainda'
                  : 'Chefs interessados (${briefing.interests.length})',
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        if (briefing.interests.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
              child: Text(
                'Aguardando o interesse dos chefs da sua região…',
                style: AppText.manrope(
                    fontSize: 14, color: AppColors.muted, height: 1.5),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final interest = briefing.interests[i];
                final existing = negotiations
                    .where((n) => n.chefId == interest.chefId)
                    .firstOrNull;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                  child: _InterestCard(
                    interest: interest,
                    existingNegotiation: existing,
                    canAct: briefing.isActive,
                    onNegotiate: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => StartNegotiationScreen(
                          briefingId: briefingId,
                          chefId: interest.chefId,
                        ),
                      ));
                    },
                    onOpenNegotiation: (id) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => NegotiationDetailScreen(
                          negotiationId: id,
                        ),
                      ));
                    },
                  ),
                );
              },
              childCount: briefing.interests.length,
            ),
          ),

        // ── Actions ─────────────────────────────────────────────────
        if (briefing.isActive)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 32, 22, 16),
              child: _CloseBriefingButton(briefingId: briefingId),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

// ── Interest Card ─────────────────────────────────────────────────────────────

class _InterestCard extends StatelessWidget {
  final ChefInterestItem interest;
  final NegotiationListItem? existingNegotiation;
  final bool canAct;
  final VoidCallback onNegotiate;
  final void Function(String negotiationId) onOpenNegotiation;

  const _InterestCard({
    required this.interest,
    required this.existingNegotiation,
    required this.canAct,
    required this.onNegotiate,
    required this.onOpenNegotiation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.goldSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.restaurant,
                    size: 20, color: AppColors.gold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chef',
                      style: AppText.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _relativeDate(interest.expressedAt),
                      style: AppText.spaceMono(
                          fontSize: 10, color: AppColors.faint),
                    ),
                  ],
                ),
              ),
              if (existingNegotiation != null)
                _NegotiationStatusBadge(status: existingNegotiation!.status),
            ],
          ),
          if (interest.message != null && interest.message!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bg2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                interest.message!,
                style: AppText.manrope(
                    fontSize: 13, color: AppColors.muted, height: 1.5),
              ),
            ),
          ],
          if (canAct || existingNegotiation != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: existingNegotiation != null
                    ? () => onOpenNegotiation(existingNegotiation!.id)
                    : onNegotiate,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: existingNegotiation != null
                        ? AppColors.surfaceHi
                        : AppColors.terra,
                    border: existingNegotiation != null
                        ? Border.all(color: AppColors.line2)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        existingNegotiation != null
                            ? Icons.open_in_new
                            : Icons.handshake_outlined,
                        size: 16,
                        color: existingNegotiation != null
                            ? AppColors.muted
                            : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        existingNegotiation != null
                            ? 'Ver negociação'
                            : 'Negociar com este chef',
                        style: AppText.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: existingNegotiation != null
                              ? AppColors.muted
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Negotiation Status Badge ───────────────────────────────────────────────────

class _NegotiationStatusBadge extends StatelessWidget {
  final String status;

  const _NegotiationStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'AWAITING_PROPOSAL' => ('Aguardando proposta', AppColors.gold),
      'PROPOSAL_SENT' => ('Proposta recebida', AppColors.terra),
      'RESERVATION_CONFIRMED' => ('Reserva confirmada', AppColors.green),
      'SERVICE_COMPLETED' => ('Concluído', AppColors.muted),
      'CANCELLED' => ('Cancelada', AppColors.faint),
      _ => (status, AppColors.faint),
    };

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
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppText.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Close Briefing Button ─────────────────────────────────────────────────────

class _CloseBriefingButton extends ConsumerStatefulWidget {
  final String briefingId;

  const _CloseBriefingButton({required this.briefingId});

  @override
  ConsumerState<_CloseBriefingButton> createState() =>
      _CloseBriefingButtonState();
}

class _CloseBriefingButtonState extends ConsumerState<_CloseBriefingButton> {
  bool _loading = false;

  Future<void> _close() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Fechar briefing',
            style: AppText.cormorant(fontSize: 22)),
        content: Text(
          'Tem certeza que deseja fechar este briefing? Esta ação não pode ser desfeita.',
          style: AppText.manrope(fontSize: 14, color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar',
                style: AppText.manrope(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Fechar',
                style: AppText.manrope(color: AppColors.terra)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(briefingDetailProvider(widget.briefingId).notifier)
          .closeBriefing();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _close,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: _loading
            ? const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: AppColors.muted),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.close, size: 16, color: AppColors.muted),
                  const SizedBox(width: 8),
                  Text(
                    'Fechar briefing',
                    style: AppText.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.goldSoft : AppColors.surfaceHi,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? AppColors.gold : AppColors.faint,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Ativo' : 'Encerrado',
            style: AppText.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isActive ? AppColors.gold : AppColors.faint,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(
                  color: AppColors.line, height: 1, thickness: 1,
                  indent: 52, endIndent: 0),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.gold),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppText.spaceMono(
                      fontSize: 9.5, letterSpacing: 1.2, color: AppColors.faint),
                ),
                const SizedBox(height: 2),
                Text(value,
                    style: AppText.manrope(fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppText.cormorant(fontSize: 22, height: 1.1),
    );
  }
}

// ── Error Body ────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

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
            Text('Não foi possível carregar',
                style: AppText.cormorant(fontSize: 22),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Verifique sua conexão e tente novamente.',
              style: AppText.manrope(
                  fontSize: 14, color: AppColors.muted, height: 1.5),
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
                child: Text('Tentar novamente',
                    style: AppText.manrope(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _formatDate(String isoDate) {
  final date = DateTime.tryParse(isoDate);
  if (date == null) return isoDate;
  const months = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];
  return '${date.day} de ${months[date.month - 1]} de ${date.year}';
}

String _relativeDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'há ${diff.inHours}h';
  if (diff.inDays == 1) return 'ontem';
  if (diff.inDays < 7) return 'há ${diff.inDays} dias';
  return 'há ${(diff.inDays / 7).floor()} semanas';
}
