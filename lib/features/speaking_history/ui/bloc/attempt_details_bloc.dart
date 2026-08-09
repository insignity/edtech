import 'package:edtech/features/recording/models/retelling_result.dart';
import 'package:edtech/features/recording/models/speaking_attempt.dart';
import 'package:edtech/features/speaking_history/data/speaking_history_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'attempt_details_event.dart';
part 'attempt_details_state.dart';

class AttemptDetailsBloc extends Bloc<AttemptDetailsEvent, AttemptDetailsState> {
  final SpeakingHistoryRepository repository;

  AttemptDetailsBloc(this.repository) : super(AttemptDetailsInitial()) {
    on<AttemptDetailsFetch>(_onFetch);
  }

  Future<void> _onFetch(
    AttemptDetailsFetch event,
    Emitter<AttemptDetailsState> emit,
  ) async {
    emit(AttemptDetailsLoading());
    try {
      final attempt = await repository.getAttempt(event.attemptId);

      // The list only offers graded rows, but a status can move between the
      // list being drawn and this request — and building a result out of an
      // attempt without feedback would throw.
      if (attempt.status == SpeakingAttemptStatus.failed) {
        emit(
          AttemptDetailsError(
            attempt.error?.message ?? 'This recording could not be processed.',
          ),
        );
        return;
      }

      if (attempt.feedback == null) {
        emit(AttemptDetailsError('This result is not ready yet.'));
        return;
      }

      emit(
        AttemptDetailsLoaded(
          RetellingResult.fromAttempt(attempt, delta: event.delta ?? 0),
          showDelta: event.delta != null,
        ),
      );
    } catch (e) {
      emit(AttemptDetailsError(e.toString()));
    }
  }
}
