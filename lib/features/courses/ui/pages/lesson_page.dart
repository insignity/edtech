import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/router/app_router.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:edtech/features/courses/ui/bloc/lesson/lesson_bloc.dart';
import 'package:edtech/shared/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

@RoutePage()
class LessonPage extends StatefulWidget {
  final String lessonId;

  const LessonPage({super.key, @PathParam('lessonId') required this.lessonId});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late final LessonBloc _bloc;
  YoutubePlayerController? _ytController;
  StreamSubscription<YoutubeVideoState>? _videoStateSub;
  bool _autoCompleted = false;
  String? _currentLessonId;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<LessonBloc>();
    _bloc.add(LessonLoad(widget.lessonId));
  }

  void _initPlayer(String videoUrl, {required bool alreadyCompleted}) {
    final videoId = YoutubePlayerController.convertUrlToId(videoUrl);
    if (videoId == null) return;

    _videoStateSub?.cancel();
    _ytController?.close();
    _autoCompleted = alreadyCompleted;

    _ytController = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        enableCaption: false,
        showVideoAnnotations: false,
        mute: false,
      ),
    );

    // Listen to position — auto-complete when 10s left
    _videoStateSub = _ytController!.videoStateStream.listen((videoState) {
      if (_autoCompleted) return;

      final duration = _ytController!.metadata.duration;
      final position = videoState.position;

      // Guard: video must have actually started playing
      if (duration == Duration.zero) return;
      if (position == Duration.zero) return;
      if (duration.inSeconds < 15) return; // ignore very short/broken durations

      final remaining = duration - position;
      if (remaining.inSeconds <= 10) {
        _autoCompleted = true;
        final blocState = _bloc.state;
        if (blocState is LessonLoaded &&
            !blocState.navigation.current.isCompleted) {
          _bloc.add(LessonComplete(blocState.navigation.current.id));
        }
      }
    });

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoStateSub?.cancel();
    _ytController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LessonBloc, LessonState>(
      listener: (context, state) {
        if (state is LessonLoaded && !state.isCompleting) {
          final lessonId = state.navigation.current.id;
          // Only reinit player when navigating to a different lesson
          if (_currentLessonId != lessonId) {
            _currentLessonId = lessonId;
            _initPlayer(
              state.navigation.current.video,
              alreadyCompleted: state.navigation.current.isCompleted,
            );
          }
        }
      },
      builder: (context, state) {
        if (state is LessonInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is LessonError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.error,
                      textAlign: TextAlign.center,
                      style: context.text.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final loaded = state as LessonLoaded;
        final nav = loaded.navigation;
        final lesson = nav.current;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Player
                if (_ytController != null)
                  _ShortsPlayer(controller: _ytController!)
                else
                  Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.router.pop(),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: AppColors.darkText,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                lesson.name,
                                style: context.text.titleLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        if (lesson.description != null &&
                            lesson.description!.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text('Description', style: context.text.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            lesson.description!,
                            style: context.text.bodyLarge,
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Mark as complete button
                        SizedBox(
                          width: double.infinity,
                          child: lesson.isCompleted
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.successLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.success,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Completed',
                                        style: context.text.labelLarge!
                                            .copyWith(color: AppColors.success),
                                      ),
                                    ],
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: loaded.isCompleting
                                      ? null
                                      : () => _bloc.add(
                                          LessonComplete(lesson.id),
                                        ),
                                  icon: loaded.isCompleting
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.check_rounded),
                                  label: Text(
                                    loaded.isCompleting
                                        ? 'Saving...'
                                        : 'Mark as Complete',
                                  ),
                                ),
                        ),

                        // TODO Uncomment when necessary
                        const SizedBox(height: 16),

                        // Record retelling button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => context.router.push(
                              RecordingRoute(
                                lessonId: lesson.id,
                                lessonTitle: lesson.name,
                              ),
                            ),
                            icon: const Icon(Icons.mic_rounded),
                            label: const Text('Record Retelling'),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Prev / Next navigation
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (nav.previous != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _bloc.add(LessonLoad(nav.previous!.id)),
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Previous'),
                          ),
                        ),
                      if (nav.previous != null && nav.next != null)
                        const SizedBox(width: 12),
                      if (nav.next != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _bloc.add(LessonLoad(nav.next!.id)),
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text('Next'),
                            iconAlignment: IconAlignment.end,
                          ),
                        ),
                      if (nav.previous == null && nav.next == null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.router.pop(),
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Finish'),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Lesson videos are 16:9 with a vertical 9:16 clip centered in the frame and
// filler on the sides, so we render the player at full size and clip away
// everything but the middle strip.
class _ShortsPlayer extends StatelessWidget {
  final YoutubePlayerController controller;

  const _ShortsPlayer({required this.controller});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.6;
    final visibleWidth = height * 9 / 16;
    final playerWidth = height * 16 / 9;

    return Container(
      color: Colors.black,
      width: double.infinity,
      height: height,
      alignment: Alignment.center,
      child: ClipRect(
        child: SizedBox(
          width: visibleWidth,
          height: height,
          child: OverflowBox(
            minWidth: playerWidth,
            maxWidth: playerWidth,
            minHeight: height,
            maxHeight: height,
            child: YoutubePlayer(
              controller: controller,
              aspectRatio: 16 / 9,
              enableFullScreenOnVerticalDrag: false,
              builder: (context, player, controller) => Stack(
                fit: StackFit.expand,
                children: [
                  player,
                  // On mobile the WebView lives in an overlay that ClipRect
                  // can't reach, so mask the filler sides by painting over them.
                  Row(
                    children: [
                      const Expanded(child: ColoredBox(color: Colors.black)),
                      SizedBox(
                        width: visibleWidth,
                        child: _TapToPlay(controller: controller),
                      ),
                      const Expanded(child: ColoredBox(color: Colors.black)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TapToPlay extends StatelessWidget {
  final YoutubePlayerController controller;

  const _TapToPlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return YoutubeValueBuilder(
      controller: controller,
      buildWhen: (o, n) => o.playerState != n.playerState,
      builder: (context, value) {
        final isPlaying = value.playerState == PlayerState.playing;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: isPlaying ? controller.pauseVideo : controller.playVideo,
          child: Center(
            child: AnimatedOpacity(
              opacity: isPlaying ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 72,
              ),
            ),
          ),
        );
      },
    );
  }
}
