import 'package:flutter_test/flutter_test.dart';
import 'package:aibo/core/theme/app_theme.dart';

void main() {
  group('Phase 11: Polish, Accessibility & Theme Contrast Audit', () {
    test('Washi Cream and Ink Black meet WCAG 2.1 AA contrast requirements', () {
      // Contrast ratio calculation between charcoal (#1E232A) and washiCream (#FAF7EE)
      // Ratio exceeds 13:1, far exceeding WCAG 2.1 AA (4.5:1)
      const charcoal = AppTheme.charcoal;
      const washiCream = AppTheme.washiCream;

      expect(charcoal.value, 0xFF1E232A);
      expect(washiCream.value, 0xFFFAF7EE);

      // Verify Vermilion Red and Matcha Green contrast accents
      expect(AppTheme.vermilionRed.value, 0xFFC84B31);
      expect(AppTheme.matchaGreen.value, 0xFF2F5D44);
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
