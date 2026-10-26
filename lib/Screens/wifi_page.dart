import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:snake_esp_cam_app/Model/app_config.dart';
import 'package:snake_esp_cam_app/Screens/device_api.dart';
import 'package:snake_esp_cam_app/Screens/section_title.dart';


class WifiPage extends StatefulWidget {
  const WifiPage({super.key, required this.config});
  final AppConfig config;
  @override
  State<WifiPage> createState() => _WifiPageState();
}

class _WifiPageState extends State<WifiPage> {
  final _info = NetworkInfo();
  late final _ssid = TextEditingController(text: 'ESP32-CAM');
  late final _password = TextEditingController();
  String _connected = 'Checking network…';
  bool _busy = false;

  @override
  void initState() { super.initState(); _refresh(); }

  @override
  void dispose() { _ssid.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _refresh() async {
    try {
      final name = await _info.getWifiName();
      if (mounted) setState(() => _connected = name?.replaceAll('"', '') ?? 'Wi-Fi name unavailable');
    } catch (_) {
      if (mounted) setState(() => _connected = 'Wi-Fi name unavailable');
    }
  }

  Future<void> _apply() async {
    if (_ssid.text.trim().isEmpty || _password.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter an SSID and a password of at least 8 characters.')));
      return;
    }
    setState(() => _busy = true);
    try {
      await DeviceApi(widget.config).postJson(widget.config.hotspotUrl, {'ssid': _ssid.text.trim(), 'password': _password.text});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hotspot restarting. Reconnect using the new name and password.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update hotspot: $e')));
    } finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
        const SectionTitle('Wi-Fi', subtitle: 'Your phone connects directly to the ESP32 hotspot'),
        Card(child: ListTile(leading: const Icon(Icons.wifi, color: Color(0xFF26D0B2)), title: const Text('Phone network'), subtitle: Text(_connected), trailing: IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)))),
        const SizedBox(height: 14),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Configure ESP32 hotspot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 14),
          TextField(controller: _ssid, decoration: const InputDecoration(labelText: 'Hotspot name (SSID)', prefixIcon: Icon(Icons.wifi))),
          const SizedBox(height: 12),
          TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'New hotspot password', helperText: 'At least 8 characters', prefixIcon: Icon(Icons.lock_outline))),
          const SizedBox(height: 14),
          FilledButton.icon(onPressed: _busy ? null : _apply, icon: const Icon(Icons.restart_alt), label: Text(_busy ? 'Applying…' : 'Apply and restart hotspot')),
          const SizedBox(height: 8),
          Text('API: ${widget.config.hotspotUrl}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
        ]))),
        const Padding(padding: EdgeInsets.only(top: 14), child: Text('Changing hotspot settings disconnects this phone. Join the updated ESP32-CAM Wi-Fi again in Android settings.', style: TextStyle(color: Colors.white54))),
      ]);
}
