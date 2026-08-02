import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/router/app_router.dart';
import 'package:edtech/core/sl/injection.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/extensions/extensions.dart';
import '../bloc/recording_bloc.dart';
import '../widgets/analysis_checklist.dart';
import '../widgets/mic_pulse.dart';
import '../widgets/waveform_bars.dart';

@RoutePage()
class RecordingPage extends StatelessWidget implements AutoRouteWrapper {
  final String lessonId;
  final String lessonTitle;

  const RecordingPage({
    super.key,
    @PathParam('lessonId') required this.lessonId,
    this.lessonTitle = 'Retelling',
  });

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
    create: (_) => sl<RecordingBloc>()..add(RecordingRequested()),
    child: this,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(title: lessonTitle),
            Expanded(
              child: BlocConsumer<RecordingBloc, RecordingState>(
                listener: (context, state) {
                  if (state is RecordingAnalyzed) {
                    // Replace, so Back from results returns to the lesson
                    // rather than to a spent recording screen.
                    context.router.replace(
                      ResultsRoute(
                        result: state.result,
                        lessonId: lessonId,
                        lessonTitle: lessonTitle,
                      ),
                    );
                  }
                },
                builder: (context, state) => switch (state) {
                  RecordingIdle() => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  RecordingPermissionDenied() => const _PermissionDenied(),
                  RecordingInProgress() => _Capture(state: state),
                  RecordingReview() => _Review(
                    state: state,
                    lessonId: lessonId,
                  ),
                  RecordingAnalyzing() => _Analyzing(state: state),
                  RecordingAnalyzed() => const SizedBox.shrink(),
                  RecordingFailed() => _Failed(
                    state: state,
                    lessonId: lessonId,
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;

  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grayLight)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.router.maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: AppColors.darkText,
          ),
          Expanded(
            child: Text(
              title,
              style: context.text.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Capture extends StatelessWidget {
  final RecordingInProgress state;

  const _Capture({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const MicPulse(),
          const SizedBox(height: 22),
          Text(
            _formatDuration(state.elapsed),
            style: context.text.displaySmall!.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'max ${_formatDuration(RecordingBloc.maxDuration)}',
            style: context.text.labelMedium,
          ),
          const SizedBox(height: 22),
          WaveformBars(levels: state.levels),
          const SizedBox(height: 30),
          _StopButton(
            onPressed: () =>
                context.read<RecordingBloc>().add(RecordingStopRequested()),
          ),
        ],
      ),
    );
  }
}

class _StopButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _StopButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Stop recording',
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.darkText.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Review extends StatelessWidget {
  final RecordingReview state;
  final String lessonId;

  const _Review({required this.state, required this.lessonId});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RecordingBloc>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        // Both CTAs run the full width of the screen, as in the design.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WaveformBars(
                  levels: state.levels,
                  color: AppColors.primarySoft,
                ),
                const SizedBox(height: 20),
                _PlayButton(
                  isPlaying: state.isPlaying,
                  onPressed: () => bloc.add(RecordingPlaybackToggled()),
                ),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: state.progress,
                      minHeight: 4,
                      backgroundColor: AppColors.primaryLight,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _formatDuration(state.duration),
                  style: context.text.titleLarge!.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => bloc.add(RecordingSubmitted(lessonId)),
            child: const Text('Send for analysis'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => bloc.add(RecordingDiscarded()),
            child: const Text('Re-record'),
          ),
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPressed;

  const _PlayButton({required this.isPlaying, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isPlaying ? 'Pause' : 'Play',
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryLight,
          ),
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 30,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _Analyzing extends StatelessWidget {
  final RecordingAnalyzing state;

  const _Analyzing({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Analyzing your recording…', style: context.text.titleLarge),
          const SizedBox(height: 26),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: state.progress,
                minHeight: 6,
                backgroundColor: AppColors.primaryLight,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 26),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: AnalysisChecklist(completed: state.completed),
          ),
          const SizedBox(height: 26),
          Text(
            'You can close this — the result will appear in History.',
            textAlign: TextAlign.center,
            style: context.text.labelMedium,
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => context.router.maybePop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _Failed extends StatelessWidget {
  final RecordingFailed state;
  final String lessonId;

  const _Failed({required this.state, required this.lessonId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.errorLight,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 30,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            "Couldn't process the recording",
            textAlign: TextAlign.center,
            style: context.text.titleLarge,
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Text(
              // The backend hands back a message meant for the learner; fall
              // back to reassurance when the failure was on our side.
              state.message ??
                  'Your recording was saved — you can retry anytime.',
              textAlign: TextAlign.center,
              style: context.text.bodyMedium,
            ),
          ),
          const SizedBox(height: 26),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () => context.read<RecordingBloc>().add(
                    RecordingSubmitted(lessonId),
                  ),
                  child: const Text('Retry'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => context.router.maybePop(),
                  child: const Text('Come back later'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionDenied extends StatelessWidget {
  const _PermissionDenied();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
            ),
            child: const Icon(
              Icons.mic_off_rounded,
              size: 30,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Microphone access is off',
            textAlign: TextAlign.center,
            style: context.text.titleLarge,
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              'Allow the microphone in system settings to record your '
              'retelling.',
              textAlign: TextAlign.center,
              style: context.text.bodyMedium,
            ),
          ),
          const SizedBox(height: 26),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.router.maybePop(),
                child: const Text('Go back'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
