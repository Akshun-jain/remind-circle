import 'package:flutter/material.dart';
import 'package:remind_circle/app/theme.dart';
import 'package:remind_circle/features/auth/presentation/screens/splash_screen.dart';

class RemindCircleApp extends StatelessWidget {
  const RemindCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RemindCircle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      //home: const Scaffold(body: Center(child: Text('RemindCircle'))),
    );
  }
}
