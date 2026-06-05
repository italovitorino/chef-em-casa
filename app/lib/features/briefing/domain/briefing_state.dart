import '../data/briefing_dto.dart';

sealed class BriefingState {
  const BriefingState();
}

class BriefingInitial extends BriefingState {
  const BriefingInitial();
}

class BriefingLoading extends BriefingState {
  const BriefingLoading();
}

class BriefingSuccess extends BriefingState {
  final BriefingResponse briefing;
  const BriefingSuccess(this.briefing);
}

class BriefingError extends BriefingState {
  final String message;
  const BriefingError(this.message);
}
