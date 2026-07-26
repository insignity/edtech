import 'package:just_audio/just_audio.dart';

/// Playback of the just-recorded file, narrowed to what the review step needs.
abstract class AudioPlayerService {
  /// Loads [path] and returns its duration when the decoder reports one.
  Future<Duration?> load(String path);

  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);

  Stream<Duration> get position;

  /// Fires once each time playback runs to the end of the file.
  Stream<void> get completions;

  Future<void> dispose();
}

class AudioPlayerServiceImpl implements AudioPlayerService {
  final AudioPlayer _player;

  AudioPlayerServiceImpl({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  @override
  Future<Duration?> load(String path) => _player.setFilePath(path);

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Stream<Duration> get position => _player.positionStream;

  @override
  Stream<void> get completions => _player.processingStateStream
      .where((state) => state == ProcessingState.completed);

  @override
  Future<void> dispose() => _player.dispose();
}
