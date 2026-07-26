import 'dart:async';

/// Announces that the session died and could not be revived.
///
/// The route guard only runs on navigation, so once the user is already inside
/// the app nothing re-checks their tokens. This lets the layer that discovers
/// the dead session — the token interceptor — push them back to login from
/// wherever they are standing.
class SessionEvents {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get onExpired => _controller.stream;

  void notifyExpired() {
    if (!_controller.isClosed) _controller.add(null);
  }

  Future<void> dispose() => _controller.close();
}
