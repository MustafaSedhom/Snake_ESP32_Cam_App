import 'dart:ui';
import 'package:flutter/material.dart';

enum ControlDirection { up, down, left, right }

class ControlButtonsWidget extends StatefulWidget {
  const ControlButtonsWidget({
    super.key,
    this.onDirectionPressed,
    this.size = 230,
  });

  final ValueChanged<ControlDirection>? onDirectionPressed;
  final double size;

  @override
  State<ControlButtonsWidget> createState() => _ControlButtonsWidgetState();
}

class _ControlButtonsWidgetState extends State<ControlButtonsWidget> {
  ControlDirection? _pressedDirection;

  void _press(ControlDirection direction) {
    setState(() => _pressedDirection = direction);
    widget.onDirectionPressed?.call(direction);
  }

  void _release() {
    setState(() => _pressedDirection = null);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final buttonSize = widget.size * 0.31;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(widget.size * 0.22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(widget.size * 0.22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),
              ),
            ),

            _directionButton(
              direction: ControlDirection.up,
              icon: Icons.keyboard_arrow_up_rounded,
              size: buttonSize,
              colors: colors,
            ),
            _directionButton(
              direction: ControlDirection.down,
              icon: Icons.keyboard_arrow_down_rounded,
              size: buttonSize,
              colors: colors,
            ),
            _directionButton(
              direction: ControlDirection.left,
              icon: Icons.keyboard_arrow_left_rounded,
              size: buttonSize,
              colors: colors,
            ),
            _directionButton(
              direction: ControlDirection.right,
              icon: Icons.keyboard_arrow_right_rounded,
              size: buttonSize,
              colors: colors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _directionButton({
    required ControlDirection direction,
    required IconData icon,
    required double size,
    required ColorScheme colors,
  }) {
    final isPressed = _pressedDirection == direction;

    Alignment alignment;
    switch (direction) {
      case ControlDirection.up:
        alignment = Alignment.topCenter;
      case ControlDirection.down:
        alignment = Alignment.bottomCenter;
      case ControlDirection.left:
        alignment = Alignment.centerLeft;
      case ControlDirection.right:
        alignment = Alignment.centerRight;
    }

    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTapDown: (_) => _press(direction),
        onTapUp: (_) => _release(),
        onTapCancel: _release,
        child: AnimatedScale(
          scale: isPressed ? 0.90 : 1,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPressed
                  ? colors.primary.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.10),
              border: Border.all(
                color: isPressed
                    ? colors.primary.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.22),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isPressed
                      ? colors.primary.withValues(alpha: 0.45)
                      : Colors.black.withValues(alpha: 0.18),
                  blurRadius: isPressed ? 22 : 10,
                  spreadRadius: isPressed ? 2 : 0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: size * 0.68,
              color: isPressed ? colors.onPrimary : colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
