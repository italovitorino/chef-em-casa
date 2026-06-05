import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../features/briefing/domain/briefing_state.dart';
import '../features/briefing/presentation/briefing_provider.dart';
import '../theme.dart';
import '../data.dart';
import '../widgets/app_button.dart';
import '../widgets/app_chip.dart';
import 'success_screen.dart';

class BriefingData {
  String? type;
  String? dateIso;      // "2026-06-20" — formato ISO para a API
  String dateLabel = ''; // "20 de Junho, 2026" — exibição na UI
  int guests = 6;
  String street = '';
  String addressNumber = '';
  String city = '';
  String state = '';
  String zipCode = '';
  int hours = 4;
  String notes = '';

  BriefingData copyWith({
    String? type,
    String? dateIso,
    String? dateLabel,
    int? guests,
    String? street,
    String? addressNumber,
    String? city,
    String? state,
    String? zipCode,
    int? hours,
    String? notes,
  }) =>
      BriefingData()
        ..type = type ?? this.type
        ..dateIso = dateIso ?? this.dateIso
        ..dateLabel = dateLabel ?? this.dateLabel
        ..guests = guests ?? this.guests
        ..street = street ?? this.street
        ..addressNumber = addressNumber ?? this.addressNumber
        ..city = city ?? this.city
        ..state = state ?? this.state
        ..zipCode = zipCode ?? this.zipCode
        ..hours = hours ?? this.hours
        ..notes = notes ?? this.notes;
}


class BriefingScreen extends ConsumerStatefulWidget {
  const BriefingScreen({super.key});

  @override
  ConsumerState<BriefingScreen> createState() => _BriefingScreenState();
}

class _BriefingScreenState extends ConsumerState<BriefingScreen> {
  int _step = 0;
  final BriefingData _data = BriefingData();
  final ScrollController _scroll = ScrollController();

  bool get _isReview => _step == 6;

  bool get _canNext => switch (_step) {
    0 => _data.type != null,
    1 => _data.dateIso != null,
    2 => _data.guests > 0,
    3 => _data.street.trim().isNotEmpty &&
        _data.addressNumber.trim().isNotEmpty &&
        _data.city.trim().isNotEmpty &&
        _data.state.trim().isNotEmpty,
    4 => _data.hours > 0,
    _ => true,
  };

  void _next() {
    if (_isReview) {
      ref.read(briefingNotifierProvider.notifier).publish(_data);
    } else {
      setState(() => _step++);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.jumpTo(0);
      });
    }
  }

  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
    } else {
      setState(() => _step--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final briefingState = ref.watch(briefingNotifierProvider);
    final isLoading = briefingState is BriefingLoading;

    ref.listen<BriefingState>(briefingNotifierProvider, (_, next) {
      if (next is BriefingSuccess) {
        ref.read(briefingNotifierProvider.notifier).reset();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SuccessScreen()),
        );
      } else if (next is BriefingError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.terra,
          ),
        );
      }
    });

    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: topPad + 12),
              // progress bar row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _back,
                      child: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Icon(
                          _step == 0 ? Icons.arrow_back : Icons.chevron_left,
                          color: AppColors.cream,
                          size: 19,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Row(
                        children: List.generate(6, (i) {
                          final filled = i <= (_step > 5 ? 5 : _step);
                          return Expanded(
                            child: Container(
                              height: 4,
                              margin: const EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                color: filled ? AppColors.terra : AppColors.surfaceHi,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 14),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: SizedBox(
                        width: 42, height: 42,
                        child: Center(
                          child: Text(
                            'Sair',
                            style: AppText.manrope(fontSize: 13, color: AppColors.muted),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scroll,
                  padding: const EdgeInsets.only(bottom: 120),
                  child: _buildStep(),
                ),
              ),
            ],
          ),
          // bottom action
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24, 14, 24,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [0.72, 1.0],
                  colors: [Color(0xFF15100B), Colors.transparent],
                ),
              ),
              child: AppButton(
                label: isLoading
                    ? 'Enviando…'
                    : _isReview
                        ? 'Enviar briefing'
                        : _step == 5
                            ? 'Revisar'
                            : 'Continuar',
                onTap: (_canNext && !isLoading) ? _next : null,
                variant: _isReview ? AppButtonVariant.gold : AppButtonVariant.primary,
                icon: (_isReview && !isLoading) ? Icons.check : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _StepType(data: _data, onChange: (d) => setState(() { _data.type = d.type; })),
      1 => _StepDate(data: _data, onChange: (d) => setState(() { _data.dateIso = d.dateIso; _data.dateLabel = d.dateLabel; })),
      2 => _StepGuests(data: _data, onChange: (d) => setState(() { _data.guests = d.guests; })),
      3 => _StepLocation(data: _data, onChange: (d) => setState(() {
        _data.street = d.street;
        _data.addressNumber = d.addressNumber;
        _data.city = d.city;
        _data.state = d.state;
        _data.zipCode = d.zipCode;
      })),
      4 => _StepDuration(data: _data, onChange: (d) => setState(() { _data.hours = d.hours; })),
      5 => _StepNotes(data: _data, onChange: (d) => setState(() { _data.notes = d.notes; })),
      _ => _StepReview(data: _data, onGoStep: (s) => setState(() => _step = s)),
    };
  }
}

