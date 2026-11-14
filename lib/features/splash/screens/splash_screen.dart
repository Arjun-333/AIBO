import 'package:flutter/material.dart';
import '../../../core/services/sound_motion_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/screens/lock_screen.dart';

/// Animated Splash Screen featuring the Japanese Torii Gate,
/// Inkan Hanko Seal ('相棒'), and Creator Signature ('Made by Arjun').
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _sealScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // 1. Torii Gate entrance (Scale & Fade)
    _logoScaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    // 2. Hanko Inkan Seal Stamp bounce
    _sealScaleAnimation = Tween<double>(begin: 2.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.elasticOut),
      ),
    );

    // 3. Text and "Made by Arjun" attribution fade & rise
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.85, curve: Curves.easeOut),
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    // Subtle entrance sound
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        SoundMotionService.instance.playTapSound();
      }
    });

    // Auto-proceed to LockScreen after 2.3 seconds
    Future.delayed(const Duration(milliseconds: 2300), () {
      _proceedToApp();
    });
  }

  void _proceedToApp() {
    if (_navigated || !mounted) return;
    _navigated = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LockScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.washiCream,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _proceedToApp, // Allow user to tap anywhere to skip
        child: SafeArea(
          child: Stack(
            children: [
              // Central Brand & Torii Section
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Torii Logo & Inkan Hanko
                      ScaleTransition(
                        scale: _logoScaleAnimation,
                        child: FadeTransition(
                          opacity: _logoFadeAnimation,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // White card frame for the Torii Gate
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceWhite,
                                  borderRadius: BorderRadius.circular(26),
                                  border: Border.all(
                                    color: AppTheme.warmBorder,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.vermilionRed
                                          .withValues(alpha: 0.12),
                                      blurRadius: 28,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: CustomPaint(
                                    size: const Size(54, 54),
                                    painter: _ToriiMiniPainter(),
                                  ),
                                ),
                              ),

                              // Hanko Seal '相棒'
                              Positioned(
                                bottom: -6,
                                right: -8,
                                child: ScaleTransition(
                                  scale: _sealScaleAnimation,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppTheme.vermilionRed,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.vermilionRed
                                              .withValues(alpha: 0.35),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '相棒',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                          height: 1.1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Brand Titles (AIBO • Personal Life OS)
                      FadeTransition(
                        opacity: _textFadeAnimation,
                        child: SlideTransition(
                          position: _textSlideAnimation,
                          child: Column(
                            children: [
                              const Text(
                                'AIBO',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 6,
                                  color: AppTheme.charcoal,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Personal Life OS for Japan',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.secondaryText,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.matchaGreen
                                      .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppTheme.matchaGreen
                                        .withValues(alpha: 0.22),
                                  ),
                                ),
                                child: const Text(
                                  '日本生活の頼れる相棒',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.matchaGreen,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Attribution Section ('Made by Arjun')
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _textFadeAnimation,
                  child: SlideTransition(
                    position: _textSlideAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.warmBorder),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '✦',
                                style: TextStyle(
                                  color: AppTheme.vermilionRed,
                                  fontSize: 10,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Made by Arjun',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.charcoal,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                '✦',
                                style: TextStyle(
                                  color: AppTheme.vermilionRed,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '100% Offline • Zero Telemetry • AES-256 Vault',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.mutedText,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
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

/// Custom Painter for the Minimalist Vermilion Torii Gate Logo
class _ToriiMiniPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final vermilion = Paint()
      ..color = AppTheme.vermilionRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Top curved Kasagi beam
    final kasagi = Path()
      ..moveTo(w * 0.08, h * 0.22)
      ..quadraticBezierTo(w * 0.5, h * 0.16, w * 0.92, h * 0.22);
    canvas.drawPath(kasagi, vermilion);

    // Second straight Nuki beam
    canvas.drawLine(
      Offset(w * 0.16, h * 0.36),
      Offset(w * 0.84, h * 0.36),
      vermilion,
    );

    // Left pillar
    canvas.drawLine(
      Offset(w * 0.30, h * 0.22),
      Offset(w * 0.30, h * 0.88),
      vermilion,
    );

    // Right pillar
    canvas.drawLine(
      Offset(w * 0.70, h * 0.22),
      Offset(w * 0.70, h * 0.88),
      vermilion,
    );

    // Center struts (Daiwa)
    canvas.drawLine(
      Offset(w * 0.46, h * 0.22),
      Offset(w * 0.46, h * 0.36),
      vermilion,
    );
    canvas.drawLine(
      Offset(w * 0.54, h * 0.22),
      Offset(w * 0.54, h * 0.36),
      vermilion,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
