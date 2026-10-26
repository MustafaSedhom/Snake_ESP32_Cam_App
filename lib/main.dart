import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';

void main() {
  runApp(const CamControlApp());
}

class CamControlApp extends StatelessWidget {
  const CamControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ESP32 Camera Control',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF13A89E),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101719),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // ESP32-CAM stream is on port 80. Its control API is on port 81.
  static const String cameraHost = '192.168.4.1';
  static const String streamUrl = 'http://$cameraHost/stream';
  static const String controlBaseUrl = 'http://$cameraHost:81';

  // These two endpoints are placeholders. Add matching APIs to your ESP32
  // firmware before expecting the motor and sensor cards to receive data.
  static const String motorApi = '$controlBaseUrl/api/motor';
  static const String sensorsApi = '$controlBaseUrl/api/sensors';

  final NetworkInfo _networkInfo = NetworkInfo();

  int _selectedTab = 0;
  String _wifiName = 'Checking Wi-Fi...';
  bool _wifiConnected = false;
  bool _streamEnabled = true;
  bool _busy = false;

  double _leftMotor = 0;
  double _rightMotor = 0;

  double? _temperature;
  double? _humidity;
  double? _gas;

  Timer? _sensorTimer;

  @override
  void initState() {
    super.initState();
    _refreshWifi();
    _refreshSensors();
    _sensorTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _refreshSensors(),
    );
  }

  @override
  void dispose() {
    _sensorTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshWifi() async {
    try {
      final name = await _networkInfo.getWifiName();
      if (!mounted) return;

      setState(() {
        _wifiName = name?.replaceAll('"', '') ?? 'Wi-Fi name unavailable';
        _wifiConnected = name != null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _wifiName = 'Wi-Fi name unavailable';
        _wifiConnected = false;
      });
    }
  }

  Future<void> _setLed(int brightness) async {
    await _postJson(
      '$controlBaseUrl/api/led',
      {'brightness': brightness},
      successMessage: 'Flash brightness updated',
    );
  }

  Future<void> _setMotor(String side, double value) async {
    final roundedValue = value.round();

    await _postJson(
      motorApi,
      {'motor': side, 'speed': roundedValue},
      successMessage: '$side motor updated',
    );
  }

  Future<void> _postJson(
    String url,
    Map<String, dynamic> body, {
    String? successMessage,
  }) async {
    setState(() => _busy = true);

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 4));

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (successMessage != null) {
          _showMessage(successMessage);
        }
      } else {
        _showMessage('Request failed (${response.statusCode})');
      }
    } on TimeoutException {
      if (mounted) _showMessage('Connection timed out. Check the ESP32 Wi-Fi.');
    } catch (error) {
      if (mounted) _showMessage('Could not connect: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refreshSensors() async {
    try {
      final response = await http
          .get(Uri.parse(sensorsApi))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (!mounted) return;

      setState(() {
        _temperature = (data['temperature'] as num?)?.toDouble();
        _humidity = (data['humidity'] as num?)?.toDouble();
        _gas = (data['gas'] as num?)?.toDouble();
      });
    } catch (_) {
      // The sensor API may not be implemented yet.
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openWifiSettings() {
    _showMessage(
      'Join the ESP32-CAM Wi-Fi in your phone settings, then return here.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomePage(),
      _buildSettingsPage(),
      _buildWifiPage(),
      _buildControlPage(),
      _buildSensorsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cam Control'),
        actions: [
          Icon(
            _wifiConnected ? Icons.wifi : Icons.wifi_off,
            color: _wifiConnected ? Colors.greenAccent : Colors.orangeAccent,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                _wifiName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(child: pages[_selectedTab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          setState(() => _selectedTab = index);
          if (index == 2) _refreshWifi();
          if (index == 4) _refreshSensors();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
          NavigationDestination(
            icon: Icon(Icons.wifi_outlined),
            selectedIcon: Icon(Icons.wifi),
            label: 'Wi-Fi',
          ),
          NavigationDestination(
            icon: Icon(Icons.gamepad_outlined),
            selectedIcon: Icon(Icons.gamepad),
            label: 'Control',
          ),
          NavigationDestination(
            icon: Icon(Icons.sensors_outlined),
            selectedIcon: Icon(Icons.sensors),
            label: 'Sensors',
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildWifiStatusCard(),
        const SizedBox(height: 16),
        _buildStreamCard(),
        const SizedBox(height: 16),
        _buildQuickMotorControls(),
        const SizedBox(height: 16),
        _buildFlashCard(),
      ],
    );
  }

  Widget _buildWifiStatusCard() {
    return Card(
      child: ListTile(
        leading: Icon(
          _wifiConnected ? Icons.wifi : Icons.wifi_off,
          color: _wifiConnected ? Colors.greenAccent : Colors.orangeAccent,
        ),
        title: Text(_wifiConnected ? 'Wi-Fi connected' : 'Wi-Fi status'),
        subtitle: Text(_wifiName),
        trailing: IconButton(
          tooltip: 'Refresh Wi-Fi',
          onPressed: _refreshWifi,
          icon: const Icon(Icons.refresh),
        ),
      ),
    );
  }

  Widget _buildStreamCard() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: const Text('Live camera'),
            trailing: IconButton(
              tooltip: _streamEnabled ? 'Stop stream' : 'Start stream',
              onPressed: () {
                setState(() => _streamEnabled = !_streamEnabled);
              },
              icon: Icon(
                _streamEnabled ? Icons.pause_circle : Icons.play_circle,
              ),
            ),
          ),
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: _streamEnabled
                  ? Mjpeg(
                      stream: streamUrl,
                      isLive: true,
                      fit: BoxFit.contain,
                      timeout: const Duration(seconds: 10),
                      loading: (context) => const CircularProgressIndicator(),
                      error: (context, error, stack) => const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Stream unavailable. Connect to ESP32-CAM Wi-Fi.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : const Text('Stream paused'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Camera stream: http://192.168.4.1/stream',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMotorControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Motor controls', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _motorSlider('Left motor', _leftMotor, (value) {
              setState(() => _leftMotor = value);
            }),
            _motorSlider('Right motor', _rightMotor, (value) {
              setState(() => _rightMotor = value);
            }),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _busy
                    ? null
                    : () async {
                        await _setMotor('left', _leftMotor);
                        await _setMotor('right', _rightMotor);
                      },
                icon: const Icon(Icons.send),
                label: const Text('Send motor speeds'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _motorSlider(
    String title,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title: ${value.round()}%'),
        Slider(
          value: value,
          min: -100,
          max: 100,
          divisions: 40,
          label: '${value.round()}%',
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildFlashCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Camera flash', style: Theme.of(context).textTheme.titleLarge),
            Slider(
              value: 0,
              min: 0,
              max: 255,
              divisions: 255,
              label: '0',
              onChanged: (value) => _setLed(value.round()),
            ),
            const Text('Flash API: /api/led on port 81'),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const ListTile(
          leading: Icon(Icons.videocam),
          title: Text('Camera stream'),
          subtitle: Text(streamUrl),
        ),
        const ListTile(
          leading: Icon(Icons.settings_ethernet),
          title: Text('Control API'),
          subtitle: Text(controlBaseUrl),
        ),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Motor and sensor APIs'),
          subtitle: Text(
            'Set the endpoint paths to match your ESP32 firmware.',
          ),
        ),
      ],
    );
  }

  Widget _buildWifiPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Wi-Fi settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.wifi),
            title: const Text('Connected network'),
            subtitle: Text(_wifiName),
            trailing: IconButton(
              onPressed: _refreshWifi,
              icon: const Icon(Icons.refresh),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _openWifiSettings,
          icon: const Icon(Icons.settings),
          label: const Text('Connect to ESP32-CAM Wi-Fi'),
        ),
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Connect to the ESP32-CAM hotspot in your phone Wi-Fi settings. '
            'Default network: ESP32-CAM. Return to this app after connecting.',
          ),
        ),
      ],
    );
  }

  Widget _buildControlPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Motor control',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _motorSlider('Left motor', _leftMotor, (value) {
          setState(() => _leftMotor = value);
        }),
        _motorSlider('Right motor', _rightMotor, (value) {
          setState(() => _rightMotor = value);
        }),
        FilledButton.icon(
          onPressed: _busy
              ? null
              : () async {
                  await _setMotor('left', _leftMotor);
                  await _setMotor('right', _rightMotor);
                },
          icon: const Icon(Icons.send),
          label: const Text('Send motor speeds'),
        ),
        const SizedBox(height: 16),
        const Text(
          'This page sends JSON to /api/motor. Add that endpoint to the ESP32 '
          'firmware and adapt the JSON fields if your motor controller uses '
          'a different API.',
        ),
      ],
    );
  }

  Widget _buildSensorsPage() {
    return RefreshIndicator(
      onRefresh: _refreshSensors,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Sensors',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _sensorCard(
            'Temperature',
            _temperature == null ? '--' : '${_temperature!.toStringAsFixed(1)} °C',
            Icons.thermostat,
          ),
          _sensorCard(
            'Humidity',
            _humidity == null ? '--' : '${_humidity!.toStringAsFixed(1)}%',
            Icons.water_drop_outlined,
          ),
          _sensorCard(
            'Gas',
            _gas == null ? '--' : _gas!.toStringAsFixed(0),
            Icons.air,
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Expected sensor JSON from /api/sensors: '
              '{"temperature":24.5,"humidity":55,"gas":120}.',
            ),
          ),
          OutlinedButton.icon(
            onPressed: _refreshSensors,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh readings'),
          ),
        ],
      ),
    );
  }

  Widget _sensorCard(String label, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}