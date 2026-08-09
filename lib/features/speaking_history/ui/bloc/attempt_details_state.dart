part of 'attempt_details_bloc.dart';

@immutable
sealed class AttemptDetailsState {}

final class AttemptDetailsInitial extends AttemptDetailsState {}

final class AttemptDetailsLoading extends AttemptDetailsState {}

final class AttemptDetailsError extends AttemptDetailsState {
  final String error;

  AttemptDetailsError(this.error);
}

final class AttemptDetailsLoaded extends AttemptDetailsState {
  final RetellingResult result;

  /// False for a first attempt, so the screen hides the "vs last attempt" line.
  final bool showDelta;

  AttemptDetailsLoaded(this.result, {required this.showDelta});
}
