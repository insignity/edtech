part of 'speaking_history_bloc.dart';

@immutable
sealed class SpeakingHistoryState {}

final class SpeakingHistoryInitial extends SpeakingHistoryState {}

final class SpeakingHistoryLoading extends SpeakingHistoryState {}

final class SpeakingHistoryError extends SpeakingHistoryState {
  final String error;

  SpeakingHistoryError(this.error);
}

final class SpeakingHistoryLoaded extends SpeakingHistoryState {
  final List<SpeakingHistoryLesson> lessons;

  /// Total lessons on the server, not the number loaded so far.
  final int count;

  final bool hasMore;
  final bool isLoadingMore;

  /// Last page fetched, so the next one can be asked for.
  final int page;

  SpeakingHistoryLoaded({
    required this.lessons,
    required this.count,
    required this.hasMore,
    required this.page,
    this.isLoadingMore = false,
  });

  SpeakingHistoryLoaded copyWith({bool? isLoadingMore}) => SpeakingHistoryLoaded(
    lessons: lessons,
    count: count,
    hasMore: hasMore,
    page: page,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}
