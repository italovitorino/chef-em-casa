import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/negotiation/data/negotiation_dto.dart';
import '../features/negotiation/data/negotiation_repository.dart';
import '../features/negotiation/presentation/negotiation_provider.dart';
import '../theme.dart';

// ── StartNegotiationScreen ────────────────────────────────────────────────────
// Inicia negociação e redireciona para NegotiationDetailScreen.

class StartNegotiationScreen extends ConsumerWidget {
  final String briefingId;
  final String chefId;

  const StartNegotiationScreen({
    super.key,
    required this.briefingId,
    required this.chefId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _StartBody(briefingId: briefingId, chefId: chefId),
    );
  }
}

class _StartBody extends ConsumerStatefulWidget {
  final String briefingId;
  final String chefId;

  const _StartBody({required this.briefingId, required this.chefId});

  @override
  ConsumerState<_StartBody> createState() => _StartBodyState();
}

class _StartBodyState extends ConsumerState<_StartBody> {
  bool _loading = true;
  String? _error;
  String? _negotiationId;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final negotiation = await ref
          .read(negotiationRepositoryProvider)
          .start(widget.briefingId, widget.chefId);
      if (mounted) {
        setState(() {
          _loading = false;
          _negotiationId = negotiation.id;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().replaceFirst('AppException(null): ', '').replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.terra),
            SizedBox(height: 16),
            Text('Iniciando negociação…',
                style: TextStyle(color: AppColors.muted)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40, color: AppColors.terra),
              const SizedBox(height: 16),
              Text('Não foi possível iniciar a negociação',
                  style: AppText.cormorant(fontSize: 22),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(_error!,
                  style:
                      AppText.manrope(fontSize: 14, color: AppColors.muted),
                  textAlign: TextAlign.center),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 13),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.line2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('Voltar',
                      style: AppText.manrope(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Replace this screen with NegotiationDetailScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _negotiationId != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => NegotiationDetailScreen(
              negotiationId: _negotiationId!),
        ));
      }
    });

    return const SizedBox.shrink();
  }
}

// ── NegotiationDetailScreen ───────────────────────────────────────────────────

class NegotiationDetailScreen extends ConsumerWidget {
  final String negotiationId;

  const NegotiationDetailScreen({super.key, required this.negotiationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(negotiationProvider(negotiationId));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.terra),
        ),
        error: (e, _) => _ErrorBody(
          message: e.toString()
              .replaceFirst('AppException(null): ', '')
              .replaceFirst('Exception: ', ''),
          onRetry: () =>
              ref.read(negotiationProvider(negotiationId).notifier).refresh(),
          onBack: () => Navigator.of(context).pop(),
        ),
        data: (neg) => _NegotiationBody(
            negotiation: neg, negotiationId: negotiationId),
      ),
    );
  }
}

// ── Negotiation Body ──────────────────────────────────────────────────────────

class _NegotiationBody extends ConsumerWidget {
  final NegotiationResponse negotiation;
  final String negotiationId;

  const _NegotiationBody(
      {required this.negotiation, required this.negotiationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPad = MediaQuery.of(context).padding.top;

    return CustomScrollView(
      slivers: [
        // ── App bar ──────────────────────────────────────────────────
        SliverAppBar(
          backgroundColor: AppColors.bg,
          surfaceTintColor: Colors.transparent,
          pinned: true,
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.cream, size: 20),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Negociação',
                  style: AppText.cormorant(fontSize: 22, height: 1.1)),
              Text('com chef',
                  style: AppText.spaceMono(
                      fontSize: 9.5, color: AppColors.faint)),
            ],
          ),
        ),

