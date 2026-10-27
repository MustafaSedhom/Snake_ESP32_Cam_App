import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:snake_esp_cam_app/Screens/Home/Widget/Control_Buttons.dart';
import 'package:snake_esp_cam_app/Screens/Home/Widget/WIFi_Status_Widget.dart';
import 'package:snake_esp_cam_app/Screens/Home/Widget/camera_stream_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool is_connected = true;

  Future<void> printWifiInfo() async {
    final info = NetworkInfo();

    try {
      final wifiName = await info.getWifiName();
      final wifiIP = await info.getWifiIP();
      final gatewayIP = await info.getWifiGatewayIP();

      print('Wi-Fi name: $wifiName');
      print('Device IP: $wifiIP');
      print('Router IP: $gatewayIP');
    } catch (e) {
      print('Could not read Wi-Fi info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            mainAxisAlignment: .start,
            children: [
              // AppBar
              Container(
                height: 100,
                margin: EdgeInsets.symmetric(horizontal: 5, vertical: 30),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      offset: const Offset(0, 6),
                      blurRadius: 14,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      offset: const Offset(0, 2),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      "Snake",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 20,
                      ),
                    ),
                    WifiStatusWidget(
                      isConnected: is_connected,
                      wifiName: "WIFI Name",
                      connectedColor: Colors.blue.shade800,
                      disconnectedColor: Colors.orange.shade900,
                      connectedContainerColor: Colors.green,
                      disconnectedContainerColor: Colors.orange,
                    ),
                  ],
                ),
              ),
              // Live Camera and Audio
              CameraStreamView(
                url: 'http://192.168.1.50:81/stream',
                audioUrl: 'http://192.168.1.50/audio',
              ),
              // control
              ControlButtonsWidget(),
              /////////////
              Gap(30),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    is_connected = !is_connected;
                    printWifiInfo();
                  });
                },
                child: const Text('Read Wi-Fi info'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
