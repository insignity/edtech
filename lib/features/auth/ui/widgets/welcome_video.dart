
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class WelcomeVideo extends StatefulWidget {
  const WelcomeVideo({super.key});

  @override
  State<WelcomeVideo> createState() => _WelcomeVideoState();
}

class _WelcomeVideoState extends State<WelcomeVideo> {
  late VideoPlayerController _controller;
  bool _isWaiting = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/videos/panda.mp4'
    )
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
    _controller.setVolume(0); // без звука

    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (!_controller.value.isInitialized) return;

    final isFinished =
        _controller.value.position >= _controller.value.duration;

    if (isFinished && !_isWaiting) {
      _isWaiting = true;

      _controller.pause();

      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;

        _controller.seekTo(Duration.zero);
        _controller.play();

        _isWaiting = false;
      });
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );
  }
}