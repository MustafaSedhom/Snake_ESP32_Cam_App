import 'package:flutter/material.dart';

import 'package:snake_esp_cam_app/Screens/Splash/Splash_Screen.dart';

void main() => runApp(const CamControlApp());

class CamControlApp extends StatelessWidget {
  const CamControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF26D0B2);

    final lightScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      surface: const Color(0xFFF5F8F8),
    );

    final darkScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF151D21),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Robotics',

      themeMode: ThemeMode.system,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        scaffoldBackgroundColor: const Color(0xFFF5F8F8),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        scaffoldBackgroundColor: const Color(0xFF0C1114),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0E1518),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}