        // ── Status ───────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(22, topPad > 0 ? 8 : 16, 22, 0),
            child: _NegotiationStatusCard(negotiation: negotiation),
          ),
        ),

        // ── Proposal ────────────────────────────────────────────────
        if (negotiation.currentProposal != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              child: _ProposalCard(proposal: negotiation.currentProposal!),
            ),
          ),

        // ── Actions ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
            child: _ActionButtons(
                negotiation: negotiation, negotiationId: negotiationId),
          ),
        ),

        // ── History ──────────────────────────────────────────────────
        if (negotiation.proposalHistory.length > 1) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 12),
              child: Text(
                'Histórico de propostas',
                style: AppText.cormorant(fontSize: 20),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final proposal = negotiation.proposalHistory[i];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                  child: _ProposalHistoryItem(
                    proposal: proposal,
                    index: negotiation.proposalHistory.length - i,
                  ),
                );
              },
              childCount: negotiation.proposalHistory.length,
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

// ── Status Card ───────────────────────────────────────────────────────────────

class _NegotiationStatusCard extends StatelessWidget {
  final NegotiationResponse negotiation;

  const _NegotiationStatusCard({required this.negotiation});

  @override
  Widget build(BuildContext context) {
    final (label, icon, color, desc) = switch (negotiation.status) {
      'AWAITING_PROPOSAL' => (
          'Aguardando proposta',
          Icons.hourglass_empty,
          AppColors.gold,
          'O chef ainda não enviou uma proposta. Assim que receber, você poderá analisá-la aqui.',
        ),
      'PROPOSAL_SENT' => (
          'Proposta recebida',
          Icons.description_outlined,
          AppColors.terra,
          'O chef enviou uma proposta. Analise os detalhes e escolha uma ação.',
        ),
      'RESERVATION_CONFIRMED' => (
          'Reserva confirmada!',
          Icons.check_circle_outline,
          AppColors.green,
          'Você aceitou a proposta. O serviço está confirmado.',
        ),
      'SERVICE_COMPLETED' => (
          'Serviço concluído',
          Icons.celebration_outlined,
          AppColors.muted,
          'O serviço foi concluído com sucesso.',
        ),
      'CANCELLED' => (
          'Negociação cancelada',
          Icons.cancel_outlined,
          AppColors.faint,
          'Esta negociação foi cancelada.',
        ),
      _ => (
          negotiation.status,
          Icons.info_outline,
          AppColors.muted,
          '',
        ),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppText.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: color)),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(desc,
                      style: AppText.manrope(
                          fontSize: 13, color: AppColors.muted, height: 1.5)),
                ],
                if (negotiation.updatedAt != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Atualizado ${_relativeDate(negotiation.updatedAt!)}',
                    style: AppText.spaceMono(
                        fontSize: 9.5, color: AppColors.faint),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Proposal Card ─────────────────────────────────────────────────────────────

class _ProposalCard extends StatelessWidget {
  final ProposalResponse proposal;

  const _ProposalCard({required this.proposal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Proposta do chef',
              style: AppText.cormorant(fontSize: 20)),
          const SizedBox(height: 14),
          // Amount
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.goldSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              proposal.formattedAmount,
              style: AppText.cormorant(
                  fontSize: 34, fontWeight: FontWeight.w700, color: AppColors.gold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 14),
          _ProposalRow(
            icon: Icons.description_outlined,
            label: 'Descrição',
            value: proposal.serviceDescription,
          ),
          if (proposal.validUntil != null) ...[
            const Divider(color: AppColors.line, height: 20, thickness: 1),
            _ProposalRow(
              icon: Icons.event_available_outlined,
              label: 'Válida até',
              value: _formatDate(proposal.validUntil!),
            ),
          ],
          if (proposal.notes != null && proposal.notes!.isNotEmpty) ...[
            const Divider(color: AppColors.line, height: 20, thickness: 1),
            _ProposalRow(
              icon: Icons.notes_outlined,
              label: 'Observações',
              value: proposal.notes!,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProposalRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProposalRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.gold),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppText.spaceMono(
                      fontSize: 9.5,
                      letterSpacing: 1.2,
                      color: AppColors.faint)),
              const SizedBox(height: 2),
              Text(value,
                  style:
                      AppText.manrope(fontSize: 14, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Action Buttons ────────────────────────────────────────────────────────────

class _ActionButtons extends ConsumerStatefulWidget {
  final NegotiationResponse negotiation;
  final String negotiationId;

  const _ActionButtons(
      {required this.negotiation, required this.negotiationId});

  @override
  ConsumerState<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends ConsumerState<_ActionButtons> {
  bool _loading = false;

  Future<void> _run(Future<void> Function() action, String errorCtx) async {
    setState(() => _loading = true);
    try {
      await action();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppColors.surface,
          content: Text(
            e.toString().replaceFirst('AppException(null): ', '').replaceFirst('Exception: ', ''),
            style: AppText.manrope(fontSize: 13, color: AppColors.cream),
          ),
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(negotiationProvider(widget.negotiationId).notifier);
    final neg = widget.negotiation;

    if (!neg.isActive) return const SizedBox.shrink();

    if (neg.isAwaitingProposal) {
      return _CancelButton(
        loading: _loading,
        onCancel: () => _run(notifier.cancel, 'cancelar'),
      );
    }

    if (neg.hasProposal) {
      return Column(
        children: [
          _PrimaryButton(
            label: 'Aceitar proposta',
            icon: Icons.check,
            color: AppColors.terra,
            loading: _loading,
            onTap: () => _run(notifier.accept, 'aceitar'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SecondaryButton(
                  label: 'Pedir revisão',
                  loading: _loading,
                  onTap: () => _run(notifier.requestRevision, 'revisão'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SecondaryButton(
                  label: 'Recusar',
                  loading: _loading,
                  onTap: () => _run(notifier.reject, 'rejeitar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _CancelButton(
            loading: _loading,
            onCancel: () => _run(notifier.cancel, 'cancelar'),
          ),
        ],
      );
    }

    if (neg.isConfirmed) {
      return _PrimaryButton(
        label: 'Marcar como concluído',
        icon: Icons.celebration_outlined,
        color: AppColors.terra,
        loading: _loading,
        onTap: () => _run(notifier.complete, 'concluir'),
      );
    }

    return const SizedBox.shrink();
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool loading;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(label,
                      style: AppText.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ],
              ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: AppText.manrope(
              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onCancel;

  const _CancelButton({required this.loading, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onCancel,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Cancelar negociação',
          style: AppText.manrope(
              fontSize: 13, color: AppColors.faint),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ── Proposal History Item ─────────────────────────────────────────────────────

class _ProposalHistoryItem extends StatelessWidget {
  final ProposalResponse proposal;
  final int index;

  const _ProposalHistoryItem({required this.proposal, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceHi,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            '#$index',
            style: AppText.spaceMono(fontSize: 12, color: AppColors.faint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(proposal.formattedAmount,
                    style: AppText.manrope(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                Text(proposal.serviceDescription,
                    style:
                        AppText.manrope(fontSize: 12, color: AppColors.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (proposal.sentAt != null)
            Text(
              _relativeDate(proposal.sentAt!),
              style: AppText.spaceMono(fontSize: 9.5, color: AppColors.faint),
            ),
        ],
      ),
    );
  }
}

// ── Error Body ────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const _ErrorBody(
      {required this.message, required this.onRetry, required this.onBack});

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
            Text(message,
                style: AppText.manrope(
                    fontSize: 14, color: AppColors.muted, height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 22),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.line2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Voltar',
                        style: AppText.manrope(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.terra,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Tentar novamente',
                        style: AppText.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
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

// ── Helpers ───────────────────────────────────────────────────────────────────

String _formatDate(String isoDate) {
  final date = DateTime.tryParse(isoDate);
  if (date == null) return isoDate;
  const months = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _relativeDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inSeconds < 60) return 'agora mesmo';
  if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'há ${diff.inHours}h';
  if (diff.inDays == 1) return 'ontem';
  return 'há ${diff.inDays} dias';
}
