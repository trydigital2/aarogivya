import 'dart:async';

class PushNotificationService {
  Stream<dynamic> get foregroundMessages => const Stream.empty();

  Future<void> initialize() async {
    // Local offline mock: no push notification backend needed
  }

  Future<void> syncToken(String userId) async {
    // Local offline mock
  }

  Future<void> unregisterToken() async {
    // Local offline mock
  }
}
