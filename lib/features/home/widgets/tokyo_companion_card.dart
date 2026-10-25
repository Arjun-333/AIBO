import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class TokyoCompanionCard extends StatefulWidget {
  final int completedTasks;
  final int totalTasks;
  final double totalSpendJpy;

  const TokyoCompanionCard({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    required this.totalSpendJpy,
  });

  @override
  State<TokyoCompanionCard> createState() => _TokyoCompanionCardState();
}

class _TokyoCompanionCardState extends State<TokyoCompanionCard> with SingleTickerProviderStateMixin {
  late AnimationController _jumpController;
  late Animation<double> _jumpAnimation;

  // Cat State: 'running' (走る), 'jumping' (跳ぶ), 'resting' (休む)
  String _activeState = 'running';
  int _treatsCount = 18;
  String _speechBubble = '今日も東京でがんばろう！ (Let\'s do our best in Tokyo today!)';

  final List<String> _companionTips = [
    '明日は可燃ごみの日！ (Tomorrow is burnable garbage!)',
    '水分補給を忘れずに。(Stay hydrated while walking!)',
    'Suica残高を確認した？ (Checked your Suica card balance?)',
    '区役所の手続きは午前中がおすすめ。(Morning is best for ward office visits.)',
    '今月も予算を守ってえらい！ (Great job keeping to this month\'s budget!)',
    'おいしいおにぎりを食べよう。(Let\'s grab an onigiri at the konbini!)',
  ];

