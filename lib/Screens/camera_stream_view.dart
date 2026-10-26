import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

class CameraStreamView extends StatelessWidget {
  const CameraStreamView({super.key, required this.url, required this.enabled});
  final String url;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: ColoredBox(
          color: Colors.black,
          child: !enabled
              ? const Center(child: Text('Stream paused'))
              : Mjpeg(
                  stream: url,
                  isLive: true,
                  fit: BoxFit.contain,
                  timeout: const Duration(seconds: 12),
                  loading: (_) => const Center(child: CircularProgressIndicator()),
                  error: (_, __, ___) => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Camera stream unavailable\nCheck Wi-Fi and stream URL', textAlign: TextAlign.center),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
