import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/format_utils.dart';
import '../features/negotiation/data/negotiation_dto.dart';
import '../features/negotiation/presentation/chef_negotiations_provider.dart';
import '../theme.dart';
import 'chef_negotiation_detail_screen.dart';

class ChefNegotiationListScreen extends ConsumerWidget {
  const ChefNegotiationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final negsAsync = ref.watch(chefNegotiationsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                child: Text('Negociações',
                    style: AppText.cormorant(fontSize: 28)),
              ),
              TabBar(
                labelColor: AppColors.cream,
                unselectedLabelColor: AppColors.faint,
                indicatorColor: AppColors.terra,
                dividerColor: AppColors.line,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle:
                    AppText.manrope(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: AppText.manrope(fontSize: 13),
                tabs: const [
                  Tab(text: 'Em aberto'),
                  Tab(text: 'Concluídas'),
                ],
              ),
              Expanded(
                child: negsAsync.when(
                  loading: () => const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.terra)),
                  error: (e, _) => Center(
                      child: Text('Erro ao carregar',
                          style: AppText.manrope(color: AppColors.muted))),
                  data: (negs) {
                    final open = negs.where((n) => n.isActive).toList();
                    final closed = negs
                        .where((n) => n.isCompleted || n.isCancelled)
                        .toList();
                    return TabBarView(
                      children: [
                        _NegList(negs: open),
                        _NegList(negs: closed),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NegList extends StatelessWidget {
  final List<NegotiationResponse> negs;

  const _NegList({required this.negs});

  @override
  Widget build(BuildContext context) {
    if (negs.isEmpty) {
      return Center(
        child: Text('Nenhuma negociação',
            style: AppText.manrope(color: AppColors.muted)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 100),
      itemCount: negs.length,
      itemBuilder: (_, i) {
        final n = negs[i];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChefNegotiationDetailScreen(negotiation: n),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Negociação #${n.id.substring(0, 8)}',
                        style: AppText.manrope(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _statusLabel(n.status),
                        style: AppText.manrope(
                            color: AppColors.muted, fontSize: 12),
                      ),
                      if (n.currentProposal != null)
                        Text(
                          n.currentProposal!.formattedAmount,
                          style: AppText.manrope(
                              color: AppColors.gold,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                      if (n.createdAt != null)
                        Text(
                          formatDate(n.createdAt!.toIso8601String()),
                          style: AppText.manrope(
                              color: AppColors.faint, fontSize: 11),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.faint),
              ],
            ),
          ),
        );
      },
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
