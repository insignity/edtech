import 'package:edtech/features/speaking_history/data/speaking_history_repository.dart';
import 'package:edtech/features/speaking_history/models/speaking_history.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'speaking_history_event.dart';
part 'speaking_history_state.dart';

class SpeakingHistoryBloc
    extends Bloc<SpeakingHistoryEvent, SpeakingHistoryState> {
  final SpeakingHistoryRepository repository;

  /// The endpoint defaults to 20 and caps at 100. Twenty lessons fill more than
  /// a screen, so the first paint stays quick and the rest comes on scroll.
  static const int pageSize = 20;

  SpeakingHistoryBloc(this.repository) : super(SpeakingHistoryInitial()) {
    on<SpeakingHistoryFetch>(_onFetch);
    on<SpeakingHistoryLoadMore>(_onLoadMore);
  }

  Future<void> _onFetch(
    SpeakingHistoryFetch event,
    Emitter<SpeakingHistoryState> emit,
  ) async {
    emit(SpeakingHistoryLoading());
    try {
      final result = await repository.getHistory(page: 1, pageSize: pageSize);
      emit(
        SpeakingHistoryLoaded(
          lessons: result.lessons,
          count: result.count,
          hasMore: result.hasMore,
          page: 1,
        ),
      );
    } catch (e) {
      emit(SpeakingHistoryError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
    SpeakingHistoryLoadMore event,
    Emitter<SpeakingHistoryState> emit,
  ) async {
    final current = state;
    // The list fires this on every frame it spends near the bottom, so drop the
    // request unless there is a page left and nothing is already in flight.
    if (current is! SpeakingHistoryLoaded ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));

    final nextPage = current.page + 1;
    try {
      final result = await repository.getHistory(
        page: nextPage,
        pageSize: pageSize,
      );
      emit(
        SpeakingHistoryLoaded(
          lessons: [...current.lessons, ...result.lessons],
          count: result.count,
          hasMore: result.hasMore,
          page: nextPage,
        ),
      );
    } catch (_) {
      // A failed page must not throw away what is already on screen — drop back
      // to the loaded state so scrolling can trigger another try.
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}
