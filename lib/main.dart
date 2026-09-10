import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind_circle/app/app.dart';
import 'package:remind_circle/firebase_options.dart';

import 'package:remind_circle/core/notifications/notification_permission.dart';
import 'package:remind_circle/core/notifications/notification_service.dart';
import 'package:remind_circle/core/services/firestore_service.dart';
//import 'package:remind_circle/features/events/data/repositories/firestore_event_repository.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:remind_circle/features/home/data/repositories/firestore_home_repository.dart';
import 'package:remind_circle/core/notifications/fcm_service.dart';

import 'package:remind_circle/core/notifications/notification_navigation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Firebase is required by the app's providers, so it remains a startup
  // prerequisite. Notification setup and rescheduling are non-critical startup
  // work and should not block the first frame.
  NotificationNavigationService.instance.beginStartupCheck();

  runApp(ProviderScope(child: RemindCircleApp()));

  // Finish notification setup in the background after the app is visible.
  unawaited(_initializeNotificationsInBackground());
}

Future<void> _initializeNotificationsInBackground() async {
  bool notificationLaunch = false;

  try {
    await NotificationService.instance.initialize();
    await NotificationPermission.request();

    // Initialize FCM notification-tap handling before checking auth.
    // This is required for notification taps that launch a completely
    // terminated app.
    await FcmService.instance.initialize();

    // At this point both local-notification and FCM launch details
    // have been checked.
    notificationLaunch =
        NotificationNavigationService.instance.hasPendingNavigation;

    NotificationNavigationService.instance.completeStartupCheck(
      notificationLaunch: notificationLaunch,
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final homeRepository = FirestoreHomeRepository(FirestoreService());
    final events = await homeRepository.allActiveEvents(user.uid);
    await NotificationService.instance.rescheduleAllNotifications(events);
  } catch (e, stack) {
    debugPrint('Failed to initialize/reschedule notifications: $e');
    debugPrintStack(stackTrace: stack);

    // Never leave SplashScreen waiting forever if notification setup fails.
    NotificationNavigationService.instance.completeStartupCheck(
      notificationLaunch: notificationLaunch,
    );
  }
}
