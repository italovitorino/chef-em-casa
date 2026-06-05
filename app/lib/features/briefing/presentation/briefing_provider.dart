import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data.dart';
import '../../../screens/briefing_screen.dart' show BriefingData;
import '../data/briefing_dto.dart';
import '../data/briefing_repository.dart';
import '../domain/briefing_state.dart';

class BriefingNotifier extends Notifier<BriefingState> {
  @override
  BriefingState build() => const BriefingInitial();

  Future<void> publish(BriefingData data) async {
    state = const BriefingLoading();
    try {
      final et = kEventTypes.firstWhere(
        (e) => e.id == data.type,
        orElse: () => kEventTypes.last,
      );

      final request = CreateBriefingRequest(
        eventType: et.apiKey,
        eventDate: data.dateIso ?? '',
        numberOfGuests: data.guests,
        street: data.street,
        number: data.addressNumber,
        city: data.city,
        state: data.state,
        zipCode: data.zipCode,
        estimatedDurationMinutes: data.hours * 60,
        notes: data.notes.isNotEmpty ? data.notes : null,
      );

      final briefing =
          await ref.read(briefingRepositoryProvider).publish(request);
      state = BriefingSuccess(briefing);
    } on Exception catch (e) {
      state = BriefingError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void reset() => state = const BriefingInitial();
}

final briefingNotifierProvider =
    NotifierProvider<BriefingNotifier, BriefingState>(
  BriefingNotifier.new,
);
