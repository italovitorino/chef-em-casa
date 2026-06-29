import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/format_utils.dart';
import '../features/briefing/data/briefing_dto.dart';
import '../features/briefing/data/briefing_repository.dart';
import '../theme.dart';

class ChefBriefingDetailScreen extends ConsumerStatefulWidget {
  final BriefingListItem briefing;

  const ChefBriefingDetailScreen({super.key, required this.briefing});

  @override
  ConsumerState<ChefBriefingDetailScreen> createState() =>
      _ChefBriefingDetailScreenState();
}

class _ChefBriefingDetailScreenState
    extends ConsumerState<ChefBriefingDetailScreen> {
  bool _loading = false;
  bool _done = false;

  Future<void> _expressInterest() async {
    setState(() => _loading = true);
    try {
      await ref.read(briefingRepositoryProvider).expressInterest(widget.briefing.id);
      setState(() => _done = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Interesse expressado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.briefing;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.cream),
        title: Text('Detalhes do pedido', style: AppText.cormorant(fontSize: 20)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(b.eventType, style: AppText.cormorant(fontSize: 28)),
              const SizedBox(height: 8),
              _InfoRow(label: 'Data', value: formatDate(b.eventDate)),
              _InfoRow(label: 'Convidados', value: '${b.numberOfGuests} pessoas'),
              _InfoRow(label: 'Duração', value: '${b.hours}h'),
              if (b.city != null) _InfoRow(label: 'Cidade', value: b.city!),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: (_loading || _done) ? null : _expressInterest,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.star_outline),
                label: Text(_done ? 'Interesse expressado' : 'Expressar interesse'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terra,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text('$label: ', style: AppText.manrope(color: AppColors.muted, fontSize: 14)),
          Expanded(
            child: Text(value,
                style: AppText.manrope(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
