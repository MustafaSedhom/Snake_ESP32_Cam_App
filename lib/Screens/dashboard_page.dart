import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snake_esp_cam_app/Model/app_config.dart';
import 'package:snake_esp_cam_app/Screens/Home/Home_Screen.dart';
import 'package:snake_esp_cam_app/Screens/Setting/settings_page.dart';
import 'package:snake_esp_cam_app/Screens/device_api.dart';

import 'control_page.dart';

import 'sensors_page.dart';
import 'wifi_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.config});
  final AppConfig config;
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _network = NetworkInfo();
  int _tab = 0;
  String _wifiName = 'Checking Wi-Fi…';
  bool _wifiConnected = false;
  bool _streamEnabled = true;
  bool _busy = false;
  double _brightness = 0;
  double? _temperature, _humidity, _gas;
  Timer? _sensorTimer;

  DeviceApi get _api => DeviceApi(widget.config);

  @override
  void initState() {
    super.initState();
    _refreshWifi();
    _refreshSensors();
    _sensorTimer = Timer.periodic(const Duration(seconds: 8), (_) => _refreshSensors());
  }

  @override
  void dispose() { _sensorTimer?.cancel(); super.dispose(); }

  Future<void> _refreshWifi() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await Permission.locationWhenInUse.request();
      }
      final name = await _network.getWifiName();
      if (!mounted) return;
      setState(() { _wifiName = name?.replaceAll('"', '') ?? 'Wi-Fi name unavailable'; _wifiConnected = name != null; });
    } catch (_) { if (mounted) setState(() { _wifiName = 'Wi-Fi name unavailable'; _wifiConnected = false; }); }
  }

  Future<void> _refreshSensors() async {
    try {
      final data = await _api.getJson(widget.config.sensorsUrl);
      if (!mounted) return;
      setState(() {
        _temperature = (data['temperature'] as num?)?.toDouble();
        _humidity = (data['humidity'] as num?)?.toDouble();
        _gas = (data['gas'] as num?)?.toDouble();
      });
    } catch (_) { /* The sensor endpoint is optional until firmware supports it. */ }
  }

  Future<void> _setBrightness(double value) async {
    setState(() => _brightness = value);
    try {
      await _api.postJson(widget.config.ledUrl, {'brightness': value.round()});
    } catch (e) { _message('Flash request failed: $e'); }
  }

  Future<void> _motorCommand(String command) async {
    setState(() => _busy = true);
    try {
      await _api.postJson(widget.config.motorUrl, {'command': command});
      if (mounted) _message('Motor command: $command');
    } catch (e) { if (mounted) _message('Motor API error: $e'); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(config: widget.config, wifiName: _wifiName, wifiConnected: _wifiConnected, streamEnabled: _streamEnabled, onToggleStream: () => setState(() => _streamEnabled = !_streamEnabled), brightness: _brightness, onBrightness: (v) => setState(() => _brightness = v), onBrightnessEnd: _setBrightness, onMotor: _motorCommand, busy: _busy),
      SettingsPage(config: widget.config),
      WifiPage(config: widget.config),
      ControlPage(config: widget.config, onMotor: _motorCommand, busy: _busy),
      SensorsPage(temperature: _temperature, humidity: _humidity, gas: _gas, onRefresh: _refreshSensors),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('CAM//CONTROL', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        actions: [
          Icon(_wifiConnected ? Icons.wifi_rounded : Icons.wifi_off_rounded, color: _wifiConnected ? const Color(0xFF26D0B2) : Colors.orangeAccent),
          const SizedBox(width: 7),
          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 140), child: Text(_wifiName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(child: IndexedStack(index: _tab, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) { setState(() => _tab = i); if (i == 2) _refreshWifi(); if (i == 4) _refreshSensors(); },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.tune_rounded), label: 'Settings'),
          NavigationDestination(icon: Icon(Icons.wifi_outlined), selectedIcon: Icon(Icons.wifi), label: 'Wi-Fi'),
          NavigationDestination(icon: Icon(Icons.gamepad_outlined), selectedIcon: Icon(Icons.gamepad_rounded), label: 'Control'),
          NavigationDestination(icon: Icon(Icons.sensors_outlined), selectedIcon: Icon(Icons.sensors), label: 'Sensors'),
        ],
      ),
    );
  }
}
