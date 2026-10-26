import 'package:flutter/material.dart';
import 'package:snake_esp_cam_app/Model/app_config.dart';
import 'package:snake_esp_cam_app/Screens/dashboard_page.dart';

void main() => runApp(const CamControlApp());

class CamControlApp extends StatelessWidget {
  const CamControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF26D0B2),
      brightness: Brightness.dark,
      surface: const Color(0xFF151D21),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CAM//CONTROL',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFF0C1114),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0E1518),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      home: DashboardPage(config: AppConfig()),
    );
  }
}
