import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:remind_circle/core/notifications/notification_service.dart';

class NotificationPermission {
  NotificationPermission._();

  static Future<void> request() async {
    final android = NotificationService.instance.plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await android?.requestNotificationsPermission();
  }
}
