import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class SoundMotionService {
  static final SoundMotionService instance = SoundMotionService._init();
  SoundMotionService._init();

  /// Plays a tactile click sound and light haptic feedback
  void playTapSound() {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.lightImpact();
  }

  /// Plays a celebratory success vibration and chime
  void playSuccessHaptic() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.click);
  }

  /// Plays an alert vibration for emergencies and overdue reminders
  void playAlertVibration() {
    HapticFeedback.vibrate();
    SystemSound.play(SystemSoundType.alert);
  }

  /// Displays an animated slide-down Japanese Toast Notification
  void showJapaneseNotification(
    BuildContext context, {
    required String title,
    required String messageJa,
    String? iconEmoji,
    Color? accentColor,
  }) {
    playSuccessHaptic();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _SlideDownNotification(
        title: title,
        messageJa: messageJa,
        iconEmoji: iconEmoji ?? '⛩️',
        accentColor: accentColor ?? AppTheme.vermilionRed,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _SlideDownNotification extends StatefulWidget {
  final String title;
  final String messageJa;
  final String iconEmoji;
  final Color accentColor;
  final VoidCallback onDismiss;

  const _SlideDownNotification({
    required this.title,
    required this.messageJa,
    required this.iconEmoji,
    required this.accentColor,
    required this.onDismiss,
  });

  @override
  State<_SlideDownNotification> createState() => _SlideDownNotificationState();
}

class _SlideDownNotificationState extends State<_SlideDownNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Auto-dismiss after 3.2 seconds
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.accentColor, width: 1.8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2A000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.iconEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.inkBlack,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.messageJa,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: AppTheme.mutedGrey),
                    onPressed: () {
                      _controller.reverse().then((_) => widget.onDismiss());
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
