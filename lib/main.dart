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

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('FIREBASE PROJECT: ${Firebase.app().options.projectId}');

  debugPrint('FIREBASE APP ID: ${Firebase.app().options.appId}');

  debugPrint(
    'FIRESTORE DATABASE: ${FirebaseFirestore.instance.app.options.projectId}',
  );

  await NotificationService.instance.initialize();

  await NotificationPermission.request();

  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    try {
      final homeRepository = FirestoreHomeRepository(FirestoreService());

      final events = await homeRepository.allActiveEvents(user.uid);

      //await NotificationService.instance.cancelAllNotifications();

      await NotificationService.instance.rescheduleAllNotifications(events);
    } catch (e, stack) {
      debugPrint('Failed to reschedule notifications: $e');
      debugPrintStack(stackTrace: stack);
    }
  }

  //await NotificationService.instance.scheduleTestNotification();

  //await NotificationService.instance.debugPendingNotifications();

  runApp(const ProviderScope(child: RemindCircleApp()));
}
