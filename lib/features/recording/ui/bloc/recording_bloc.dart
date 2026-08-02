import 'dart:async';

import 'package:edtech/features/recording/data/recording_repository.dart';
import 'package:edtech/features/recording/data/services/audio_player_service.dart';
import 'package:edtech/features/recording/data/services/audio_recorder_service.dart';
import 'package:edtech/features/recording/models/analysis_step.dart';
import 'package:edtech/features/recording/models/analysis_update.dart';
import 'package:edtech/features/recording/models/retelling_result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'recording_event.dart';
part 'recording_state.dart';

class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final AudioRecorderService recorder;
  final AudioPlayerService player;
  final RecordingRepository repository;

  /// Hard cap from the design — the timer stops itself at 2:00.
  static const Duration maxDuration = Duration(minutes: 2);

  /// Bars in the waveform, so the level window is sized to match.
  static const int waveformBars = 28;

  static const Duration _tickInterval = Duration(milliseconds: 120);

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  double _lastLevel = 0;
  StreamSubscription<double>? _levelSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<void>? _completionSubscription;
  StreamSubscription<AnalysisUpdate>? _analysisSubscription;

  RecordingBloc({
    required this.recorder,
    required this.player,
    required this.repository,
  }) : super(RecordingIdle()) {
    on<RecordingRequested>(_onRequested);
    on<RecordingTicked>(_onTicked);
    on<RecordingStopRequested>(_onStopRequested);
    on<RecordingPlaybackToggled>(_onPlaybackToggled);
    on<RecordingPositionChanged>(_onPositionChanged);
    on<RecordingPlaybackCompleted>(_onPlaybackCompleted);
    on<RecordingDiscarded>(_onDiscarded);
    on<RecordingSubmitted>(_onSubmitted);
    on<RecordingStepCompleted>(_onStepCompleted);
    on<RecordingResultReceived>(_onResultReceived);
    on<RecordingAnalysisFinished>(_onAnalysisFinished);
    on<RecordingAnalysisFailed>(_onAnalysisFailed);
  }

  Future<void> _onRequested(
    RecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    if (!await recorder.hasPermission()) {
      emit(RecordingPermissionDenied());
      return;
    }

    await recorder.start();

    _lastLevel = 0;
    _levelSubscription = recorder.levels.listen((level) => _lastLevel = level);
    _stopwatch
      ..reset()
      ..start();
    _ticker = Timer.periodic(_tickInterval, (_) => add(RecordingTicked()));

    emit(RecordingInProgress(elapsed: Duration.zero, levels: const []));
  }

  void _onTicked(RecordingTicked event, Emitter<RecordingState> emit) {
    if (state is! RecordingInProgress) return;
    final current = state as RecordingInProgress;

    final elapsed = _stopwatch.elapsed;
    if (elapsed >= maxDuration) {
      add(RecordingStopRequested());
      return;
    }

    emit(
      RecordingInProgress(
        elapsed: elapsed,
        levels: _appendLevel(current.levels, _lastLevel),
      ),
    );
  }

  Future<void> _onStopRequested(
    RecordingStopRequested event,
    Emitter<RecordingState> emit,
  ) async {
    if (state is! RecordingInProgress) return;
    final current = state as RecordingInProgress;

    final elapsed = _stopwatch.elapsed;
    await _stopCapture();

    final path = await recorder.stop();
    if (path == null) {
      emit(RecordingIdle());
      return;
    }

    final duration = await player.load(path) ?? elapsed;
    _listenToPlayback();

    emit(
      RecordingReview(path: path, duration: duration, levels: current.levels),
    );
  }

  Future<void> _onPlaybackToggled(
    RecordingPlaybackToggled event,
    Emitter<RecordingState> emit,
  ) async {
    if (state is! RecordingReview) return;
    final current = state as RecordingReview;

    if (current.isPlaying) {
      await player.pause();
      emit(current.copyWith(isPlaying: false));
      return;
    }

    // Replaying after the end should start over, not sit at the tail.
    if (current.position >= current.duration) {
      await player.seek(Duration.zero);
    }
    await player.play();
    emit(current.copyWith(isPlaying: true));
  }

  void _onPositionChanged(
    RecordingPositionChanged event,
    Emitter<RecordingState> emit,
  ) {
    if (state is! RecordingReview) return;
    emit((state as RecordingReview).copyWith(position: event.position));
  }

  void _onPlaybackCompleted(
    RecordingPlaybackCompleted event,
    Emitter<RecordingState> emit,
  ) {
    if (state is! RecordingReview) return;
    final current = state as RecordingReview;
    emit(current.copyWith(isPlaying: false, position: current.duration));
  }

  Future<void> _onDiscarded(
    RecordingDiscarded event,
    Emitter<RecordingState> emit,
  ) async {
    final path = switch (state) {
      RecordingReview(:final path) => path,
      RecordingFailed(:final path) => path,
      _ => null,
    };

    await _stopPlayback();
    if (path != null) await recorder.deleteFile(path);

    emit(RecordingIdle());
    add(RecordingRequested());
  }

  Future<void> _onSubmitted(
    RecordingSubmitted event,
    Emitter<RecordingState> emit,
  ) async {
    final (path, duration, levels) = switch (state) {
      RecordingReview(:final path, :final duration, :final levels) => (
        path,
        duration,
        levels,
      ),
      RecordingFailed(:final path, :final duration, :final levels) => (
        path,
        duration,
        levels,
      ),
      _ => (null, Duration.zero, const <double>[]),
    };
    if (path == null) return;

    await _stopPlayback();
    emit(RecordingAnalyzing(path: path, duration: duration, levels: levels));

    await _analysisSubscription?.cancel();
    _analysisSubscription = repository
        .analyze(lessonId: event.lessonId, filePath: path)
        .listen(
          (update) => add(switch (update) {
            AnalysisStepDone(:final step) => RecordingStepCompleted(step),
            AnalysisResultReady(:final result) => RecordingResultReceived(
              result,
            ),
          }),
          onError: (Object error) => add(
            RecordingAnalysisFailed(
              error is AnalysisException ? error.message : null,
            ),
          ),
          onDone: () => add(RecordingAnalysisFinished()),
        );
  }

  void _onStepCompleted(
    RecordingStepCompleted event,
    Emitter<RecordingState> emit,
  ) {
    if (state is! RecordingAnalyzing) return;
    emit((state as RecordingAnalyzing).withStep(event.step));
  }

  void _onResultReceived(
    RecordingResultReceived event,
    Emitter<RecordingState> emit,
  ) {
    if (state is! RecordingAnalyzing) return;
    emit((state as RecordingAnalyzing).withResult(event.result));
  }

  void _onAnalysisFinished(
    RecordingAnalysisFinished event,
    Emitter<RecordingState> emit,
  ) {
    if (state is! RecordingAnalyzing) return;
    final current = state as RecordingAnalyzing;

    // A stream that ends without walking every step, or without handing back a
    // score, never really succeeded.
    final result = current.result;
    if (current.completed.length < AnalysisStep.values.length ||
        result == null) {
      emit(
        RecordingFailed(
          path: current.path,
          duration: current.duration,
          levels: current.levels,
        ),
      );
      return;
    }
    emit(RecordingAnalyzed(result));
  }

  void _onAnalysisFailed(
    RecordingAnalysisFailed event,
    Emitter<RecordingState> emit,
  ) {
    if (state is! RecordingAnalyzing) return;
    final current = state as RecordingAnalyzing;
    emit(
      RecordingFailed(
        path: current.path,
        duration: current.duration,
        levels: current.levels,
        message: event.message,
      ),
    );
  }

  static List<double> _appendLevel(List<double> levels, double level) {
    final next = [...levels, level];
    return next.length <= waveformBars
        ? next
        : next.sublist(next.length - waveformBars);
  }

  void _listenToPlayback() {
    _positionSubscription = player.position.listen(
      (position) => add(RecordingPositionChanged(position)),
    );
    _completionSubscription = player.completions.listen(
      (_) => add(RecordingPlaybackCompleted()),
    );
  }

  Future<void> _stopCapture() async {
    _ticker?.cancel();
    _ticker = null;
    _stopwatch.stop();
    await _levelSubscription?.cancel();
    _levelSubscription = null;
  }

  Future<void> _stopPlayback() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    await _completionSubscription?.cancel();
    _completionSubscription = null;
    await player.pause();
  }

  @override
  Future<void> close() async {
    await _stopCapture();
    await _positionSubscription?.cancel();
    await _completionSubscription?.cancel();
    await _analysisSubscription?.cancel();
    await recorder.dispose();
    await player.dispose();
    return super.close();
  }
}
