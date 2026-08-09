part of 'attempt_details_bloc.dart';

@immutable
sealed class AttemptDetailsEvent {}

class AttemptDetailsFetch extends AttemptDetailsEvent {
  final String attemptId;

  /// Score change against the previous attempt, worked out by the history list
  /// which already holds every attempt for the lesson. Null on a first attempt,
  /// where there is nothing to compare against.
  final int? delta;

  AttemptDetailsFetch(this.attemptId, {this.delta});
}
