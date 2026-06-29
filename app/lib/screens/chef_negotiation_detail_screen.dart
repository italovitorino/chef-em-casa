import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/negotiation/data/negotiation_dto.dart';
import '../features/negotiation/data/negotiation_repository.dart';
import '../features/negotiation/presentation/chef_negotiations_provider.dart';
import '../theme.dart';
import 'chat_screen.dart';

class ChefNegotiationDetailScreen extends ConsumerStatefulWidget {
  final String negotiationId;

  const ChefNegotiationDetailScreen({super.key, required this.negotiationId});

  @override
  ConsumerState<ChefNegotiationDetailScreen> createState() =>
      _ChefNegotiationDetailScreenState();
}

class _ChefNegotiationDetailScreenState
    extends ConsumerState<ChefNegotiationDetailScreen> {
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _validCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _validCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
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
      await ref.read(negotiationRepositoryProvider).submitProposal(
            widget.negotiationId,
            SubmitProposalRequest(
              totalAmount: amount,
              serviceDescription: _descCtrl.text.trim(),
              validUntil: _validCtrl.text.trim().isEmpty
                  ? null
                  : _validCtrl.text.trim(),
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
                builder: (_) =>
                    ChatScreen(negotiationId: widget.negotiationId),
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
              Text('Enviar proposta', style: AppText.cormorant(fontSize: 24)),
              const SizedBox(height: 20),
              _Field(
                  label: r'Valor total (R$)',
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 14),
              _Field(
                  label: 'Descrição do serviço',
                  controller: _descCtrl,
                  maxLines: 3),
              const SizedBox(height: 14),
              _Field(
                  label: 'Válido até (AAAA-MM-DD)',
                  controller: _validCtrl),
              const SizedBox(height: 14),
              _Field(
                  label: 'Observações (opcional)',
                  controller: _notesCtrl,
                  maxLines: 2),
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
                        style: AppText.manrope(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboardType;

  const _Field({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
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
          ),
        ),
      ],
    );
  }
}