  @override
  void initState() {
    super.initState();
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _jumpAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -38.0).chain(CurveTween(curve: Curves.easeOutQuad)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -38.0, end: 0.0).chain(CurveTween(curve: Curves.bounceOut)), weight: 50),
    ]).animate(_jumpController);
  }

  @override
  void dispose() {
    _jumpController.dispose();
    super.dispose();
  }

  void _triggerJump() {
    HapticFeedback.lightImpact();
    setState(() {
      _activeState = 'jumping';
      _treatsCount += 1;
      _speechBubble = _companionTips[Random().nextInt(_companionTips.length)];
    });

    _jumpController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() => _activeState = 'running');
      }
    });
  }

  void _setState(String state) {
    HapticFeedback.selectionClick();
    setState(() {
      _activeState = state;
      if (state == 'resting') {
        _speechBubble = 'ちょっと休憩... お疲れ様！ (Taking a short rest. Good work!)';
      } else if (state == 'jumping') {
        _triggerJump();
      } else {
        _speechBubble = '東京を元気にパトロール中！ (Patrolling Tokyo with energy!)';
      }
    });
  }

  double get _progressPercent {
    if (widget.totalTasks == 0) return 0.42; // default concept demo
    return (widget.completedTasks / widget.totalTasks).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final progressInt = (_progressPercent * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.washiCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.warmBorder, width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Japanese Typography & Concept Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'む ち ね こ',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4.0,
                      color: AppTheme.inkBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'C O N C E P T   D E S I G N',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.2,
                      color: AppTheme.charcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '東京での毎日。一歩ずつ、軽やかに。',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.mutedGrey,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              // Concept Points Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.warmBorder),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CONCEPT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.charcoal)),
                    SizedBox(height: 2),
                    Text('・歩くほど、軽くなる。', style: TextStyle(fontSize: 9, color: AppTheme.mutedGrey)),
                    Text('・走る、跳ぶ、楽しむ。', style: TextStyle(fontSize: 9, color: AppTheme.mutedGrey)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Horizontal Device Frame: Tokyo Rooftop Skyline + Animated Chubby Cat
          GestureDetector(
            onTap: _triggerJump,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFDCD6CA), // warm beige sky
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.inkBlack, width: 4.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Tokyo Skyline Background (Custom Painter)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _TokyoSkylinePainter(),
                      ),
                    ),

                    // Top Bar inside Screen: Weight Gauge + Treats Counter
                    Positioned(
                      top: 14,
                      left: 18,
                      right: 18,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DAILY GOAL',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: AppTheme.inkBlack,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Capsule progress bar
                              Container(
                                width: 90,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6F4EE),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.inkBlack, width: 1.2),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _progressPercent,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.inkBlack,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$progressInt %',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.charcoal),
                              ),
                            ],
                          ),

                          // Treats counter
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.washiCream,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.inkBlack, width: 1.2),
                            ),
                            child: Row(
                              children: [
                                const Text('●', style: TextStyle(fontSize: 10, color: Color(0xFF6B4F3B))),
                                const SizedBox(width: 4),
                                Text(
                                  '× $_treatsCount',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.inkBlack),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.pause, size: 14, color: AppTheme.inkBlack),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Interactive Jumping Cat
                    Positioned(
                      bottom: 40,
                      left: 100,
                      child: AnimatedBuilder(
                        animation: _jumpAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _jumpAnimation.value),
                            child: _buildChubbyCat(),
                          );
                        },
                      ),
                    ),

                    // Tap Instruction Hint
                    Positioned(
                      bottom: 8,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.inkBlack.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app, size: 10, color: Colors.white),
                            SizedBox(width: 4),
                            Text('TAP TO JUMP (跳ぶ)', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Speech Bubble from Cat
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.warmBorder),
            ),
            child: Row(
              children: [
                const Text('🐱', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _speechBubble,
                    style: const TextStyle(fontSize: 12, color: AppTheme.inkBlack, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // System / Cat State Row
          Row(
            children: [
              // System Action Buttons
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SYSTEM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.charcoal)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildStateButton('走る', 'running', Icons.directions_run),
                        const SizedBox(width: 6),
                        _buildStateButton('跳ぶ', 'jumping', Icons.arrow_upward),
                        const SizedBox(width: 6),
                        _buildStateButton('休む', 'resting', Icons.nightlight_outlined),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Cat State
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CAT STATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.charcoal)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildStatePill('軽い', _progressPercent < 0.4),
                        const SizedBox(width: 4),
                        _buildStatePill('ふつう', _progressPercent >= 0.4 && _progressPercent < 0.8),
                        const SizedBox(width: 4),
                        _buildStatePill('重い', _progressPercent >= 0.8),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Keywords & Color Palette Row matching concept sheet
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Keywords
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('KEYWORDS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.charcoal)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: const [
                        _KeywordChip(label: '肥満 (Muchi)'),
                        _KeywordChip(label: 'ジャンプ'),
                        _KeywordChip(label: 'シンプル'),
                        _KeywordChip(label: 'Bauhaus'),
                        _KeywordChip(label: 'Tokyo 2026'),
                      ],
                    ),
                  ],
                ),
              ),

              // Color Palette Dots
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('COLOR PALETTE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppTheme.charcoal)),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      _PaletteDot(color: Color(0xFF111111)),
                      SizedBox(width: 4),
                      _PaletteDot(color: Color(0xFF333333)),
                      SizedBox(width: 4),
                      _PaletteDot(color: Color(0xFF777777)),
                      SizedBox(width: 4),
                      _PaletteDot(color: Color(0xFFBEB8AD)),
                      SizedBox(width: 4),
                      _PaletteDot(color: Color(0xFFE6E1D7)),
                      SizedBox(width: 4),
                      _PaletteDot(color: Color(0xFFF6F4EE)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStateButton(String label, String stateKey, IconData icon) {
    final isSelected = _activeState == stateKey;
    return Expanded(
      child: InkWell(
        onTap: () => _setState(stateKey),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.inkBlack : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.warmBorder),
          ),
          child: Column(
            children: [
              Icon(icon, size: 14, color: isSelected ? Colors.white : AppTheme.charcoal),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppTheme.charcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatePill(String label, bool isActive) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.sandAccent.withOpacity(0.3) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? AppTheme.inkBlack : AppTheme.warmBorder, width: isActive ? 1.2 : 1),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppTheme.inkBlack : AppTheme.mutedGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildChubbyCat() {
    return Container(
      width: 72,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.inkBlack, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Black spot on head/back
          Positioned(
            top: 4,
            right: 8,
            child: Container(
              width: 22,
              height: 18,
              decoration: const BoxDecoration(
                color: AppTheme.inkBlack,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
          ),
          // Cat Face
          Positioned(
            top: 14,
            right: 12,
            child: Row(
              children: [
                Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              ],
            ),
          ),
          // Little legs
          Positioned(
            bottom: 2,
            left: 14,
            child: Row(
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: AppTheme.inkBlack, borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 20),
                Container(width: 6, height: 6, decoration: BoxDecoration(color: AppTheme.inkBlack, borderRadius: BorderRadius.circular(3))),
              ],
            ),
          ),
          // Tiny tail
          Positioned(
            bottom: 12,
            left: -3,
            child: Container(
              width: 8,
              height: 4,
              decoration: BoxDecoration(color: AppTheme.inkBlack, borderRadius: BorderRadius.circular(2)),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  final String label;
  const _KeywordChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warmBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 9, color: AppTheme.charcoal, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _PaletteDot extends StatelessWidget {
  final Color color;
  const _PaletteDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black26, width: 0.8),
      ),
    );
  }
}

/// Custom Bauhaus Tokyo Rooftop Skyline Painter
class _TokyoSkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFC8C2B7);
    final midPaint = Paint()..color = const Color(0xFFAFA99E);
    final darkPaint = Paint()..color = const Color(0xFF7A756D);
    final inkPaint = Paint()..color = AppTheme.inkBlack;

    // Distant background buildings
    canvas.drawRect(Rect.fromLTWH(20, 30, 45, size.height - 30), bgPaint);
    canvas.drawRect(Rect.fromLTWH(80, 50, 60, size.height - 50), bgPaint);
    canvas.drawRect(Rect.fromLTWH(160, 20, 55, size.height - 20), bgPaint);
    canvas.drawRect(Rect.fromLTWH(240, 40, 50, size.height - 40), bgPaint);

    // Midground buildings with windows
    canvas.drawRect(Rect.fromLTWH(50, 70, 70, size.height - 70), midPaint);
    canvas.drawRect(Rect.fromLTWH(135, 60, 65, size.height - 60), midPaint);
    canvas.drawRect(Rect.fromLTWH(210, 80, 80, size.height - 80), midPaint);

    // Foreground black rooftop silhouette
    canvas.drawRect(Rect.fromLTWH(0, size.height - 40, size.width, 40), inkPaint);
    canvas.drawRect(Rect.fromLTWH(0, size.height - 80, 85, 40), inkPaint);
    canvas.drawRect(Rect.fromLTWH(size.width - 90, size.height - 95, 90, 55), inkPaint);

    // Water tower on right rooftop
    final towerPaint = Paint()..color = const Color(0xFF7A756D);
    canvas.drawOval(Rect.fromLTWH(size.width - 65, size.height - 115, 20, 16), towerPaint);
    canvas.drawRect(Rect.fromLTWH(size.width - 63, size.height - 100, 16, 8), inkPaint);

    // Minimalist Japanese signboard "むちねこ"
    final signPaint = Paint()..color = AppTheme.washiCream;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width - 125, size.height - 110, 20, 55), const Radius.circular(4)),
      signPaint,
    );
    final borderPaint = Paint()
      ..color = AppTheme.inkBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width - 125, size.height - 110, 20, 55), const Radius.circular(4)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
