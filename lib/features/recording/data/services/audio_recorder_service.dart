import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Microphone capture, narrowed to what the recording screen needs.
///
/// Kept behind an interface so the bloc can be tested without a microphone.
abstract class AudioRecorderService {
  Future<bool> hasPermission();

  /// Starts capture and returns the file being written to.
  Future<String> start();

  /// Stops capture and returns the finished file, or null if nothing was written.
  Future<String?> stop();

  /// Loudness samples in the 0..1 range, emitted while recording.
  Stream<double> get levels;

  Future<void> deleteFile(String path);

  Future<void> dispose();
}

class AudioRecorderServiceImpl implements AudioRecorderService {
  final AudioRecorder _recorder;

  AudioRecorderServiceImpl({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  // The mic floor we treat as silence. `record` reports dBFS, which runs from
  // roughly -60 (quiet room) up to 0 (clipping).
  static const double _silenceFloorDb = -45;

  static const Duration _sampleInterval = Duration(milliseconds: 120);

  @override
  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Future<String> start() async {
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/retelling_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, numChannels: 1),
      path: path,
    );
    return path;
  }

  @override
  Future<String?> stop() => _recorder.stop();

  @override
  Stream<double> get levels => _recorder
      .onAmplitudeChanged(_sampleInterval)
      .map((amplitude) => _normalize(amplitude.current));

  static double _normalize(double dbfs) {
    if (dbfs.isNaN || dbfs.isInfinite) return 0;
    final ratio = (dbfs - _silenceFloorDb) / -_silenceFloorDb;
    return ratio.clamp(0.0, 1.0);
  }

  @override
  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<void> dispose() => _recorder.dispose();
}
