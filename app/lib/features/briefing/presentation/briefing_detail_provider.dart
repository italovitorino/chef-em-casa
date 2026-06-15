import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/app_exception.dart';
import '../../negotiation/data/negotiation_dto.dart';
import '../../negotiation/data/negotiation_repository.dart';
import '../data/briefing_dto.dart';
import '../data/briefing_repository.dart';

class BriefingDetailState {
  final BriefingDetailResponse briefing;
  final List<NegotiationListItem> negotiations;

  const BriefingDetailState({
    required this.briefing,
    required this.negotiations,
  });
}

final briefingDetailProvider = AsyncNotifierProviderFamily<
    BriefingDetailNotifier, BriefingDetailState, String>(
  BriefingDetailNotifier.new,
);

class BriefingDetailNotifier
    extends FamilyAsyncNotifier<BriefingDetailState, String> {
  Timer? _timer;

  @override
  Future<BriefingDetailState> build(String id) async {
    ref.onDispose(() => _timer?.cancel());
    _startPolling(id);
    return _fetch(id);
  }

  void _startPolling(String id) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      ref.invalidateSelf();
    });
  }

  Future<BriefingDetailState> _fetch(String id) async {
    final results = await Future.wait([
      ref.read(briefingRepositoryProvider).getById(id),
      ref.read(negotiationRepositoryProvider).listForBriefing(id),
    ]);
    return BriefingDetailState(
      briefing: results[0] as BriefingDetailResponse,
      negotiations: results[1] as List<NegotiationListItem>,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(arg));
  }

  Future<void> closeBriefing() async {
    try {
      final updated = await ref.read(briefingRepositoryProvider).close(arg);
      final negotiations = state.value?.negotiations ?? [];
      state = AsyncData(BriefingDetailState(
        briefing: updated,
        negotiations: negotiations,
      ));
    } on AppException catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
