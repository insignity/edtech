import 'package:bloc_test/bloc_test.dart';
import 'package:edtech/features/courses/data/courses_repository.dart';
import 'package:edtech/features/courses/models/courses_model.dart';
import 'package:edtech/features/my_courses/ui/bloc/my_courses_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCoursesRepository extends Mock implements CoursesRepository {}

void main() {
  late MockCoursesRepository repository;

  setUp(() {
    repository = MockCoursesRepository();
  });

  blocTest<MyCoursesBloc, MyCoursesState>(
    'emits [Loading, Loaded] with subscriptions',
    build: () {
      when(() => repository.getMySubscriptions()).thenAnswer(
        (_) async => CoursesModel(courses: const [], count: 0),
      );
      return MyCoursesBloc(repository);
    },
    act: (bloc) => bloc.add(MyCoursesFetch()),
    expect: () => [
      isA<MyCoursesLoading>(),
      isA<MyCoursesLoaded>().having((s) => s.courses.count, 'count', 0),
    ],
  );

  blocTest<MyCoursesBloc, MyCoursesState>(
    'emits [Loading, Error] when request fails',
    build: () {
      when(() => repository.getMySubscriptions())
          .thenThrow(Exception('network'));
      return MyCoursesBloc(repository);
    },
    act: (bloc) => bloc.add(MyCoursesFetch()),
    expect: () => [isA<MyCoursesLoading>(), isA<MyCoursesError>()],
  );
}
