part of 'recording_bloc.dart';

@immutable
sealed class RecordingState {}

final class RecordingIdle extends RecordingState {}

/// The microphone was refused, so there is nothing to offer but an explanation.
final class RecordingPermissionDenied extends RecordingState {}

final class RecordingInProgress extends RecordingState {
  final Duration elapsed;

  /// Rolling window of loudness samples, oldest first, for the waveform.
  final List<double> levels;

  RecordingInProgress({required this.elapsed, required this.levels});
}

final class RecordingReview extends RecordingState {
  final String path;
  final Duration duration;
  final List<double> levels;
  final bool isPlaying;
  final Duration position;

  RecordingReview({
    required this.path,
    required this.duration,
    required this.levels,
    this.isPlaying = false,
    this.position = Duration.zero,
  });

  double get progress => duration.inMilliseconds == 0
      ? 0
      : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

  RecordingReview copyWith({bool? isPlaying, Duration? position}) =>
      RecordingReview(
        path: path,
        duration: duration,
        levels: levels,
        isPlaying: isPlaying ?? this.isPlaying,
        position: position ?? this.position,
      );
}

final class RecordingAnalyzing extends RecordingState {
  final String path;
  final Duration duration;
  final List<double> levels;

  /// Steps the backend has confirmed, in order.
  final List<AnalysisStep> completed;

  /// Set once grading reports back, before the stream closes.
  final RetellingResult? result;

  RecordingAnalyzing({
    required this.path,
    required this.duration,
    required this.levels,
    this.completed = const [],
    this.result,
  });

  double get progress => completed.length / AnalysisStep.values.length;

  RecordingAnalyzing withStep(AnalysisStep step) => RecordingAnalyzing(
    path: path,
    duration: duration,
    levels: levels,
    completed: [...completed, step],
    result: result,
  );

  RecordingAnalyzing withResult(RetellingResult value) => RecordingAnalyzing(
    path: path,
    duration: duration,
    levels: levels,
    completed: completed,
    result: value,
  );
}

final class RecordingAnalyzed extends RecordingState {
  final RetellingResult result;

  RecordingAnalyzed(this.result);
}

/// Analysis failed. The recording stays on disk so a retry costs nothing.
final class RecordingFailed extends RecordingState {
  final String path;
  final Duration duration;
  final List<double> levels;

  /// What the backend said went wrong, when it said anything.
  final String? message;

  RecordingFailed({
    required this.path,
    required this.duration,
    required this.levels,
    this.message,
  });
}
