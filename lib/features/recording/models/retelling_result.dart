/// How a score reads at a glance. The palette assigns one colour per band.
enum ScoreBand { strong, fair, weak }

class Correction {
  final String wrong;
  final String right;

  const Correction({required this.wrong, required this.right});

  factory Correction.fromJson(Map<String, dynamic> json) => Correction(
    wrong: json['wrong'] as String,
    right: json['right'] as String,
  );
}

class RetellingResult {
  final int score;

  /// Change against the previous attempt; negative means a step back.
  final int delta;

  final int fluency;
  final int grammar;
  final int vocabulary;

  /// Words per minute. The design calls 120–150 the comfortable range.
  final int wpm;

  final String feedback;
  final String transcript;
  final List<Correction> corrections;

  const RetellingResult({
    required this.score,
    required this.delta,
    required this.fluency,
    required this.grammar,
    required this.vocabulary,
    required this.wpm,
    required this.feedback,
    required this.transcript,
    this.corrections = const [],
  });

  static const int paceFloor = 120;
  static const int paceCeiling = 150;

  ScoreBand get band => switch (score) {
    >= 90 => ScoreBand.strong,
    >= 70 => ScoreBand.fair,
    _ => ScoreBand.weak,
  };

  bool get improved => delta >= 0;

  String get deltaLabel =>
      '${improved ? '+' : ''}$delta vs last attempt';

  factory RetellingResult.fromJson(Map<String, dynamic> json) => RetellingResult(
    score: json['score'] as int,
    delta: json['delta'] as int? ?? 0,
    fluency: json['fluency'] as int,
    grammar: json['grammar'] as int,
    vocabulary: json['vocabulary'] as int,
    wpm: json['wpm'] as int,
    feedback: json['feedback'] as String? ?? '',
    transcript: json['transcript'] as String? ?? '',
    corrections:
        (json['corrections'] as List<dynamic>? ?? [])
            .map((item) => Correction.fromJson(item as Map<String, dynamic>))
            .toList(),
  );
}