// ── Field shell ───────────────────────────────────────────────────────────────
class _FieldShell extends StatelessWidget {
  final String kicker;
  final String title;
  final String? sub;
  final Widget child;

  const _FieldShell({
    required this.kicker,
    required this.title,
    this.sub,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kicker,
            style: AppText.spaceMono(fontSize: 10.5, letterSpacing: 2),
          ),
          const SizedBox(height: 10),
          Text(title, style: AppText.cormorant(fontSize: 31, height: 1.08)),
          if (sub != null) ...[
            const SizedBox(height: 10),
            Text(sub!, style: AppText.manrope(fontSize: 14, color: AppColors.muted, height: 1.5)),
          ],
          const SizedBox(height: 26),
          child,
        ],
      ),
    );
  }
}

// ── Step 1 — Event type ───────────────────────────────────────────────────────
class _StepType extends StatelessWidget {
  final BriefingData data;
  final ValueChanged<BriefingData> onChange;

  const _StepType({required this.data, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      kicker: 'PASSO 1 DE 6',
      title: 'Qual é a ocasião?',
      sub: 'Escolha o tipo de evento para orientarmos os chefs certos.',
      child: Column(
        children: kEventTypes.map((e) {
          final on = data.type == e.id;
          return GestureDetector(
            onTap: () => onChange(data.copyWith(type: e.id)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: on ? AppColors.terraSoft : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: on ? AppColors.terra : AppColors.line,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: on ? AppColors.terra : AppColors.surfaceHi,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(e.icon, size: 22, color: on ? Colors.white : AppColors.gold),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.label, style: AppText.cormorant(fontSize: 20, height: 1.1)),
                        const SizedBox(height: 1),
                        Text(e.desc, style: AppText.manrope(fontSize: 12.5, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: on ? AppColors.terra : Colors.transparent,
                      border: Border.all(
                        color: on ? AppColors.terra : AppColors.line2,
                        width: 1.5,
                      ),
                    ),
                    child: on
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Step 2 — Date ─────────────────────────────────────────────────────────────
const _kMonths = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];
const _kWd = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

class _StepDate extends StatefulWidget {
  final BriefingData data;
  final ValueChanged<BriefingData> onChange;

  const _StepDate({required this.data, required this.onChange});

  @override
  State<_StepDate> createState() => _StepDateState();
}

class _StepDateState extends State<_StepDate> {
  int _month = 5; // June 0-indexed
  static const int _year = 2026;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(_year, _month + 1, 1).weekday % 7;
    final daysInMonth = DateTime(_year, _month + 2, 0).day;

    return _FieldShell(
      kicker: 'PASSO 2 DE 6',
      title: 'Quando será?',
      sub: 'Selecione a data do evento.',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: [
                // month nav
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NavBtn(
                      icon: Icons.chevron_left,
                      onTap: () => setState(() => _month = (_month - 1).clamp(5, 11)),
                    ),
                    Text(
                      '${_kMonths[_month]} $_year',
                      style: AppText.cormorant(fontSize: 22),
                    ),
                    _NavBtn(
                      icon: Icons.chevron_right,
                      onTap: () => setState(() => _month = (_month + 1).clamp(5, 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // weekday headers
                Row(
                  children: _kWd.map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: AppText.spaceMono(fontSize: 11, color: AppColors.faint),
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 6),
                // day grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: firstDay + daysInMonth,
                  itemBuilder: (_, i) {
                    if (i < firstDay) return const SizedBox();
                    final day = i - firstDay + 1;
                    final month2 = (_month + 1).toString().padLeft(2, '0');
                    final day2 = day.toString().padLeft(2, '0');
                    final iso = '$_year-$month2-$day2';
                    final selected = widget.data.dateIso == iso;
                    final past = _month == 5 && day < 4;
                    return GestureDetector(
                      onTap: past ? null : () => widget.onChange(
                        widget.data.copyWith(
                          dateIso: iso,
                          dateLabel: '$day de ${_kMonths[_month]}, $_year',
                        ),
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.terra : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: AppText.manrope(
                              fontSize: 14.5,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              color: past
                                  ? AppColors.faint
                                  : selected
                                      ? Colors.white
                                      : AppColors.cream,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 9,
            children: [
              ('2026-06-06', 'Sáb, 6 jun'),
              ('2026-06-13', 'Sáb, 13 jun'),
              ('2026-06-20', 'Sáb, 20 jun'),
            ].map(((String, String) e) => AppChip(
              label: e.$2,
              active: widget.data.dateIso == e.$1,
              onTap: () => widget.onChange(
                widget.data.copyWith(dateIso: e.$1, dateLabel: '${e.$2}, $_year'),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: AppColors.surfaceHi,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(icon, color: AppColors.cream, size: 18),
      ),
    );
  }
}

// ── Step 3 — Guests ───────────────────────────────────────────────────────────
class _StepGuests extends StatelessWidget {
  final BriefingData data;
  final ValueChanged<BriefingData> onChange;

  const _StepGuests({required this.data, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final n = data.guests;
    return _FieldShell(
      kicker: 'PASSO 3 DE 6',
      title: 'Quantos convidados?',
      sub: 'Inclua todas as pessoas que serão servidas.',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepperBtn(
                icon: Icons.chevron_left,
                onTap: () => onChange(data.copyWith(guests: (n - 1).clamp(1, 60))),
              ),
              const SizedBox(width: 26),
              SizedBox(
                width: 110,
                child: Column(
                  children: [
                    Text('$n', style: AppText.cormorant(fontSize: 64, height: 1)),
                    Text(
                      n == 1 ? 'convidado' : 'convidados',
                      style: AppText.manrope(fontSize: 13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 26),
              _StepperBtn(
                icon: Icons.chevron_right,
                onTap: () => onChange(data.copyWith(guests: (n + 1).clamp(1, 60))),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            alignment: WrapAlignment.center,
            children: [2, 4, 6, 8, 12, 20].map((g) => AppChip(
              label: '$g',
              icon: Icons.people,
              active: n == g,
              onTap: () => onChange(data.copyWith(guests: g)),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _StepperBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line2, width: 1.5),
        ),
        child: Icon(icon, color: AppColors.cream, size: 24),
      ),
    );
  }
}

// ── Step 4 — Location ─────────────────────────────────────────────────────────
class _StepLocation extends StatefulWidget {
  final BriefingData data;
  final ValueChanged<BriefingData> onChange;

  const _StepLocation({required this.data, required this.onChange});

  @override
  State<_StepLocation> createState() => _StepLocationState();
}

class _StepLocationState extends State<_StepLocation> {
  bool _locating = false;

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permissão de localização negada.')),
          );
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      final marks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (marks.isNotEmpty && mounted) {
        final p = marks.first;
        widget.onChange(widget.data.copyWith(
          street: p.thoroughfare ?? '',
          addressNumber: p.subThoroughfare ?? '',
          city: p.locality ?? '',
          state: p.administrativeArea ?? '',
          zipCode: p.postalCode ?? '',
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao obter localização: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      kicker: 'PASSO 4 DE 6',
      title: 'Onde vai acontecer?',
      sub: 'O chef precisa do endereço para avaliar deslocamento e estrutura.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botão de localização atual
          GestureDetector(
            onTap: _locating ? null : _useCurrentLocation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.goldSoft,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.gold),
              ),
              child: Row(
                children: [
                  if (_locating)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.gold),
                    )
                  else
                    const Icon(Icons.location_on, size: 18, color: AppColors.gold),
                  const SizedBox(width: 10),
                  Text(
                    _locating ? 'Obtendo localização…' : 'Usar minha localização atual',
                    style: AppText.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _AddressField(
            label: 'Rua',
            value: widget.data.street,
            onChanged: (v) => widget.onChange(widget.data.copyWith(street: v)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _AddressField(
                  label: 'Número',
                  value: widget.data.addressNumber,
                  onChanged: (v) =>
                      widget.onChange(widget.data.copyWith(addressNumber: v)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _AddressField(
                  label: 'CEP',
                  value: widget.data.zipCode,
                  onChanged: (v) =>
                      widget.onChange(widget.data.copyWith(zipCode: v)),
                  keyboard: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AddressField(
            label: 'Cidade',
            value: widget.data.city,
            onChanged: (v) => widget.onChange(widget.data.copyWith(city: v)),
          ),
          const SizedBox(height: 12),
          _AddressField(
            label: 'Estado (UF)',
            value: widget.data.state,
            onChanged: (v) =>
                widget.onChange(widget.data.copyWith(state: v.toUpperCase())),
            maxLength: 2,
          ),
        ],
      ),
    );
  }
}

/// Campo de endereço com controller que se sincroniza quando o valor é atualizado
/// externamente (ex.: preenchimento via geocoding).
class _AddressField extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboard;
  final int? maxLength;

  const _AddressField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.keyboard,
    this.maxLength,
  });

  @override
  State<_AddressField> createState() => _AddressFieldState();
}

class _AddressFieldState extends State<_AddressField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_AddressField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && _ctrl.text != widget.value) {
      _ctrl.text = widget.value;
      _ctrl.selection =
          TextSelection.fromPosition(TextPosition(offset: _ctrl.text.length));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppText.manrope(
              fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.muted),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: TextField(
            controller: _ctrl,
            onChanged: widget.onChanged,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboard,
            style: AppText.manrope(fontSize: 14.5),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              counterText: '',
            ),
            cursorColor: AppColors.terra,
          ),
        ),
      ],
    );
  }
}

// ── Step 5 — Duration ─────────────────────────────────────────────────────────
class _StepDuration extends StatelessWidget {
  final BriefingData data;
  final ValueChanged<BriefingData> onChange;

  const _StepDuration({required this.data, required this.onChange});

  static const int _max = 10;

  @override
  Widget build(BuildContext context) {
    final h = data.hours;
    final pct = (h - 1) / (_max - 1);

    return _FieldShell(
      kicker: 'PASSO 5 DE 6',
      title: 'Tempo estimado',
      sub: 'Por quantas horas você espera contar com o chef no local?',
      child: Column(
        children: [
          // big number
          Center(
            child: Column(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: '$h', style: AppText.cormorant(fontSize: 64, height: 1)),
                      TextSpan(text: 'h', style: AppText.cormorant(fontSize: 30, color: AppColors.gold)),
                    ],
                  ),
                ),
                Text(
                  'incluindo preparo e serviço',
                  style: AppText.manrope(fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // custom slider track
          LayoutBuilder(
            builder: (_, constraints) {
              final trackW = constraints.maxWidth;
              return Column(
                children: [
                  SizedBox(
                    height: 28,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // track bg
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHi,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.line),
                          ),
                        ),
                        // filled track
                        FractionallySizedBox(
                          widthFactor: pct,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: const LinearGradient(
                                colors: [AppColors.terraDeep, AppColors.terra],
                              ),
                            ),
                          ),
                        ),
                        // thumb
                        Positioned(
                          left: pct * (trackW - 26),
                          child: Container(
                            width: 26, height: 26,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.cream,
                              boxShadow: [
                                BoxShadow(color: Color(0x80000000), blurRadius: 8, offset: Offset(0, 3)),
                              ],
                            ),
                          ),
                        ),
                        // invisible slider for interaction
                        Slider(
                          value: h.toDouble(),
                          min: 1,
                          max: _max.toDouble(),
                          divisions: _max - 1,
                          onChanged: (v) => onChange(data.copyWith(hours: v.round())),
                          activeColor: Colors.transparent,
                          inactiveColor: Colors.transparent,
                          thumbColor: Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1h', style: AppText.spaceMono(fontSize: 11, color: AppColors.faint)),
                      Text('10h+', style: AppText.spaceMono(fontSize: 11, color: AppColors.faint)),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            alignment: WrapAlignment.center,
            children: [3, 4, 5, 6].map((v) => AppChip(
              label: '$v horas',
              icon: Icons.access_time,
              active: h == v,
              onTap: () => onChange(data.copyWith(hours: v)),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Step 6 — Notes ────────────────────────────────────────────────────────────
class _StepNotes extends StatefulWidget {
  final BriefingData data;
  final ValueChanged<BriefingData> onChange;

  const _StepNotes({required this.data, required this.onChange});

  @override
  State<_StepNotes> createState() => _StepNotesState();
}

class _StepNotesState extends State<_StepNotes> {
  late final TextEditingController _ctrl;
  static const _suggestions = [
    'Sem lactose',
    'Opção vegetariana',
    'Alergia a frutos do mar',
    'Harmonização com vinhos',
    'Sobremesa especial',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.data.notes);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle(String s) {
    final current = _ctrl.text;
    final String next;
    if (current.contains(s)) {
      next = current.replaceAll('. $s', '').replaceAll(s, '').trim();
    } else {
      next = current.isEmpty ? s : '$current. $s';
    }
    _ctrl.text = next;
    widget.onChange(widget.data.copyWith(notes: next));
  }

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      kicker: 'PASSO 6 DE 6',
      title: 'Observações',
      sub: 'Restrições, preferências de menu, estrutura disponível… tudo ajuda o chef.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: TextField(
              controller: _ctrl,
              onChanged: (v) => widget.onChange(widget.data.copyWith(notes: v)),
              style: AppText.manrope(fontSize: 15, height: 1.6),
              maxLines: 6,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Ex.: aniversário surpresa, 2 convidados vegetarianos…',
                hintStyle: AppText.manrope(fontSize: 15, color: AppColors.faint, height: 1.6),
              ),
              cursorColor: AppColors.terra,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Adicionar rapidamente',
            style: AppText.manrope(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _ctrl,
            builder: (_, val, _) => Wrap(
              spacing: 9,
              runSpacing: 9,
              children: _suggestions.map((s) => AppChip(
                label: s,
                icon: Icons.add,
                active: val.text.contains(s),
                onTap: () => _toggle(s),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step review ───────────────────────────────────────────────────────────────
class _StepReview extends StatelessWidget {
  final BriefingData data;
  final ValueChanged<int> onGoStep;

  const _StepReview({required this.data, required this.onGoStep});

  @override
  Widget build(BuildContext context) {
    final et = kEventTypes.firstWhere(
      (e) => e.id == data.type,
      orElse: () => kEventTypes.first,
    );

    final rows = [
      (0, et.icon, 'Tipo do evento', et.label),
      (1, Icons.calendar_month, 'Data', data.dateLabel.isNotEmpty ? data.dateLabel : '—'),
      (2, Icons.people, 'Convidados', '${data.guests} pessoas'),
      (3, Icons.location_on, 'Local', () {
        final parts = [data.street, data.addressNumber, data.city, data.state]
            .where((s) => s.isNotEmpty)
            .join(', ');
        return parts.isNotEmpty ? parts : '—';
      }()),
      (4, Icons.access_time, 'Duração estimada', '${data.hours} horas'),
      (5, Icons.description, 'Observações', data.notes.isNotEmpty ? data.notes : 'Nenhuma'),
    ];

    return _FieldShell(
      kicker: 'REVISÃO',
      title: 'Confira seu briefing',
      sub: 'Toque em qualquer item para ajustar antes de enviar.',
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              children: rows.asMap().entries.map((entry) {
                final i = entry.key;
                final (step, icon, label, value) = entry.value;
                return GestureDetector(
                  onTap: () => onGoStep(step),
                  child: Container(
                    decoration: BoxDecoration(
                      border: i < rows.length - 1
                          ? const Border(bottom: BorderSide(color: AppColors.line))
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHi,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, size: 19, color: AppColors.gold),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label.toUpperCase(),
                                style: AppText.manrope(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.faint,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                value,
                                style: AppText.manrope(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Icon(Icons.chevron_right, size: 17, color: AppColors.faint),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.goldSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome, size: 18, color: AppColors.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ao enviar, seu briefing fica visível para os chefs da região. Eles abrem uma conversa para negociar menu e valor.',
                    style: AppText.manrope(
                      fontSize: 12.5,
                      color: AppColors.muted,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
