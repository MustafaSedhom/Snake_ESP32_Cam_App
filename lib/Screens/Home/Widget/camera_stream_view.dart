import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

class CameraStreamView extends StatefulWidget {
  const CameraStreamView({
    super.key,
    required this.url,
    this.audioUrl,
    this.enabled = true,
    this.aspectRatio = 4 / 3,
    this.borderRadius = 18,
  });

  final String url;
  final String? audioUrl;
  final bool enabled;
  final double aspectRatio;
  final double borderRadius;

  @override
  State<CameraStreamView> createState() => _CameraStreamViewState();
}

class _CameraStreamViewState extends State<CameraStreamView> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late bool _isPlaying;
  bool _audioEnabled = false;
  bool _audioError = false;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.enabled;
  }

  @override
  void didUpdateWidget(covariant CameraStreamView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.enabled != widget.enabled) {
      _isPlaying = widget.enabled;
      if (_isPlaying && _audioEnabled) {
        _startAudio();
      } else {
        _stopAudio();
      }
    }

    if (oldWidget.audioUrl != widget.audioUrl && _audioEnabled && _isPlaying) {
      _startAudio();
    }
  }

  void _toggleStream() {
    final play = !_isPlaying;

    setState(() {
      _isPlaying = play;
      if (!play) _audioEnabled = false;
      _audioError = false;
    });

    if (play) {
      // عند استئناف الفيديو لا نشغّل الصوت تلقائيًا.
    } else {
      _stopAudio();
    }
  }

  Future<void> _toggleAudio() async {
    if (widget.audioUrl == null || widget.audioUrl!.isEmpty) {
      setState(() => _audioError = true);
      return;
    }

    final enable = !_audioEnabled;
    setState(() {
      _audioEnabled = enable;
      _audioError = false;
    });

    if (enable && _isPlaying) {
      await _startAudio();
    } else {
      await _stopAudio();
    }
  }

  Future<void> _startAudio() async {
    final url = widget.audioUrl;
    if (url == null || url.isEmpty || !_isPlaying) return;

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      if (mounted) setState(() => _audioError = false);
    } catch (_) {
      if (mounted) setState(() => _audioError = true);
    }
  }

  Future<void> _stopAudio() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {
      // تجاهل خطأ الإيقاف.
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // الفيديو أو شاشة الإيقاف / التحميل / الخطأ
              ColoredBox(
                color: const Color(0xFF080B0E),
                child: _isPlaying
                    ? Mjpeg(
                        key: ValueKey(widget.url),
                        stream: widget.url,
                        isLive: true,
                        fit: BoxFit.contain,
                        timeout: const Duration(seconds: 12),
                        loading: (_) => const _StreamMessage(
                          icon: Icons.wifi_tethering_rounded,
                          title: 'جارٍ الاتصال بالبث',
                          message: 'في انتظار صورة الكاميرا...',
                          showLoading: true,
                        ),
                        error: (_, __, ___) => const _StreamMessage(
                          icon: Icons.videocam_off_rounded,
                          title: 'تعذّر الاتصال',
                          message: 'تحقق من الشبكة ورابط الكاميرا.',
                          isError: true,
                        ),
                      )
                    : const _StreamMessage(
                        icon: Icons.videocam_off_rounded,
                        title: 'STREAM OFF',
                        message: 'اضغط زر الكاميرا لاستئناف البث.',
                        isError: true,
                      ),
              ),

              // تدرج بسيط لتحسين وضوح العناصر فوق الفيديو.
              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x55000000),
                        Colors.transparent,
                        Color(0x33000000),
                      ],
                      stops: [0, 0.5, 1],
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 12,
                left: 12,
                child: _GlassPill(child: _LiveBadge(isLive: _isPlaying)),
              ),

              // زرا الكاميرا والصوت بنفس الحجم.
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _GlassButton(
                      icon: _isPlaying
                          ? Icons.videocam_rounded
                          : Icons.videocam_off_rounded,
                      isActive: _isPlaying,
                      tooltip: _isPlaying ? 'إيقاف البث' : 'تشغيل البث',
                      onPressed: _toggleStream,
                    ),
                    const SizedBox(width: 10),
                    _GlassButton(
                      icon: _audioEnabled
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      isActive: _audioEnabled,
                      tooltip: _audioEnabled ? 'إيقاف الصوت' : 'تشغيل الصوت',
                      onPressed: _toggleAudio,
                    ),
                  ],
                ),
              ),

              if (_audioError)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: _GlassPill(
                    child: Text(
                      widget.audioUrl == null
                          ? 'لم يتم تحديد رابط الصوت'
                          : 'تعذّر تشغيل الصوت',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.isActive,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final bool isActive;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final accent = isActive ? const Color(0xFF35E0C1) : Colors.white;

    return Tooltip(
      message: tooltip,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Material(
            color: Colors.white.withValues(alpha: isActive ? 0.20 : 0.10),
            shape: CircleBorder(
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.30),
                width: 1,
              ),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: SizedBox(
                width: 48,
                height: 48,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    icon,
                    key: ValueKey(icon),
                    size: 23,
                    color: accent,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.isLive});

  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final color = isLive ? Colors.greenAccent : Colors.redAccent;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.65),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 7),
        Text(
          isLive ? 'LIVE' : 'OFF',
          style: TextStyle(
            color: isLive ? Colors.white : Colors.redAccent,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }
}

class _StreamMessage extends StatelessWidget {
  const _StreamMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.showLoading = false,
    this.isError = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool showLoading;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.redAccent : Colors.white70;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLoading) ...[
              const SizedBox(
                width: 38,
                height: 38,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Color(0xFF35E0C1),
                ),
              ),
              const SizedBox(height: 14),
            ] else ...[
              Icon(icon, color: color, size: 42),
              const SizedBox(height: 12),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: isError ? 22 : 17,
                fontWeight: FontWeight.bold,
                letterSpacing: isError ? 1.2 : 0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
