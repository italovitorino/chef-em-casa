import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/negotiation/presentation/chef_negotiations_provider.dart';
import '../theme.dart';
import 'chef_negotiation_detail_screen.dart';

class ChefNegotiationListScreen extends ConsumerWidget {
  const ChefNegotiationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final negsAsync = ref.watch(chefNegotiationsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
              child: Text('Negociações', style: AppText.cormorant(fontSize: 28)),
            ),
            Expanded(
              child: negsAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.terra)),
                error: (_, _) => Center(
                    child: Text('Erro ao carregar',
                        style: AppText.manrope(color: AppColors.muted))),
                data: (negs) => negs.isEmpty
                    ? Center(
                        child: Text('Nenhuma negociação',
                            style: AppText.manrope(color: AppColors.muted)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 8),
                        itemCount: negs.length,
                        itemBuilder: (_, i) {
                          final n = negs[i];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChefNegotiationDetailScreen(
                                    negotiationId: n.id),
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                border: Border.all(color: AppColors.line),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Negociação #${n.id.substring(0, 8)}',
                                          style: AppText.manrope(
                                              fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _statusLabel(n.status),
                                          style: AppText.manrope(
                                              color: AppColors.muted,
                                              fontSize: 12),
                                        ),
                                        if (n.currentProposal != null)
                                          Text(
                                            n.currentProposal!.formattedAmount,
                                            style: AppText.manrope(
                                                color: AppColors.gold,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right,
                                      color: AppColors.faint),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String status) => switch (status) {
        'AWAITING_PROPOSAL' => 'Aguardando proposta',
        'PROPOSAL_SENT' => 'Proposta enviada',
        'PROPOSAL_ACCEPTED' => 'Proposta aceita',
        'PROPOSAL_REJECTED' => 'Proposta recusada',
        'REVISION_REQUESTED' => 'Revisão solicitada',
        'RESERVATION_CONFIRMED' => 'Reserva confirmada',
        'SERVICE_COMPLETED' => 'Serviço concluído',
        'CANCELLED' => 'Cancelada',
        _ => status,
      };
}
