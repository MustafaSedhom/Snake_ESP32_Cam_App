import 'package:flutter/material.dart';
import 'package:snake_esp_cam_app/Screens/section_title.dart';


class SensorsPage extends StatelessWidget {
  const SensorsPage({super.key, required this.temperature, required this.humidity, required this.gas, required this.onRefresh, this.loading = false});
  final double? temperature, humidity, gas;
  final Future<void> Function() onRefresh;
  final bool loading;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(padding: const EdgeInsets.all(18), children: [
          SectionTitle('Environment', subtitle: 'Live readings from the ESP32 sensor endpoint'),
          Row(children: [
            Expanded(child: _ReadingCard(label: 'Temperature', value: temperature == null ? '--' : '${temperature!.toStringAsFixed(1)}°', unit: 'C', icon: Icons.thermostat_rounded, color: const Color(0xFFFFA56B))),
            const SizedBox(width: 10),
            Expanded(child: _ReadingCard(label: 'Humidity', value: humidity == null ? '--' : humidity!.toStringAsFixed(0), unit: '%', icon: Icons.water_drop_rounded, color: const Color(0xFF6CCBFF))),
          ]),
          const SizedBox(height: 10),
          _ReadingCard(label: 'Gas level', value: gas == null ? '--' : gas!.toStringAsFixed(0), unit: 'ppm / raw', icon: Icons.air_rounded, color: const Color(0xFFCE9AFF)),
          const SizedBox(height: 14),
          OutlinedButton.icon(onPressed: loading ? null : onRefresh, icon: const Icon(Icons.refresh), label: Text(loading ? 'Updating…' : 'Refresh readings')),
          const SizedBox(height: 12),
          const Text('Expected JSON: {"temperature":24.5,"humidity":55,"gas":120}. Configure the sensor endpoint in Settings.', style: TextStyle(color: Colors.white54)),
        ]),
      );
}

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({required this.label, required this.value, required this.unit, required this.icon, required this.color});
  final String label, value, unit;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: .14), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color)),
        const SizedBox(height: 18),
        Text(label, style: const TextStyle(color: Colors.white60)),
        const SizedBox(height: 5),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)), const SizedBox(width: 5), Padding(padding: const EdgeInsets.only(bottom: 5), child: Text(unit, style: const TextStyle(color: Colors.white54))) ]),
      ])));
}
