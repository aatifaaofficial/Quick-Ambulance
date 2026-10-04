import 'dart:async';

import '../models/notification_item.dart';

class NotificationService {
  final StreamController<List<AppNotificationItem>> _controller =
      StreamController<List<AppNotificationItem>>.broadcast();

  Stream<List<AppNotificationItem>> get notifications => _controller.stream;

  void emit(List<AppNotificationItem> items) {
    _controller.add(items);
  }

  void dispose() {
    _controller.close();
  }
}
