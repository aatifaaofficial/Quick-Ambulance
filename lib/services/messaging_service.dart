import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../config/firebase_config.dart';
import 'firebase_service.dart';

class MessagingService {
  static Future<NotificationSettings> requestPermission() {
    return FirebaseService.messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Stream<RemoteMessage> get foregroundMessages =>
      FirebaseMessaging.onMessage;

  static Future<String?> getToken({String? webVapidKey}) async {
    if (kIsWeb &&
        (webVapidKey ?? FirebaseConfig.webVapidKey).isEmpty) {
      throw StateError(
        'Firebase Web Push requires FIREBASE_WEB_VAPID_KEY to be configured.',
      );
    }
    final vapidKey = webVapidKey ?? FirebaseConfig.webVapidKey;
    if (kIsWeb) {
      return FirebaseService.messaging.getToken(vapidKey: vapidKey);
    }
    return FirebaseService.messaging.getToken();
  }
}
