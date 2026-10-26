import 'package:flutter/material.dart';
import 'package:snake_esp_cam_app/Model/app_config.dart';
import 'package:snake_esp_cam_app/Screens/section_title.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.config});
  final AppConfig config;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _stream;
  late final TextEditingController _server;
  late final TextEditingController _led;
  late final TextEditingController _wifi;
  late final TextEditingController _motor;
  late final TextEditingController _sensors;

  @override
  void initState() {
    super.initState();
    final c = widget.config;
    _stream = TextEditingController(text: c.streamUrl);
    _server = TextEditingController(text: c.controlServer);
    _led = TextEditingController(text: c.ledPath);
    _wifi = TextEditingController(text: c.hotspotPath);
    _motor = TextEditingController(text: c.motorPath);
    _sensors = TextEditingController(text: c.sensorsPath);
  }

  @override
  void dispose() {
    _stream.dispose(); _server.dispose(); _led.dispose(); _wifi.dispose(); _motor.dispose(); _sensors.dispose();
    super.dispose();
  }

  void _save() {
    widget.config.update(streamUrl: _stream.text, controlServer: _server.text, ledPath: _led.text, hotspotPath: _wifi.text, motorPath: _motor.text, sensorsPath: _sensors.text);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection settings saved for this session')));
  }

  Widget _field(String label, TextEditingController controller, {String? hint}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(controller: controller, autocorrect: false, keyboardType: TextInputType.url, decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: const Icon(Icons.link))),
      );

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
        const SectionTitle('Connection settings', subtitle: 'Set the camera address and device API routes'),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          _field('Camera stream URL', _stream, hint: 'http://192.168.4.1/stream'),
          _field('Control server base URL', _server, hint: 'http://192.168.4.1:81'),
          const Divider(height: 24),
          _field('Flash endpoint', _led, hint: '/api/led'),
          _field('Wi-Fi / hotspot endpoint', _wifi, hint: '/api/hotspot'),
          _field('Motor endpoint', _motor, hint: '/api/motor'),
          _field('Sensors endpoint', _sensors, hint: '/api/sensors'),
          const SizedBox(height: 4),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save_outlined), label: const Text('Save settings'))),
        ]))),
        const SizedBox(height: 12),
        const Text('Defaults match the ESP32-CAM sketch: stream at port 80, control APIs at port 81.', style: TextStyle(color: Colors.white54)),
      ]);
}
