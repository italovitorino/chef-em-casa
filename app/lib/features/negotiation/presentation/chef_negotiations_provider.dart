import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/negotiation_dto.dart';
import '../data/negotiation_repository.dart';

class ChefNegotiationsNotifier extends AsyncNotifier<List<NegotiationResponse>> {
  Timer? _timer;

  @override
  Future<List<NegotiationResponse>> build() async {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => refresh());
    ref.onDispose(() => _timer?.cancel());
    return ref.read(negotiationRepositoryProvider).getMyNegotiations();
  }

  Future<void> refresh() async {
    final list = await ref.read(negotiationRepositoryProvider).getMyNegotiations();
    state = AsyncData(list);
  }
}

final chefNegotiationsProvider = AsyncNotifierProvider<
    ChefNegotiationsNotifier, List<NegotiationResponse>>(
  ChefNegotiationsNotifier.new,
);
