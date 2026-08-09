import 'package:edtech/features/recording/models/speaking_attempt.dart';

/// In-memory cache of graded attempts, so reopening one from history does not
/// go back to the network.
///
/// Safe because a finished attempt never changes: its score, transcript and
/// feedback are fixed once the backend is done with it. Attempts still moving
/// through the pipeline are deliberately **not** kept — the recording screen
/// polls the same endpoint waiting for the status to change, and a cached
/// `analyzing` would freeze that poll until it times out.
class SpeakingAttemptStore {
  final Map<String, SpeakingAttempt> _attempts = {};

  /// Keeps [attempt] only if it has reached a terminal status.
  void put(SpeakingAttempt attempt) {
    if (!attempt.status.isTerminal) return;
    _attempts[attempt.id] = attempt;
  }

  SpeakingAttempt? get(String attemptId) => _attempts[attemptId];

  /// Drops everything. Attempts carry the learner's own transcript, so this
  /// runs on logout and account deletion.
  void clear() => _attempts.clear();
}
