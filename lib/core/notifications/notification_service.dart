import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:remind_circle/features/events/domain/models/event.dart';
//import 'package:intl/intl.dart';
import 'package:remind_circle/core/services/recurrence_service.dart';
import 'package:remind_circle/core/constants/event_constants.dart';
//import 'package:remind_circle/features/events/data/repositories/event_repository.dart';
//import 'package:remind_circle/features/events/domain/models/event.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  FlutterLocalNotificationsPlugin get plugin => _notifications;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    String timezone = await FlutterTimezone.getLocalTimezone();

    if (timezone == 'Asia/Calcutta') {
      timezone = 'Asia/Kolkata';
    }
    //print('Local timezone: $timezone');
    //tz.setLocalLocation(tz.getLocation(timezone));

    tz.setLocalLocation(tz.getLocation(timezone));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _notifications.initialize(settings);
  }

  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Testing notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      1,
      '🎉 RemindCircle',
      'Notifications are working!',
      details,
    );
  }

  Future<void> scheduleTestNotification() async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduled = now.add(const Duration(seconds: 5));

    //print('Timezone: ${tz.local.name}');
    //print('Now: $now');
    //print('Scheduled: $scheduled');

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Testing notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      2,
      '⏰ Scheduled Notification',
      'This appeared after 5 seconds!',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'test',
    );

    //print('Scheduled successfully');
  }

  Future<void> debugPendingNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();

    debugPrint('PENDING NOTIFICATIONS - Count: ${pending.length}');

    for (final notification in pending) {
      debugPrint(
        'PENDING NOTIFICATION - '
        'ID: ${notification.id}, '
        'Title: ${notification.title}, '
        'Payload: ${notification.payload}',
      );
    }
  }

  int _notificationId(String eventId, int daysBefore) {
    var hash = 0;

    for (final codeUnit in eventId.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }

    return (hash * 31 + daysBefore) & 0x7fffffff;
  }

  String _notificationTitle(Event event, int daysBefore) {
    final name = event.personName ?? event.title;

    if (daysBefore == 0) {
      switch (event.eventType.name) {
        case 'birthday':
          return '🎂 $name Today';
        case 'anniversary':
          return '💍 $name Today';
        default:
          return '📅 $name Today';
      }
    }

    return '⏰ $name in $daysBefore day${daysBefore == 1 ? '' : 's'}';
  }

  String _notificationBody(Event event, int daysBefore) {
    if (daysBefore == 0) {
      switch (event.eventType.name) {
        case 'birthday':
          return "Don't forget to wish them!";
        case 'anniversary':
          return "Celebrate this special day!";
        default:
          return "Today's reminder.";
      }
    }

    return 'Upcoming reminder.';
  }

  Future<void> scheduleEventNotifications(Event event) async {
    final nextOccurrence = RecurrenceService.getNextOccurrence(event);

    debugPrint('NOTIFICATION DEBUG - Event ID: ${event.id}');
    debugPrint('NOTIFICATION DEBUG - Event time: ${event.eventTime}');
    debugPrint('NOTIFICATION DEBUG - Now: ${DateTime.now()}');
    debugPrint('NOTIFICATION DEBUG - Next occurrence: $nextOccurrence');
    debugPrint('NOTIFICATION DEBUG - Reminders: ${event.notifyBefore}');

    if (nextOccurrence == null) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'event_channel',
      'Event Reminders',
      channelDescription: 'Reminders for upcoming events',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    for (final daysBefore in event.notifyBefore) {
      final notificationTime = tz.TZDateTime.from(
        nextOccurrence,
        tz.local,
      ).subtract(Duration(days: daysBefore));

      if (notificationTime.isBefore(tz.TZDateTime.now(tz.local))) {
        continue;
      }

      await _notifications.zonedSchedule(
        _notificationId(event.id, daysBefore),
        _notificationTitle(event, daysBefore),
        _notificationBody(event, daysBefore),
        notificationTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: event.id,
      );

      debugPrint(
        'Scheduled ${event.id} ($daysBefore days before) at $notificationTime',
      );
    }
  }

  Future<void> cancelEventNotifications(String eventId) async {
    for (final daysBefore in EventConstants.reminderOptions) {
      await _notifications.cancel(_notificationId(eventId, daysBefore));
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> rescheduleAllNotifications(List<Event> events) async {
    for (final event in events) {
      await cancelEventNotifications(event.id);
      await scheduleEventNotifications(event);
    }
  }
}
