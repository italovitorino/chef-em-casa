import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/app_exception.dart';
import '../data/negotiation_dto.dart';
import '../data/negotiation_repository.dart';

final negotiationProvider = AsyncNotifierProviderFamily<
    NegotiationNotifier, NegotiationResponse, String>(
  NegotiationNotifier.new,
);

class NegotiationNotifier
    extends FamilyAsyncNotifier<NegotiationResponse, String> {
  Timer? _timer;

  @override
  Future<NegotiationResponse> build(String id) async {
    ref.onDispose(() => _timer?.cancel());
    _startPolling(id);
    return _fetch(id);
  }

  void _startPolling(String id) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) {
      ref.invalidateSelf();
    });
  }

  Future<NegotiationResponse> _fetch(String id) =>
      ref.read(negotiationRepositoryProvider).getById(id);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(arg));
  }

  Future<void> accept() => _action(
      ref.read(negotiationRepositoryProvider).accept(arg));

  Future<void> reject() => _action(
      ref.read(negotiationRepositoryProvider).reject(arg));

  Future<void> requestRevision() => _action(
      ref.read(negotiationRepositoryProvider).requestRevision(arg));

  Future<void> complete() => _action(
      ref.read(negotiationRepositoryProvider).complete(arg));

  Future<void> cancel() => _action(
      ref.read(negotiationRepositoryProvider).cancel(arg));

  Future<void> _action(Future<NegotiationResponse> future) async {
    try {
      final updated = await future;
      state = AsyncData(updated);
    } on AppException catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

// Provider para iniciar negociação (ação única, sem polling)
final startNegotiationProvider = FutureProviderFamily<NegotiationResponse,
    ({String briefingId, String chefId})>(
  (ref, params) => ref
      .read(negotiationRepositoryProvider)
      .start(params.briefingId, params.chefId),
);
