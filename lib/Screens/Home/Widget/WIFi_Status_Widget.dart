import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class WifiStatusWidget extends StatelessWidget {
  const WifiStatusWidget({
    super.key,
    required this.isConnected,
    required this.connectedColor,
    required this.disconnectedColor,
    required this.connectedContainerColor,
    required this.disconnectedContainerColor,
    this.wifiName,
  });

  final bool isConnected;
  final Color connectedColor;
  final Color disconnectedColor;
  final Color connectedContainerColor;
  final Color disconnectedContainerColor;
  final String? wifiName;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isConnected ? connectedColor : disconnectedColor;
    final containerColor = isConnected
        ? connectedContainerColor.withValues(alpha: 0.2)
        : disconnectedContainerColor.withValues(alpha: 0.2);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: foregroundColor.withValues(alpha: 0.16),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: foregroundColor.withValues(alpha: 0.07),
            offset: const Offset(0, 1),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConnected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            color: foregroundColor,
            size: 20,
          ),
          const Gap(8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: Text(
              isConnected ? (wifiName ?? 'متصل') : 'غير متصل',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
