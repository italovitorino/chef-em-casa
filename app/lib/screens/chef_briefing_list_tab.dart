import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/format_utils.dart';
import '../data.dart';
import '../features/briefing/presentation/briefings_list_provider.dart';
import '../features/auth/presentation/user_provider.dart';
import '../theme.dart';
import 'chef_briefing_detail_screen.dart';

class ChefBriefingListTab extends ConsumerStatefulWidget {
  const ChefBriefingListTab({super.key});

  @override
  ConsumerState<ChefBriefingListTab> createState() =>
      _ChefBriefingListTabState();
}

class _ChefBriefingListTabState extends ConsumerState<ChefBriefingListTab> {
  String? _filterEventType;
  DateTimeRange? _filterDateRange;

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2028),
      initialDateRange: _filterDateRange,
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
    if (picked != null) setState(() => _filterDateRange = picked);
  }

  bool _passesDateFilter(String eventDate) {
    if (_filterDateRange == null || eventDate.isEmpty) return true;
    final date = DateTime.tryParse(eventDate.split('T').first);
    if (date == null) return true;
    return !date.isBefore(_filterDateRange!.start) &&
        !date.isAfter(_filterDateRange!.end);
  }

  @override
  Widget build(BuildContext context) {
    final briefingsAsync = ref.watch(briefingsListProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ChefGreeting(),
                  const SizedBox(height: 12),
                  Text('Pedidos disponíveis',
                      style: AppText.cormorant(fontSize: 28)),
                  const SizedBox(height: 14),
                  _FilterRow(
                    selectedType: _filterEventType,
                    dateRange: _filterDateRange,
                    onTypeSelected: (t) =>
                        setState(() => _filterEventType = t),
                    onDateTap: _pickDateRange,
                    onClearDate: () =>
                        setState(() => _filterDateRange = null),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Expanded(
              child: briefingsAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.terra)),
                error: (e, _) => Center(
                    child: Text('Erro ao carregar',
                        style: AppText.manrope(color: AppColors.muted))),
                data: (briefings) {
                  final filtered = briefings
                      .where((b) => b.isActive)
                      .where((b) =>
                          _filterEventType == null ||
                          b.eventType == _filterEventType)
                      .where((b) => _passesDateFilter(b.eventDate))
                      .toList();
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text('Nenhum pedido disponível',
                          style: AppText.manrope(color: AppColors.muted)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(22, 4, 22, 100),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final b = filtered[i];
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
                                    Text(
                                      _eventTypeLabel(b.eventType),
                                      style: AppText.cormorant(fontSize: 18),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${formatDate(b.eventDate)}  ·  ${b.numberOfGuests} pessoas',
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

  String _eventTypeLabel(String apiKey) {
    try {
      return kEventTypes.firstWhere((e) => e.apiKey == apiKey).label;
    } catch (_) {
      return apiKey;
    }
  }
}

class _ChefGreeting extends ConsumerWidget {
  const _ChefGreeting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameAsync = ref.watch(currentUserNameProvider);
    final hour = DateTime.now().hour;
    final greeting =
        hour < 12 ? 'Bom dia' : hour < 18 ? 'Boa tarde' : 'Boa noite';
    final fullName = nameAsync.valueOrNull ?? '';
    final firstName = fullName.isNotEmpty ? fullName.split(' ').first : '';
    final displayGreeting =
        firstName.isNotEmpty ? '$greeting, $firstName' : greeting;
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';

    return Row(
      children: [
        Expanded(
          child: Text(
            displayGreeting,
            style: AppText.manrope(fontSize: 13, color: AppColors.muted),
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
            border: Border.all(color: AppColors.line2),
          ),
          child: Center(
            child: Text(initial, style: AppText.cormorant(fontSize: 20)),
          ),
        ),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  final String? selectedType;
  final DateTimeRange? dateRange;
  final ValueChanged<String?> onTypeSelected;
  final VoidCallback onDateTap;
  final VoidCallback onClearDate;

  const _FilterRow({
    required this.selectedType,
    required this.dateRange,
    required this.onTypeSelected,
    required this.onDateTap,
    required this.onClearDate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _DateChip(
            dateRange: dateRange,
            onTap: onDateTap,
            onClear: onClearDate,
          ),
          const SizedBox(width: 8),
          for (final e in kEventTypes) ...[
            _TypeChip(
              label: e.label,
              selected: selectedType == e.apiKey,
              onTap: () =>
                  onTypeSelected(selectedType == e.apiKey ? null : e.apiKey),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.terra : AppColors.surface,
          border:
              Border.all(color: selected ? AppColors.terra : AppColors.line),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppText.manrope(
            fontSize: 12,
            color: selected ? Colors.white : AppColors.muted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final DateTimeRange? dateRange;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateChip({
    required this.dateRange,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = dateRange != null;
    final label = isActive
        ? '${formatDate(dateRange!.start.toIso8601String())} – ${formatDate(dateRange!.end.toIso8601String())}'
        : 'Data';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.terra : AppColors.surface,
          border:
              Border.all(color: isActive ? AppColors.terra : AppColors.line),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 12,
                color: isActive ? Colors.white : AppColors.muted),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppText.manrope(
                fontSize: 12,
                color: isActive ? Colors.white : AppColors.muted,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
