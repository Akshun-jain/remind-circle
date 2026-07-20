import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind_circle/app/app.dart';
import 'package:remind_circle/firebase_options.dart';

import 'package:remind_circle/core/notifications/notification_permission.dart';
import 'package:remind_circle/core/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService.instance.initialize();

  await NotificationPermission.request();

  runApp(const ProviderScope(child: RemindCircleApp()));
}
