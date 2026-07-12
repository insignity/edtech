import 'package:edtech/features/courses/data/services/lessons_store_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  late LessonsStoreService store;

  setUp(() {
    store = LessonsStoreService();
  });

  group('getLessonNavigation', () {
    setUp(() {
      store.setLessons([
        makeLesson(id: 'l1'),
        makeLesson(id: 'l2'),
        makeLesson(id: 'l3'),
      ]);
    });

    test('first lesson has no previous', () {
      final nav = store.getLessonNavigation('l1');
      expect(nav.previous, isNull);
      expect(nav.current.id, 'l1');
      expect(nav.next?.id, 'l2');
    });

    test('middle lesson has both neighbours', () {
      final nav = store.getLessonNavigation('l2');
      expect(nav.previous?.id, 'l1');
      expect(nav.current.id, 'l2');
      expect(nav.next?.id, 'l3');
    });

    test('last lesson has no next', () {
      final nav = store.getLessonNavigation('l3');
      expect(nav.previous?.id, 'l2');
      expect(nav.next, isNull);
    });

    test('throws when lesson is not in store', () {
      expect(() => store.getLessonNavigation('missing'), throwsException);
    });
  });

  group('markCompleted', () {
    test('sets isCompleted only on the target lesson', () {
      store.setLessons([makeLesson(id: 'l1'), makeLesson(id: 'l2')]);

      store.markCompleted('l1');

      expect(store.getLessonNavigation('l1').current.isCompleted, isTrue);
      expect(store.getLessonNavigation('l2').current.isCompleted, isFalse);
    });

    test('completed state survives navigation reads', () {
      store.setLessons([makeLesson(id: 'l1'), makeLesson(id: 'l2')]);

      store.markCompleted('l2');
      final nav = store.getLessonNavigation('l1');

      expect(nav.next?.isCompleted, isTrue);
    });
  });
}
