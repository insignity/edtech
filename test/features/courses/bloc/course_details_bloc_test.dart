import 'package:bloc_test/bloc_test.dart';
import 'package:edtech/features/courses/data/courses_repository.dart';
import 'package:edtech/features/courses/ui/bloc/course_details/course_details_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockCoursesRepository extends Mock implements CoursesRepository {}

void main() {
  late MockCoursesRepository repository;

  setUp(() {
    repository = MockCoursesRepository();
  });

  group('CourseDetailsFetch', () {
    blocTest<CourseDetailsBloc, CourseDetailsState>(
      'emits [Loading, Loaded] with course and lessons',
      build: () {
        when(() => repository.getCourseById('course-1'))
            .thenAnswer((_) async => makeCourse());
        when(() => repository.getLessons('course-1'))
            .thenAnswer((_) async => [makeLesson()]);
        return CourseDetailsBloc(repository);
      },
      act: (bloc) => bloc.add(CourseDetailsFetch('course-1')),
      expect: () => [
        isA<CourseDetailsLoading>(),
        isA<CourseDetailsLoaded>()
            .having((s) => s.course.id, 'course id', 'course-1')
            .having((s) => s.lessons.length, 'lessons count', 1),
      ],
    );

    blocTest<CourseDetailsBloc, CourseDetailsState>(
      'emits [Loading, Error] when fetch fails',
      build: () {
        when(() => repository.getCourseById(any()))
            .thenThrow(Exception('network'));
        return CourseDetailsBloc(repository);
      },
      act: (bloc) => bloc.add(CourseDetailsFetch('course-1')),
      expect: () => [isA<CourseDetailsLoading>(), isA<CourseDetailsError>()],
    );
  });
}
