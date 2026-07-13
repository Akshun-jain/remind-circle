import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:remind_circle/app/app.dart';
import 'package:remind_circle/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const RemindCircleApp());
}
