part of 'recording_bloc.dart';

@immutable
sealed class RecordingEvent {}

class RecordingRequested extends RecordingEvent {}

class RecordingStopRequested extends RecordingEvent {}

/// Emitted by the internal ticker while capture runs.
class RecordingTicked extends RecordingEvent {}

class RecordingPlaybackToggled extends RecordingEvent {}

class RecordingPositionChanged extends RecordingEvent {
  final Duration position;
  RecordingPositionChanged(this.position);
}

class RecordingPlaybackCompleted extends RecordingEvent {}

/// Throws the take away and starts a fresh one.
class RecordingDiscarded extends RecordingEvent {}

class RecordingSubmitted extends RecordingEvent {
  final String lessonId;
  RecordingSubmitted(this.lessonId);
}

class RecordingStepCompleted extends RecordingEvent {
  final AnalysisStep step;
  RecordingStepCompleted(this.step);
}

class RecordingResultReceived extends RecordingEvent {
  final RetellingResult result;
  RecordingResultReceived(this.result);
}

class RecordingAnalysisFinished extends RecordingEvent {}

class RecordingAnalysisFailed extends RecordingEvent {}
