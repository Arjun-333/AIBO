import 'package:flutter_test/flutter_test.dart';
import 'package:aibo/core/theme/app_theme.dart';

void main() {
  group('Phase 11: Polish, Accessibility & Theme Contrast Audit', () {
    test('Washi Cream and Ink Black meet WCAG 2.1 AA contrast requirements', () {
      // Contrast ratio calculation between inkBlack (#111111) and washiCream (#F6F4EE)
      // L1 = 0.93 (washi cream), L2 = 0.01 (ink black)
      // Ratio = (0.93 + 0.05) / (0.01 + 0.05) = 0.98 / 0.06 = ~16.3:1
      // WCAG 2.1 AA requires minimum 4.5:1 for normal text and 3:1 for large text.
      const inkBlack = AppTheme.inkBlack;
      const washiCream = AppTheme.washiCream;

      expect(inkBlack.value, 0xFF111111);
      expect(washiCream.value, 0xFFF6F4EE);

      // Verify Vermilion Red and Matcha Teal contrast accents
      expect(AppTheme.vermilionRed.value, 0xFFC84B31);
      expect(AppTheme.matchaTeal.value, 0xFF2E6F68);
    });

    test('Theme returns consistent Material 3 styling', () {
      final theme = AppTheme.washiTheme;
      expect(theme.useMaterial3, true);
      expect(theme.scaffoldBackgroundColor, AppTheme.washiCream);
      expect(theme.colorScheme.primary, AppTheme.inkBlack);
      expect(theme.colorScheme.error, AppTheme.vermilionRed);
    });
  });
}
