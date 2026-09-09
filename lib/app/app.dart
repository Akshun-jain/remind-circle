import 'package:flutter/material.dart';
import 'package:remind_circle/app/theme.dart';
import 'package:remind_circle/core/notifications/notification_navigation_service.dart';
import 'package:remind_circle/features/auth/presentation/screens/splash_screen.dart';

class RemindCircleApp extends StatelessWidget {
  RemindCircleApp({super.key});

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    NotificationNavigationService.instance.attachNavigatorKey(_navigatorKey);

    return MaterialApp(
      title: 'RemindCircle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: _navigatorKey,
      home: const SplashScreen(),
    );
  }
}
