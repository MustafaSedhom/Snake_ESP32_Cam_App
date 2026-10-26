import 'package:flutter/material.dart';

class MotorDpad extends StatelessWidget {
  const MotorDpad({super.key, required this.onCommand, this.busy = false});
  final ValueChanged<String> onCommand;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    Widget key(IconData icon, String command, {bool center = false}) => SizedBox(
          width: 74,
          height: 68,
          child: FilledButton(
            onPressed: busy ? null : () => onCommand(command),
            style: FilledButton.styleFrom(
              backgroundColor: center ? const Color(0xFF26D0B2) : const Color(0xFF243136),
              foregroundColor: center ? const Color(0xFF06221D) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: center
                ? const Text('OK', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17))
                : Icon(icon, size: 28),
          ),
        );

    return Column(mainAxisSize: MainAxisSize.min, children: [
      key(Icons.keyboard_arrow_up, 'forward'),
      const SizedBox(height: 8),
      Row(mainAxisSize: MainAxisSize.min, children: [
        key(Icons.keyboard_arrow_left, 'left'),
        const SizedBox(width: 8),
        key(Icons.circle_outlined, 'ok', center: true),
        const SizedBox(width: 8),
        key(Icons.keyboard_arrow_right, 'right'),
      ]),
      const SizedBox(height: 8),
      key(Icons.keyboard_arrow_down, 'backward'),
    ]);
  }
}
