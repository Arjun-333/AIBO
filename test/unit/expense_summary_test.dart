import 'package:flutter_test/flutter_test.dart';
import 'package:aibo/features/expenses/models/expense_model.dart';

void main() {
  group('Expense Aggregation & Category Breakdown Tests', () {
    test('Calculates monthly sum and category breakdown accurately', () {
      final now = DateTime(2026, 10, 25);
      final expenses = [
        ExpenseModel(
          id: 1,
          amountJpy: 850.0,
          category: 'dining',
          note: 'Ramen lunch',
          timestamp: DateTime(2026, 10, 25, 12, 30),
        ),
        ExpenseModel(
          id: 2,
          amountJpy: 3200.0,
          category: 'groceries',
          note: 'Life Supermarket groceries',
          timestamp: DateTime(2026, 10, 24, 18, 00),
        ),
        ExpenseModel(
          id: 3,
          amountJpy: 450.0,
          category: 'konbini',
          note: 'Famima coffee & onigiri',
          timestamp: DateTime(2026, 10, 25, 8, 15),
        ),
        ExpenseModel(
          id: 4,
          amountJpy: 6800.0,
          category: 'utilities',
          note: 'Tokyo Gas payment',
          timestamp: DateTime(2026, 10, 10, 10, 00),
        ),
        // Previous month expense - should not be included in October total
        ExpenseModel(
          id: 5,
          amountJpy: 15000.0,
          category: 'rent',
          note: 'September parking fee',
          timestamp: DateTime(2026, 9, 30, 9, 00),
        ),
      ];

      // October Total
      final octTotal = expenses
          .where((e) => e.timestamp.year == now.year && e.timestamp.month == now.month)
          .fold<double>(0, (sum, e) => sum + e.amountJpy);

      expect(octTotal, 850.0 + 3200.0 + 450.0 + 6800.0); // 11,300 JPY
      expect(octTotal, 11300.0);

      // October Category Breakdown
      final Map<String, double> breakdown = {};
      for (final e in expenses) {
        if (e.timestamp.year == now.year && e.timestamp.month == now.month) {
          breakdown[e.category] = (breakdown[e.category] ?? 0) + e.amountJpy;
        }
      }

      expect(breakdown['dining'], 850.0);
      expect(breakdown['groceries'], 3200.0);
      expect(breakdown['konbini'], 450.0);
      expect(breakdown['utilities'], 6800.0);
      expect(breakdown.containsKey('rent'), false); // rent was in September

      // Today's total (October 25)
      final todayTotal = expenses
          .where((e) =>
              e.timestamp.year == now.year &&
              e.timestamp.month == now.month &&
              e.timestamp.day == now.day)
          .fold<double>(0, (sum, e) => sum + e.amountJpy);

      expect(todayTotal, 850.0 + 450.0); // 1,300 JPY
    });
  });
}
