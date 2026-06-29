import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/negotiation_dto.dart';
import '../data/negotiation_repository.dart';

final clientNegotiationsProvider = FutureProvider<List<NegotiationResponse>>((ref) {
  return ref.read(negotiationRepositoryProvider).getMyNegotiations();
});
