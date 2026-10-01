import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/router/app_router.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:edtech/features/courses/models/lesson_model.dart';
import 'package:edtech/features/courses/ui/bloc/lesson/lesson_bloc.dart';
import 'package:edtech/shared/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

enum _PlayerStatus { loading, ready, youtube, missing, error }

@RoutePage()
class LessonPage extends StatefulWidget {
  final String lessonId;

  const LessonPage({super.key, @PathParam('lessonId') required this.lessonId});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late final LessonBloc _bloc;
  VideoPlayerController? _videoController;
  _PlayerStatus _status = _PlayerStatus.loading;
  String? _youtubeUrl;
  bool _autoCompleted = false;
  String? _currentLessonId;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<LessonBloc>();
    _bloc.add(LessonLoad(widget.lessonId));
  }

  Future<void> _initPlayer(
    LessonModel lesson, {
    required bool alreadyCompleted,
  }) async {
    await _disposeVideo();
    _autoCompleted = alreadyCompleted;
    _youtubeUrl = null;
    final lessonId = lesson.id;

    if (mounted) setState(() => _status = _PlayerStatus.loading);

    // Null video_source means the backend predates the playback API — the
    // legacy lesson.video URL is already the final, playable one.
    if (lesson.videoSource == null) {
      if (lesson.video.isEmpty) {
        if (mounted && _currentLessonId == lessonId) {
          setState(() => _status = _PlayerStatus.missing);
        }
        return;
      }
      final ok = await _tryPlayVideo(lessonId, lesson.video);
      if (!ok && mounted && _currentLessonId == lessonId) {
        setState(() => _status = _PlayerStatus.error);
      }
      return;
    }

    await _loadPlayback(lessonId, retrying: false);
  }

  // The signed S3 URL expires, so it is always fetched fresh right before
  // playing — never cached across lesson visits. One retry covers a URL that
  // went stale between the fetch and the player actually opening it.
  Future<void> _loadPlayback(String lessonId, {required bool retrying}) async {
    try {
      final playback = await _bloc.repository.getPlayback(lessonId);
      if (!mounted || _currentLessonId != lessonId) return;

      switch (playback.source) {
        case VideoSource.s3:
          final url = playback.url;
          final ok = url != null && await _tryPlayVideo(lessonId, url);
          if (!ok && mounted && _currentLessonId == lessonId) {
            if (!retrying) {
              await _loadPlayback(lessonId, retrying: true);
            } else {
              setState(() => _status = _PlayerStatus.error);
            }
          }
        case VideoSource.youtube:
          setState(() {
            _youtubeUrl = playback.url;
            _status = _PlayerStatus.youtube;
          });
        case VideoSource.none:
          setState(() => _status = _PlayerStatus.missing);
      }
    } catch (_) {
      if (!mounted || _currentLessonId != lessonId) return;
      if (!retrying) {
        await _loadPlayback(lessonId, retrying: true);
      } else {
        setState(() => _status = _PlayerStatus.error);
      }
    }
  }

  /// Returns whether playback actually started. Never throws.
  Future<bool> _tryPlayVideo(String lessonId, String url) async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    controller.addListener(_videoListener);
    try {
      await controller.initialize();
    } catch (_) {
      controller.removeListener(_videoListener);
      await controller.dispose();
      return false;
    }

    if (!mounted || _currentLessonId != lessonId) {
      controller.removeListener(_videoListener);
      await controller.dispose();
      return false;
    }

    _videoController = controller;
    setState(() => _status = _PlayerStatus.ready);
    return true;
  }

  Future<void> _disposeVideo() async {
    final controller = _videoController;
    _videoController = null;
    if (controller != null) {
      controller.removeListener(_videoListener);
      await controller.dispose();
    }
  }

  Future<void> _openYoutube() async {
    final url = _youtubeUrl;
    if (url == null) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  // Auto-complete when 10s left
  void _videoListener() {
    final controller = _videoController;
    if (controller == null || _autoCompleted) return;
    if (!controller.value.isInitialized) return;

    final duration = controller.value.duration;
    final position = controller.value.position;

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
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
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
              state.navigation.current,
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
                _LessonVideoArea(
                  status: _status,
                  controller: _videoController,
                  onOpenYoutube: _openYoutube,
                  onRetry: () => _initPlayer(
                    lesson,
                    alreadyCompleted: lesson.isCompleted,
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

// Lesson videos are portrait MP4s served from S3 via a short-lived signed
// URL, so the ready state just renders the player at its native aspect
// ratio, filling the available width. Every other state is a small message
// in the same black frame so the layout doesn't jump around while loading.
class _LessonVideoArea extends StatelessWidget {
  final _PlayerStatus status;
  final VideoPlayerController? controller;
  final VoidCallback onOpenYoutube;
  final VoidCallback onRetry;

  const _LessonVideoArea({
    required this.status,
    required this.controller,
    required this.onOpenYoutube,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (status == _PlayerStatus.ready && controller != null) {
      return _LessonVideoPlayer(controller: controller!);
    }

    final maxHeight = MediaQuery.sizeOf(context).height * 0.6;

    Widget child;
    switch (status) {
      case _PlayerStatus.ready:
      case _PlayerStatus.loading:
        child = const CircularProgressIndicator(color: AppColors.primary);
      case _PlayerStatus.youtube:
        child = _VideoMessage(
          icon: Icons.open_in_new_rounded,
          message: 'Video is available on YouTube',
          actionLabel: 'Open video',
          onAction: onOpenYoutube,
        );
      case _PlayerStatus.missing:
        child = const _VideoMessage(
          icon: Icons.videocam_off_rounded,
          message: 'No video for this lesson',
        );
      case _PlayerStatus.error:
        child = _VideoMessage(
          icon: Icons.error_outline_rounded,
          message: 'Could not load the video',
          actionLabel: 'Retry',
          onAction: onRetry,
        );
    }

    return Container(
      color: Colors.black,
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: maxHeight, minHeight: 200),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _VideoMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _VideoMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 40),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _LessonVideoPlayer extends StatelessWidget {
  final VideoPlayerController controller;

  const _LessonVideoPlayer({required this.controller});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.6;

    return Container(
      color: Colors.black,
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: maxHeight),
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            VideoPlayer(controller),
            _TapToPlay(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _TapToPlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _TapToPlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final isPlaying = value.isPlaying;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: isPlaying ? controller.pause : controller.play,
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
