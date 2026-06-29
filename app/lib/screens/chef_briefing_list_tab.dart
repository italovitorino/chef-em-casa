import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/briefing/presentation/briefings_list_provider.dart';
import '../theme.dart';
import 'chef_briefing_detail_screen.dart';

class ChefBriefingListTab extends ConsumerWidget {
  const ChefBriefingListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final briefingsAsync = ref.watch(briefingsListProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
              child: Text('Pedidos disponíveis',
                  style: AppText.cormorant(fontSize: 28)),
            ),
            Expanded(
              child: briefingsAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.terra)),
                error: (_, _) => Center(
                    child: Text('Erro ao carregar',
                        style: AppText.manrope(color: AppColors.muted))),
                data: (briefings) {
                  final open = briefings.where((b) => b.isActive).toList();
                  return open.isEmpty
                      ? Center(
                          child: Text('Nenhum pedido disponível',
                              style: AppText.manrope(color: AppColors.muted)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 8),
                          itemCount: open.length,
                          itemBuilder: (_, i) {
                            final b = open[i];
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ChefBriefingDetailScreen(briefing: b),
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
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(b.eventType,
                                              style:
                                                  AppText.cormorant(fontSize: 18)),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${b.eventDate}  ·  ${b.numberOfGuests} pessoas',
                                            style: AppText.manrope(
                                                color: AppColors.muted,
                                                fontSize: 13),
                                          ),
                                          if (b.city != null)
                                            Text(b.city!,
                                                style: AppText.manrope(
                                                    color: AppColors.muted,
                                                    fontSize: 12)),
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
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
