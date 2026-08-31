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
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void>? _initializationFuture;

  FlutterLocalNotificationsPlugin get plugin => _notifications;

  Future<void> initialize() {
    return _initializationFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    tz.initializeTimeZones();

    String timezone = await FlutterTimezone.getLocalTimezone();

    if (timezone == 'Asia/Calcutta') {
      timezone = 'Asia/Kolkata';
    }

    tz.setLocalLocation(tz.getLocation(timezone));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _notifications.initialize(settings);
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
    await initialize();
    await cancelEventNotifications(event.id);

    final nextOccurrence = RecurrenceService.getNextOccurrence(event);

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
    }
  }

  Future<void> cancelEventNotifications(String eventId) async {
    await initialize();
    for (final daysBefore in EventConstants.reminderOptions) {
      await _notifications.cancel(_notificationId(eventId, daysBefore));
    }
  }

  Future<void> cancelAllNotifications() async {
    await initialize();
    await _notifications.cancelAll();
  }

  Future<void> rescheduleAllNotifications(List<Event> events) async {
    await initialize();
    for (final event in events) {
      //await cancelEventNotifications(event.id);
      await scheduleEventNotifications(event);
    }
  }
}
