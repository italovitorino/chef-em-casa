import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/briefing_dto.dart';
import '../data/briefing_repository.dart';

class BriefingsListNotifier
    extends AsyncNotifier<List<BriefingListItem>> {
  @override
  Future<List<BriefingListItem>> build() => _fetch();

  Future<List<BriefingListItem>> _fetch() =>
      ref.read(briefingRepositoryProvider).list();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final briefingsListProvider =
    AsyncNotifierProvider<BriefingsListNotifier, List<BriefingListItem>>(
  BriefingsListNotifier.new,
);
