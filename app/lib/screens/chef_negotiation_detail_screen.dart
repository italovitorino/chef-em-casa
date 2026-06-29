import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/format_utils.dart';
import '../features/negotiation/data/negotiation_dto.dart';
import '../features/negotiation/data/negotiation_repository.dart';
import '../features/negotiation/presentation/chef_negotiations_provider.dart';
import '../theme.dart';
import 'chat_screen.dart';

class ChefNegotiationDetailScreen extends ConsumerStatefulWidget {
  final NegotiationResponse negotiation;

  const ChefNegotiationDetailScreen({super.key, required this.negotiation});

  @override
  ConsumerState<ChefNegotiationDetailScreen> createState() =>
      _ChefNegotiationDetailScreenState();
}

class _ChefNegotiationDetailScreenState
    extends ConsumerState<ChefNegotiationDetailScreen> {
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _validUntil;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.negotiation.currentProposal;
    if (p != null) {
      _amountCtrl.text = p.totalAmount.toStringAsFixed(2);
      _descCtrl.text = p.serviceDescription;
      _notesCtrl.text = p.notes ?? '';
      if (p.validUntil != null && p.validUntil!.isNotEmpty) {
        _validUntil = DateTime.tryParse(p.validUntil!);
      }
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _validUntil ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.terra,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _validUntil = picked);
  }

  Future<void> _submitProposal() async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    if (amount == null || _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha valor e descrição')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      String? validUntilIso;
      if (_validUntil != null) {
        validUntilIso =
            '${_validUntil!.year.toString().padLeft(4, '0')}-'
            '${_validUntil!.month.toString().padLeft(2, '0')}-'
            '${_validUntil!.day.toString().padLeft(2, '0')}';
      }
      await ref.read(negotiationRepositoryProvider).submitProposal(
            widget.negotiation.id,
            SubmitProposalRequest(
              totalAmount: amount,
              serviceDescription: _descCtrl.text.trim(),
              validUntil: validUntilIso,
              notes: _notesCtrl.text.trim().isEmpty
                  ? null
                  : _notesCtrl.text.trim(),
            ),
          );
      await ref.read(chefNegotiationsProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proposta enviada com sucesso!')),
        );
        Navigator.pop(context);
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
    final n = widget.negotiation;
    final canSubmit = n.isActive;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.cream),
        title: Text('Negociação', style: AppText.cormorant(fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: AppColors.terra),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(negotiationId: n.id),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusBanner(status: n.status),
              const SizedBox(height: 20),
              Text('Proposta', style: AppText.cormorant(fontSize: 24)),
              const SizedBox(height: 20),
              _Field(
                label: r'Valor total (R$)',
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                enabled: canSubmit,
              ),
              const SizedBox(height: 14),
              _Field(
                label: 'Descrição do serviço',
                controller: _descCtrl,
                maxLines: 3,
                enabled: canSubmit,
              ),
              const SizedBox(height: 14),
              _DateField(
                label: 'Válido até',
                selectedDate: _validUntil,
                onTap: canSubmit ? _pickDate : null,
              ),
              const SizedBox(height: 14),
              _Field(
                label: 'Observações (opcional)',
                controller: _notesCtrl,
                maxLines: 2,
                enabled: canSubmit,
              ),
              if (canSubmit) ...[
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _loading ? null : _submitProposal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.terra,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('Enviar proposta',
                          style:
                              AppText.manrope(fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'AWAITING_PROPOSAL' => ('Aguardando proposta', AppColors.muted),
      'PROPOSAL_SENT' => ('Proposta enviada', AppColors.gold),
      'PROPOSAL_ACCEPTED' =>
        ('Proposta aceita', const Color(0xFF4CAF50)),
      'PROPOSAL_REJECTED' => ('Proposta recusada', AppColors.terra),
      'REVISION_REQUESTED' =>
        ('Revisão solicitada', const Color(0xFFFF9800)),
      'RESERVATION_CONFIRMED' =>
        ('Reserva confirmada', const Color(0xFF4CAF50)),
      'SERVICE_COMPLETED' => ('Serviço concluído', AppColors.muted),
      'CANCELLED' => ('Cancelada', AppColors.terra),
      _ => (status, AppColors.muted),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: AppText.manrope(
              color: color, fontWeight: FontWeight.w700, fontSize: 13)),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final VoidCallback? onTap;

  const _DateField({
    required this.label,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final display = selectedDate != null
        ? formatDate(selectedDate!.toIso8601String())
        : 'Selecionar data';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppText.manrope(fontSize: 13, color: AppColors.muted)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    display,
                    style: AppText.manrope(
                      color: selectedDate != null
                          ? AppColors.cream
                          : AppColors.muted,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: onTap != null ? AppColors.terra : AppColors.faint,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboardType;
  final bool enabled;

  const _Field({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppText.manrope(fontSize: 13, color: AppColors.muted)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          enabled: enabled,
          style: AppText.manrope(color: AppColors.cream),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: AppColors.line.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }
}
