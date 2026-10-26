import 'package:flutter/foundation.dart';

class AppConfig extends ChangeNotifier {
  String streamUrl = 'http://192.168.4.1/stream';
  String controlServer = 'http://192.168.4.1:81';
  String ledPath = '/api/led';
  String hotspotPath = '/api/hotspot';
  String motorPath = '/api/motor';
  String sensorsPath = '/api/sensors';

  String get ledUrl => _join(controlServer, ledPath);
  String get hotspotUrl => _join(controlServer, hotspotPath);
  String get motorUrl => _join(controlServer, motorPath);
  String get sensorsUrl => _join(controlServer, sensorsPath);

  void update({
    String? streamUrl,
    String? controlServer,
    String? ledPath,
    String? hotspotPath,
    String? motorPath,
    String? sensorsPath,
  }) {
    this.streamUrl = streamUrl?.trim() ?? this.streamUrl;
    this.controlServer = controlServer?.trim().replaceFirst(RegExp(r'/$'), '') ?? this.controlServer;
    this.ledPath = _normalizePath(ledPath ?? this.ledPath);
    this.hotspotPath = _normalizePath(hotspotPath ?? this.hotspotPath);
    this.motorPath = _normalizePath(motorPath ?? this.motorPath);
    this.sensorsPath = _normalizePath(sensorsPath ?? this.sensorsPath);
    notifyListeners();
  }

  static String _normalizePath(String path) => path.startsWith('/') ? path : '/$path';
  static String _join(String base, String path) =>
      '${base.replaceFirst(RegExp(r'/$'), '')}${_normalizePath(path)}';
}
