import 'package:flutter/material.dart';
import 'package:snake_esp_cam_app/Model/app_config.dart';
import 'package:snake_esp_cam_app/Screens/camera_stream_view.dart';
import 'package:snake_esp_cam_app/Screens/motor_dpad.dart';
import 'package:snake_esp_cam_app/Screens/section_title.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.config,
    required this.wifiName,
    required this.wifiConnected,
    required this.streamEnabled,
    required this.onToggleStream,
    required this.brightness,
    required this.onBrightness,
    required this.onBrightnessEnd,
    required this.onMotor,
    required this.busy,
  });
  final AppConfig config;
  final String wifiName;
  final bool wifiConnected, streamEnabled, busy;
  final VoidCallback onToggleStream;
  final double brightness;
  final ValueChanged<double> onBrightness;
  final ValueChanged<double> onBrightnessEnd;
  final ValueChanged<String> onMotor;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
    children: [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LIVE SYSTEM',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 2,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Camera dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _StatusChip(
            connected: wifiConnected,
            label: wifiConnected ? 'ONLINE' : 'OFFLINE',
          ),
        ],
      ),
      const SizedBox(height: 18),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.videocam_rounded, color: Color(0xFF26D0B2)),
                  const SizedBox(width: 9),
                  const Expanded(
                    child: Text(
                      'Camera stream',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    onPressed: onToggleStream,
                    icon: Icon(
                      streamEnabled
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                  ),
                ],
              ),
              CameraStreamView(url: config.streamUrl, enabled: streamEnabled),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.link, size: 16, color: Colors.white54),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      config.streamUrl,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                'Flash brightness',
                subtitle: 'ESP32-CAM onboard LED · GPIO 4',
              ),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: brightness,
                      min: 0,
                      max: 255,
                      divisions: 255,
                      onChanged: onBrightness,
                      onChangeEnd: onBrightnessEnd,
                    ),
                  ),
                  Container(
                    width: 68,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(brightness / 255 * 100).round()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const SectionTitle(
                'Motor pad',
                subtitle: 'Tap a direction to send a command',
              ),
              MotorDpad(onCommand: onMotor, busy: busy),
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      Card(
        child: ListTile(
          leading: Icon(
            wifiConnected ? Icons.wifi : Icons.wifi_off,
            color: wifiConnected
                ? const Color(0xFF26D0B2)
                : Colors.orangeAccent,
          ),
          title: Text(wifiName),
          subtitle: Text(
            wifiConnected
                ? 'Connected Wi-Fi network'
                : 'Connect to the ESP32-CAM hotspot',
          ),
        ),
      ),
    ],
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.connected, required this.label});
  final bool connected;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: connected ? const Color(0x3326D0B2) : const Color(0x33FFB74D),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Icon(
          Icons.circle,
          size: 8,
          color: connected ? const Color(0xFF26D0B2) : Colors.orangeAccent,
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    ),
  );
}
