part of 'speaking_history_bloc.dart';

@immutable
sealed class SpeakingHistoryEvent {}

/// Loads the first page, replacing anything already shown.
class SpeakingHistoryFetch extends SpeakingHistoryEvent {}

/// Appends the next page. Ignored when there is none or one is in flight.
class SpeakingHistoryLoadMore extends SpeakingHistoryEvent {}
