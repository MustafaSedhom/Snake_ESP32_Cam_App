import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:snake_esp_cam_app/Model/app_config.dart';


class DeviceApi {
  DeviceApi(this.config);
  final AppConfig config;

  Future<Map<String, dynamic>> getJson(String url) async {
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 4));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) throw const FormatException('Expected JSON object');
    return decoded;
  }

  Future<Map<String, dynamic>> postJson(String url, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(url),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 4));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
    if (response.body.isEmpty) return {'ok': true};
    final decoded = jsonDecode(response.body);
    return decoded is Map<String, dynamic> ? decoded : {'ok': true};
  }
}
