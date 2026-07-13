import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      colorSchemeSeed: Colors.indigo,

      brightness: Brightness.light,

      scaffoldBackgroundColor: Colors.white,

      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    );
  }
}
