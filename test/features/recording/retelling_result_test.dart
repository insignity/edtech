import 'package:edtech/features/recording/models/retelling_result.dart';
import 'package:flutter_test/flutter_test.dart';

RetellingResult resultWith({int score = 80, int delta = 0}) => RetellingResult(
  score: score,
  delta: delta,
  fluency: 80,
  grammar: 80,
  vocabulary: 80,
  wpm: 130,
  feedback: '',
  transcript: '',
);

void main() {
  group('band', () {
    test('90 and above reads as strong', () {
      expect(resultWith(score: 100).band, ScoreBand.strong);
      expect(resultWith(score: 90).band, ScoreBand.strong);
    });

    test('70 to 89 reads as fair', () {
      expect(resultWith(score: 89).band, ScoreBand.fair);
      expect(resultWith(score: 70).band, ScoreBand.fair);
    });

    test('below 70 reads as weak', () {
      expect(resultWith(score: 69).band, ScoreBand.weak);
      expect(resultWith(score: 0).band, ScoreBand.weak);
    });
  });

  group('delta', () {
    test('signs a gain and counts no change as a gain', () {
      expect(resultWith(delta: 4).deltaLabel, '+4 vs last attempt');
      expect(resultWith(delta: 0).deltaLabel, '+0 vs last attempt');
      expect(resultWith(delta: 0).improved, isTrue);
    });

    test('leaves a drop with its own minus sign', () {
      expect(resultWith(delta: -7).deltaLabel, '-7 vs last attempt');
      expect(resultWith(delta: -7).improved, isFalse);
    });
  });

  group('fromJson', () {
    test('reads a full payload', () {
      final result = RetellingResult.fromJson(const {
        'score': 91,
        'delta': 4,
        'fluency': 88,
        'grammar': 93,
        'vocabulary': 91,
        'wpm': 142,
        'feedback': 'Great flow.',
        'transcript': 'Yesterday I go to a hotel.',
        'corrections': [
          {'wrong': 'I go', 'right': 'I went'},
        ],
      });

      expect(result.score, 91);
      expect(result.band, ScoreBand.strong);
      expect(result.corrections.single.right, 'I went');
    });

    test('survives a payload missing the optional parts', () {
      final result = RetellingResult.fromJson(const {
        'score': 64,
        'fluency': 60,
        'grammar': 66,
        'vocabulary': 65,
        'wpm': 98,
      });

      expect(result.delta, 0);
      expect(result.feedback, isEmpty);
      expect(result.corrections, isEmpty);
      expect(result.band, ScoreBand.weak);
    });
  });
}
