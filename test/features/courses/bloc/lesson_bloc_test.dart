import 'package:bloc_test/bloc_test.dart';
import 'package:edtech/features/courses/data/courses_repository.dart';
import 'package:edtech/features/courses/models/lesson_navigation.dart';
import 'package:edtech/features/courses/ui/bloc/lesson/lesson_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockCoursesRepository extends Mock implements CoursesRepository {}

void main() {
  late MockCoursesRepository repository;

  setUp(() {
    repository = MockCoursesRepository();
  });

  group('LessonLoad', () {
    blocTest<LessonBloc, LessonState>(
      'emits [LessonLoaded] with navigation from store',
      build: () {
        when(() => repository.getLessonNavigation('lesson-1')).thenReturn(
          LessonNavigation(
            current: makeLesson(id: 'lesson-1'),
            next: makeLesson(id: 'lesson-2'),
          ),
        );
        return LessonBloc(repository);
      },
      act: (bloc) => bloc.add(LessonLoad('lesson-1')),
      expect: () => [
        isA<LessonLoaded>()
            .having((s) => s.navigation.current.id, 'current', 'lesson-1')
            .having((s) => s.navigation.next?.id, 'next', 'lesson-2')
            .having((s) => s.navigation.previous, 'previous', isNull),
      ],
    );

    blocTest<LessonBloc, LessonState>(
      'emits [LessonError] when lesson not found in store',
      build: () {
        when(() => repository.getLessonNavigation(any()))
            .thenThrow(Exception('Lesson not found'));
        return LessonBloc(repository);
      },
      act: (bloc) => bloc.add(LessonLoad('missing')),
      expect: () => [isA<LessonError>()],
    );
  });

  group('LessonComplete', () {
    blocTest<LessonBloc, LessonState>(
      'emits [isCompleting, completed] and re-reads navigation from store',
      build: () {
        when(() => repository.completeLesson('lesson-1'))
            .thenAnswer((_) async {});
        when(() => repository.getLessonNavigation('lesson-1')).thenReturn(
          LessonNavigation(
            current: makeLesson(id: 'lesson-1', isCompleted: true),
          ),
        );
        return LessonBloc(repository);
      },
      seed: () => LessonLoaded(
        LessonNavigation(current: makeLesson(id: 'lesson-1')),
      ),
      act: (bloc) => bloc.add(LessonComplete('lesson-1')),
      expect: () => [
        isA<LessonLoaded>().having((s) => s.isCompleting, 'isCompleting', true),
        isA<LessonLoaded>()
            .having((s) => s.isCompleting, 'isCompleting', false)
            .having(
              (s) => s.navigation.current.isCompleted,
              'isCompleted',
              true,
            ),
      ],
    );

    blocTest<LessonBloc, LessonState>(
      'reverts to previous state when API fails',
      build: () {
        when(() => repository.completeLesson(any()))
            .thenThrow(Exception('network'));
        return LessonBloc(repository);
      },
      seed: () => LessonLoaded(
        LessonNavigation(current: makeLesson(id: 'lesson-1')),
      ),
      act: (bloc) => bloc.add(LessonComplete('lesson-1')),
      expect: () => [
        isA<LessonLoaded>().having((s) => s.isCompleting, 'isCompleting', true),
        isA<LessonLoaded>()
            .having((s) => s.isCompleting, 'isCompleting', false)
            .having(
              (s) => s.navigation.current.isCompleted,
              'still not completed',
              false,
            ),
      ],
    );

    blocTest<LessonBloc, LessonState>(
      'does nothing when state is not Loaded',
      build: () => LessonBloc(repository),
      act: (bloc) => bloc.add(LessonComplete('lesson-1')),
      expect: () => [],
      verify: (_) => verifyNever(() => repository.completeLesson(any())),
    );
  });
}
