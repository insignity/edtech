import 'package:bloc_test/bloc_test.dart';
import 'package:edtech/features/speaking_history/data/speaking_history_repository.dart';
import 'package:edtech/features/speaking_history/models/speaking_history.dart';
import 'package:edtech/features/speaking_history/ui/bloc/speaking_history_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSpeakingHistoryRepository extends Mock
    implements SpeakingHistoryRepository {}

SpeakingHistoryLesson _lesson(String id) => SpeakingHistoryLesson(
  id: id,
  title: 'Lesson $id',
  level: 'beginner',
  latestAttemptAt: DateTime.utc(2026, 8, 2),
  attempts: const [],
);

SpeakingHistoryModel _page(List<String> ids, {String? next}) =>
    SpeakingHistoryModel(
      count: 40,
      next: next,
      lessons: ids.map(_lesson).toList(),
    );

void main() {
  late MockSpeakingHistoryRepository repository;

  setUp(() {
    repository = MockSpeakingHistoryRepository();
  });

  void stubPage(int page, SpeakingHistoryModel result) {
    when(
      () => repository.getHistory(
        page: page,
        pageSize: SpeakingHistoryBloc.pageSize,
      ),
    ).thenAnswer((_) async => result);
  }

  blocTest<SpeakingHistoryBloc, SpeakingHistoryState>(
    'emits [Loading, Loaded] with the first page',
    build: () {
      stubPage(1, _page(['a', 'b']));
      return SpeakingHistoryBloc(repository);
    },
    act: (bloc) => bloc.add(SpeakingHistoryFetch()),
    expect: () => [
      isA<SpeakingHistoryLoading>(),
      isA<SpeakingHistoryLoaded>()
          .having((s) => s.lessons.length, 'lessons', 2)
          .having((s) => s.hasMore, 'hasMore', false)
          .having((s) => s.page, 'page', 1),
    ],
  );

  blocTest<SpeakingHistoryBloc, SpeakingHistoryState>(
    'emits [Loading, Error] when the request fails',
    build: () {
      when(
        () => repository.getHistory(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenThrow(Exception('network'));
      return SpeakingHistoryBloc(repository);
    },
    act: (bloc) => bloc.add(SpeakingHistoryFetch()),
    expect: () => [
      isA<SpeakingHistoryLoading>(),
      isA<SpeakingHistoryError>(),
    ],
  );

  blocTest<SpeakingHistoryBloc, SpeakingHistoryState>(
    'appends the next page instead of replacing what is shown',
    build: () {
      stubPage(1, _page(['a', 'b'], next: 'https://api/next'));
      stubPage(2, _page(['c']));
      return SpeakingHistoryBloc(repository);
    },
    act: (bloc) async {
      bloc.add(SpeakingHistoryFetch());
      await Future<void>.delayed(Duration.zero);
      bloc.add(SpeakingHistoryLoadMore());
    },
    skip: 2,
    expect: () => [
      isA<SpeakingHistoryLoaded>().having(
        (s) => s.isLoadingMore,
        'isLoadingMore',
        true,
      ),
      isA<SpeakingHistoryLoaded>()
          .having((s) => s.lessons.map((l) => l.id), 'ids', ['a', 'b', 'c'])
          .having((s) => s.page, 'page', 2)
          .having((s) => s.hasMore, 'hasMore', false)
          .having((s) => s.isLoadingMore, 'isLoadingMore', false),
    ],
  );

  blocTest<SpeakingHistoryBloc, SpeakingHistoryState>(
    'ignores load more when the last page is already in hand',
    build: () {
      stubPage(1, _page(['a']));
      return SpeakingHistoryBloc(repository);
    },
    act: (bloc) async {
      bloc.add(SpeakingHistoryFetch());
      await Future<void>.delayed(Duration.zero);
      bloc.add(SpeakingHistoryLoadMore());
    },
    expect: () => [
      isA<SpeakingHistoryLoading>(),
      isA<SpeakingHistoryLoaded>(),
    ],
    verify: (_) {
      verifyNever(
        () => repository.getHistory(
          page: 2,
          pageSize: SpeakingHistoryBloc.pageSize,
        ),
      );
    },
  );

  blocTest<SpeakingHistoryBloc, SpeakingHistoryState>(
    'keeps the loaded lessons when a further page fails',
    build: () {
      stubPage(1, _page(['a'], next: 'https://api/next'));
      when(
        () => repository.getHistory(
          page: 2,
          pageSize: SpeakingHistoryBloc.pageSize,
        ),
      ).thenThrow(Exception('network'));
      return SpeakingHistoryBloc(repository);
    },
    act: (bloc) async {
      bloc.add(SpeakingHistoryFetch());
      await Future<void>.delayed(Duration.zero);
      bloc.add(SpeakingHistoryLoadMore());
    },
    skip: 2,
    expect: () => [
      isA<SpeakingHistoryLoaded>().having(
        (s) => s.isLoadingMore,
        'isLoadingMore',
        true,
      ),
      isA<SpeakingHistoryLoaded>()
          .having((s) => s.lessons.length, 'lessons', 1)
          .having((s) => s.hasMore, 'hasMore', true)
          .having((s) => s.isLoadingMore, 'isLoadingMore', false),
    ],
  );
}
