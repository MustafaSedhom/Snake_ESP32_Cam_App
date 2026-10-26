import 'package:flutter/material.dart';
import 'package:snake_esp_cam_app/Model/app_config.dart';
import 'package:snake_esp_cam_app/Screens/motor_dpad.dart';
import 'package:snake_esp_cam_app/Screens/section_title.dart';


class ControlPage extends StatelessWidget {
  const ControlPage({super.key, required this.config, required this.onMotor, required this.busy});
  final AppConfig config;
  final ValueChanged<String> onMotor;
  final bool busy;

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
        const SectionTitle('Motor control', subtitle: 'Directional commands for your robot'),
        Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Column(children: [
          const Icon(Icons.gamepad_rounded, size: 34, color: Color(0xFF26D0B2)),
          const SizedBox(height: 20),
          MotorDpad(onCommand: onMotor, busy: busy),
          const SizedBox(height: 18),
          OutlinedButton.icon(onPressed: busy ? null : () => onMotor('stop'), icon: const Icon(Icons.stop_circle_outlined), label: const Text('STOP')),
        ]))),
        const SizedBox(height: 14),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Command API', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(config.motorUrl, style: const TextStyle(color: Colors.white60)),
          const SizedBox(height: 8),
          const Text('Sends JSON: {"command":"forward"} etc. The ESP32 firmware must implement this endpoint.', style: TextStyle(color: Colors.white54)),
        ]))),
      ]);
}
