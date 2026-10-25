import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/services/sound_motion_service.dart';
import '../../../core/theme/app_theme.dart';

/// Interactive Japanese Motifs Banner inspired by "Welcome to Japan" Torii Art
class JapaneseToriiHeroBanner extends StatefulWidget {
  final VoidCallback onToriiTap;
  const JapaneseToriiHeroBanner({super.key, required this.onToriiTap});

  @override
  State<JapaneseToriiHeroBanner> createState() => _JapaneseToriiHeroBannerState();
}

class _JapaneseToriiHeroBannerState extends State<JapaneseToriiHeroBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SoundMotionService.instance.playTapSound();
        widget.onToriiTap();
      },
      child: Container(
        height: 190,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.warmBorder, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Red Dot Matrix Corner Patterns (like Image 1)
              Positioned(top: 14, left: 16, child: _buildDotMatrix()),
              Positioned(top: 14, right: 16, child: _buildDotMatrix()),

              // Floating clouds with red sun
              AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, _) {
                  return Stack(
                    children: [
                      // Red Sun
                      Positioned(
                        top: 26 + _floatAnimation.value,
                        left: 60,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: AppTheme.vermilionRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Floating clouds
                      Positioned(
                        top: 36 - _floatAnimation.value,
                        left: 36,
                        child: _buildCloud(width: 48),
                      ),
                      Positioned(
                        top: 28 + _floatAnimation.value,
                        right: 80,
                        child: _buildCloud(width: 36),
                      ),
                    ],
                  );
                },
              ),

              // Title typography
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Column(
                  children: const [
                    Text(
                      'W E L C O M E   T O',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3.0,
                        color: AppTheme.charcoal,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'J A P A N',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.5,
                        color: AppTheme.inkBlack,
                      ),
                    ),
                  ],
                ),
              ),

              // Torii Gate and Pine Trees Artwork
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 120,
                  child: CustomPaint(
                    painter: _ToriiGatePainter(),
                  ),
                ),
              ),

              // Tap hint
              Positioned(
                bottom: 8,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.inkBlack.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '⛩️ Tap for Daily Omikuji (おみくじ)',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.charcoal),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDotMatrix() {
    return Column(
      children: List.generate(
        4,
        (_) => Row(
          children: List.generate(
            5,
            (_) => Container(
              margin: const EdgeInsets.all(2),
              width: 3,
              height: 3,
              decoration: const BoxDecoration(
                color: AppTheme.vermilionRed,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloud({required double width}) {
    return Container(
      width: width,
      height: 14,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.inkBlack, width: 1.2),
      ),
    );
  }
}

/// Custom Painter for the Iconic Vermilion Torii Gate, Mt. Fuji & Pine Trees
class _ToriiGatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final vermilionPaint = Paint()..color = AppTheme.vermilionRed;
    final outlinePaint = Paint()
      ..color = AppTheme.inkBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Mt Fuji in background center
    final fujiPath = Path();
    fujiPath.moveTo(size.width * 0.25, size.height);
    fujiPath.lineTo(size.width * 0.5, size.height * 0.15);
    fujiPath.lineTo(size.width * 0.75, size.height);
    canvas.drawPath(fujiPath, outlinePaint);

    // Left Pine Tree (松)
    _drawPineTree(canvas, Offset(size.width * 0.15, size.height * 0.55));

    // Right Pine Tree (松)
    _drawPineTree(canvas, Offset(size.width * 0.85, size.height * 0.55));

    // Center Red Torii Gate (鳥居)
    final toriiLeft = size.width * 0.35;
    final toriiRight = size.width * 0.65;
    final toriiTop = size.height * 0.12;

    // Top Kasagi curved beam
    final kasagiPath = Path();
    kasagiPath.moveTo(toriiLeft - 22, toriiTop + 6);
    kasagiPath.quadraticBezierTo(size.width * 0.5, toriiTop - 6, toriiRight + 22, toriiTop + 6);
    kasagiPath.lineTo(toriiRight + 22, toriiTop + 16);
    kasagiPath.quadraticBezierTo(size.width * 0.5, toriiTop + 4, toriiLeft - 22, toriiTop + 16);
    kasagiPath.close();

    canvas.drawPath(kasagiPath, vermilionPaint);
    canvas.drawPath(kasagiPath, outlinePaint);

    // Second straight beam (Nuki)
    final nukiRect = Rect.fromLTWH(toriiLeft - 8, toriiTop + 24, (toriiRight - toriiLeft) + 16, 8);
    canvas.drawRect(nukiRect, vermilionPaint);
    canvas.drawRect(nukiRect, outlinePaint);

    // Left pillar (Hashira)
    final leftPillar = Rect.fromLTWH(toriiLeft + 4, toriiTop + 14, 10, size.height - toriiTop);
    canvas.drawRect(leftPillar, vermilionPaint);
    canvas.drawRect(leftPillar, outlinePaint);

    // Right pillar (Hashira)
    final rightPillar = Rect.fromLTWH(toriiRight - 14, toriiTop + 14, 10, size.height - toriiTop);
    canvas.drawRect(rightPillar, vermilionPaint);
    canvas.drawRect(rightPillar, outlinePaint);

    // Shimenawa sacred rope & paper tassels (紙垂)
    final ropeY = toriiTop + 28;
    for (int i = 0; i < 5; i++) {
      final x = (toriiLeft + 16) + i * ((toriiRight - toriiLeft - 32) / 4);
      final bellPaint = Paint()..color = const Color(0xFFD4A373); // golden bell
      canvas.drawCircle(Offset(x, ropeY + 12), 4, bellPaint);
      canvas.drawCircle(Offset(x, ropeY + 12), 4, outlinePaint);
    }
  }

  void _drawPineTree(Canvas canvas, Offset center) {
    final vermilionPaint = Paint()..color = AppTheme.vermilionRed;
    final outlinePaint = Paint()
      ..color = AppTheme.inkBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    // Trunk
    final trunkPath = Path();
    trunkPath.moveTo(center.dx, center.dy + 35);
    trunkPath.quadraticBezierTo(center.dx + 6, center.dy + 15, center.dx, center.dy);
    canvas.drawPath(trunkPath, outlinePaint);

    // Cloud-like foliage clusters
    void drawCluster(double dx, double dy, double r) {
      canvas.drawCircle(Offset(center.dx + dx, center.dy + dy), r, vermilionPaint);
      canvas.drawCircle(Offset(center.dx + dx, center.dy + dy), r, outlinePaint);
      canvas.drawCircle(Offset(center.dx + dx - 2, center.dy + dy - 2), r * 0.6, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(center.dx + dx - 2, center.dy + dy - 2), r * 0.6, outlinePaint);
    }

    drawCluster(-12, -4, 14);
    drawCluster(12, -2, 16);
    drawCluster(0, -18, 15);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Interactive 50-Icons Set inspired by Flaticon Japanese Icons (Image 2)
class JapaneseIconGridWidget extends StatelessWidget {
  final Function(String title, String jpText, String emoji) onIconTap;

  const JapaneseIconGridWidget({super.key, required this.onIconTap});

  final List<Map<String, String>> _icons = const [
    {'title': 'Ramen', 'jp': 'ラーメン', 'emoji': '🍜', 'meaning': 'Standard Tokyo tonkotsu & shoyu ramen etiquette'},
    {'title': 'Sushi', 'jp': 'お寿司', 'emoji': '🍣', 'meaning': 'Dip fish side in soy sauce, not the rice!'},
    {'title': 'Lucky Cat', 'jp': '招き猫', 'emoji': '🐱', 'meaning': 'Right paw invites wealth, left paw invites guests'},
    {'title': 'Mt. Fuji', 'jp': '富士山', 'emoji': '🗻', 'meaning': 'Japan\'s sacred 3,776m peak & symbol of good fortune'},
    {'title': 'Torii Gate', 'jp': '神社鳥居', 'emoji': '⛩️', 'meaning': 'Bow lightly before passing through shrine boundary'},
    {'title': 'Green Tea', 'jp': '抹茶・お茶', 'emoji': '🍵', 'meaning': 'Complimentary green tea served in restaurants'},
    {'title': 'Origami', 'jp': '折り鶴', 'emoji': '🕊️', 'meaning': 'Symbol of peace, health, and 1,000 folded wishes'},
    {'title': 'Hot Springs', 'jp': '温泉・銭湯', 'emoji': '♨️', 'meaning': 'Wash thoroughly before entering shared bath waters'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.warmBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'JAPANESE LIFE ESSENTIALS (和の心得)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppTheme.charcoal,
                ),
              ),
              Text(
                'Tap to inspect',
                style: TextStyle(fontSize: 10, color: AppTheme.mutedGrey),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _icons.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, idx) {
              final item = _icons[idx];
              return InkWell(
                onTap: () {
                  SoundMotionService.instance.playTapSound();
                  onIconTap(item['title']!, item['meaning']!, item['emoji']!);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.washiCream,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.warmBorder),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item['emoji']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.inkBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item['jp']!,
                        style: const TextStyle(
                          fontSize: 8,
                          color: AppTheme.mutedGrey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
