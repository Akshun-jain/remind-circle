import 'dart:developer' as developer;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:remind_circle/core/constants/event_constants.dart';
import 'package:remind_circle/features/events/domain/models/event.dart';
import 'package:remind_circle/core/services/recurrence_service.dart';
import 'package:remind_circle/core/notifications/notification_navigation_service.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  FlutterLocalNotificationsPlugin get plugin => _notifications;

  Future<void>? _initializationFuture;

  Future<void> initialize() {
    return _initializationFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      tz.initializeTimeZones();

      var timezone = await FlutterTimezone.getLocalTimezone();

      if (timezone == 'Asia/Calcutta') {
        timezone = 'Asia/Kolkata';
      }

      tz.setLocalLocation(tz.getLocation(timezone));

      developer.log('Notifications: timezone initialized as ${tz.local.name}');

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');

      const settings = InitializationSettings(android: android);

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (response) {
          final eventId = response.payload;

          if (eventId == null || eventId.trim().isEmpty) {
            developer.log(
              'Notifications: tapped notification has no event payload.',
            );
            return;
          }

          NotificationNavigationService.instance.handleNotificationTap(
            eventId: eventId,
          );
        },
      );
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidPlugin?.requestExactAlarmsPermission();

      // Handle a local notification that launched the app from a
      // completely terminated state.
      final launchDetails = await _notifications
          .getNotificationAppLaunchDetails();

      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final eventId = launchDetails?.notificationResponse?.payload;

        developer.log(
          'Notifications: app launched from local notification. '
          'payload=$eventId',
        );

        if (eventId != null && eventId.trim().isNotEmpty) {
          NotificationNavigationService.instance.handleNotificationTap(
            eventId: eventId,
          );
        } else {
          developer.log(
            'Notifications: launch notification has no event payload.',
          );
        }
      }

      developer.log('Notifications: plugin initialized successfully.');
    } catch (e, stack) {
      developer.log(
        'Notifications: initialization failed.',
        error: e,
        stackTrace: stack,
      );
      rethrow;
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
    final name = event.personName?.trim().isNotEmpty == true
        ? event.personName!
        : event.title;

    final prefix = switch (event.eventType.name) {
      'birthday' => '🎂',
      'anniversary' => '💍',
      'workAnniversary' => '🏆',
      'meeting' => '📅',
      'festival' => '🎉',
      'holiday' => '🌴',
      _ => '📅',
    };

    final timing = daysBefore == 0
        ? 'Today'
        : 'in $daysBefore day${daysBefore == 1 ? '' : 's'}';

    return '$prefix $name — $timing';
  }

  String _notificationBody(Event event, int daysBefore, {String? groupName}) {
    final date = _formatEventDate(event.eventDate);
    final eventType = _formatEventType(event.eventType.name);

    final details = [
      date,
      if (event.eventTime != null) _formatEventTime(event.eventTime!),
      eventType,
      if (groupName?.trim().isNotEmpty ?? false) groupName!.trim(),
    ].join(' • ');

    return details;
  }

  String _formatEventDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)}';
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month];
  }

  String _formatEventTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String _formatEventType(String eventType) {
    switch (eventType) {
      case 'birthday':
        return 'Birthday';
      case 'anniversary':
        return 'Anniversary';
      case 'workAnniversary':
        return 'Work Anniversary';
      case 'meeting':
        return 'Meeting';
      case 'festival':
        return 'Festival';
      case 'holiday':
        return 'Holiday';
      case 'custom':
        return 'Custom';
      case 'other':
        return 'Other';
      default:
        return eventType.isEmpty
            ? 'Event'
            : eventType[0].toUpperCase() + eventType.substring(1);
    }
  }

  Future<void> scheduleEventNotifications(
    Event event, {
    String? groupName,
  }) async {
    await initialize();

    developer.log(
      'Notifications: scheduling event '
      'id=${event.id}, '
      'title="${event.title}", '
      'person="${event.personName}", '
      'type=${event.eventType.name}, '
      'notifyBefore=${event.notifyBefore}, '
      'eventDate=${event.eventDate}, '
      'eventTime=${event.eventTime}, '
      'group="$groupName"',
    );

    // Remove previous schedules for this event before recreating them.
    await cancelEventNotifications(event.id);

    final nextOccurrence = RecurrenceService.getNextOccurrence(event);

    if (nextOccurrence == null) {
      developer.log(
        'Notifications: no next occurrence for event ${event.id}. '
        'No notifications scheduled.',
      );
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    final occurrence = tz.TZDateTime.from(nextOccurrence, tz.local);

    developer.log(
      'Notifications: event ${event.id} '
      'nextOccurrence=$occurrence '
      'now=$now '
      'timezone=${tz.local.name}',
    );

    var scheduledCount = 0;

    for (final daysBefore in event.notifyBefore) {
      final notificationTime = occurrence.subtract(Duration(days: daysBefore));

      final notificationId = _notificationId(event.id, daysBefore);

      const androidDetails = AndroidNotificationDetails(
        'event_channel',
        'Event Reminders',
        channelDescription: 'Reminders for upcoming events',
        importance: Importance.max,
        priority: Priority.high,
      );

      const details = NotificationDetails(android: androidDetails);

      developer.log(
        'Notifications: preparing schedule '
        'event=${event.id}, '
        'notificationId=$notificationId, '
        'daysBefore=$daysBefore, '
        'notificationTime=$notificationTime, '
        'now=$now',
      );

      if (!notificationTime.isAfter(now)) {
        developer.log(
          'Notifications: SKIPPED notificationId=$notificationId '
          'because notification time is not in the future.',
        );
        continue;
      }

      try {
        await _notifications.zonedSchedule(
          notificationId,
          _notificationTitle(event, daysBefore),
          _notificationBody(event, daysBefore, groupName: groupName),
          notificationTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: event.id,
        );

        scheduledCount++;

        developer.log(
          'Notifications: SCHEDULED successfully '
          'notificationId=$notificationId '
          'event=${event.id} '
          'at=$notificationTime',
        );
      } catch (e, stack) {
        developer.log(
          'Notifications: FAILED to schedule '
          'notificationId=$notificationId '
          'event=${event.id}',
          error: e,
          stackTrace: stack,
        );
      }
    }

    developer.log(
      'Notifications: scheduling finished for event ${event.id}. '
      'scheduledCount=$scheduledCount '
      'requestedCount=${event.notifyBefore.length}',
    );

    // Diagnostic verification: ask Android what is actually pending.
    try {
      final pending = await _notifications.pendingNotificationRequests();

      final eventPending = pending
          .where((notification) => notification.payload == event.id)
          .toList();

      developer.log(
        'Notifications: PENDING CHECK '
        'event=${event.id}, '
        'totalPending=${pending.length}, '
        'eventPending=${eventPending.length}',
      );

      for (final notification in eventPending) {
        developer.log(
          'Notifications: pending '
          'id=${notification.id}, '
          'title="${notification.title}", '
          'body="${notification.body}", '
          'payload="${notification.payload}"',
        );
      }
    } catch (e, stack) {
      developer.log(
        'Notifications: failed to inspect pending notifications.',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'event_channel',
      'Event Reminders',
      channelDescription: 'Reminders for upcoming events',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(id, title, body, details, payload: payload);

    developer.log(
      'Notifications: immediate notification shown '
      'id=$id title="$title"',
    );
  }

  Future<void> cancelEventNotifications(String eventId) async {
    await initialize();

    for (final daysBefore in EventConstants.reminderOptions) {
      final id = _notificationId(eventId, daysBefore);
      await _notifications.cancel(id);
    }

    developer.log(
      'Notifications: cancelled existing notifications '
      'for event $eventId',
    );
  }

  Future<void> cancelAllNotifications() async {
    await initialize();
    await _notifications.cancelAll();

    developer.log('Notifications: all notifications cancelled.');
  }

  Future<void> rescheduleAllNotifications(List<Event> events) async {
    await initialize();

    developer.log(
      'Notifications: rescheduling ${events.length} active events.',
    );

    for (final event in events) {
      try {
        await scheduleEventNotifications(event);
      } catch (e, stack) {
        developer.log(
          'Notifications: failed to reschedule event ${event.id}.',
          error: e,
          stackTrace: stack,
        );
      }
    }
  }
}
