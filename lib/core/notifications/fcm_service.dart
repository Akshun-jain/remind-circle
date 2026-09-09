import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:remind_circle/core/notifications/notification_service.dart';

import 'package:remind_circle/core/notifications/notification_navigation_service.dart';

class FcmService {
  FcmService._();

  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    try {
      // Handle notification taps when the app was in the background.
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        final eventId = message.data['eventId'];
        final groupId = message.data['groupId'];

        if (eventId == null || eventId.toString().trim().isEmpty) {
          developer.log('FCM: Opened notification has no eventId.');
          return;
        }

        NotificationNavigationService.instance.handleNotificationTap(
          eventId: eventId.toString(),
          groupId: groupId?.toString(),
        );
      });

      // Handle a notification tap that launched the app from a terminated state.
      developer.log('FCM DEBUG: Checking getInitialMessage()...');

      final initialMessage = await _messaging.getInitialMessage();

      if (initialMessage == null) {
        developer.log('FCM DEBUG: getInitialMessage() returned NULL.');
      } else {
        developer.log(
          'FCM DEBUG: getInitialMessage() RECEIVED. '
          'data=${initialMessage.data}',
        );

        final eventId = initialMessage.data['eventId'];
        final groupId = initialMessage.data['groupId'];

        developer.log('FCM DEBUG: initial eventId=$eventId, groupId=$groupId');

        if (eventId != null && eventId.toString().trim().isNotEmpty) {
          developer.log(
            'FCM DEBUG: Sending initial notification to navigation service.',
          );

          NotificationNavigationService.instance.handleNotificationTap(
            eventId: eventId.toString(),
            groupId: groupId?.toString(),
          );
        } else {
          developer.log('FCM DEBUG: Initial notification has NO eventId.');
        }
      }

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        developer.log('FCM: No signed-in user.');
        return;
      }

      // Request notification permission.
      await _messaging.requestPermission(alert: true, badge: true, sound: true);

      // Get the device's FCM token.
      final token = await _messaging.getToken();

      if (token == null || token.isEmpty) {
        developer.log('FCM: Could not obtain device token.');
        return;
      }

      // Store this device token on the user's profile.
      await _firestore.collection('users').doc(user.uid).set({
        'fcmTokens': FieldValue.arrayUnion([token]),
      }, SetOptions(merge: true));

      developer.log('FCM: Device token registered.');

      // If Firebase rotates the token, update Firestore.
      _messaging.onTokenRefresh.listen((newToken) async {
        try {
          await _firestore.collection('users').doc(user.uid).set({
            'fcmTokens': FieldValue.arrayUnion([newToken]),
          }, SetOptions(merge: true));

          developer.log('FCM: Refreshed device token registered.');
        } catch (e, stack) {
          developer.log(
            'FCM: Failed to save refreshed token.',
            error: e,
            stackTrace: stack,
          );
        }
      });

      // Handle messages while the app is in the foreground.
      FirebaseMessaging.onMessage.listen((message) async {
        final notification = message.notification;

        if (notification == null) {
          return;
        }

        developer.log(
          'FCM: Foreground message received: ${notification.title}',
        );

        final eventId = message.data['eventId'];
        await NotificationService.instance.showImmediateNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
          title: notification.title ?? 'RemindCircle',
          body: notification.body ?? 'You have a new group event.',
          payload: eventId,
        );
      });
    } catch (e, stack) {
      developer.log('FCM initialization failed.', error: e, stackTrace: stack);
    }
  }

  Future<void> unregister() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      final token = await _messaging.getToken();

      if (token == null || token.isEmpty) {
        return;
      }

      await _firestore.collection('users').doc(user.uid).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });

      developer.log('FCM: Device token removed.');
    } catch (e, stack) {
      developer.log(
        'FCM: Failed to remove device token.',
        error: e,
        stackTrace: stack,
      );
    }
  }
}
