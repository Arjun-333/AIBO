import 'package:flutter_test/flutter_test.dart';
import 'package:aibo/features/expenses/models/expense_model.dart';

void main() {
  group('ExpenseModel Unit Tests', () {
    test('Calculates and serializes JPY expense correctly', () {
      final expense = ExpenseModel(
        id: 1,
        amountJpy: 1280.0,
        category: 'groceries',
        note: 'Supermarket vegetables & tofu',
      );

      final map = expense.toMap();
      expect(map['amount_jpy'], 1280.0);
      expect(map['category'], 'groceries');
      expect(map['note'], 'Supermarket vegetables & tofu');

      final restored = ExpenseModel.fromMap(map);
      expect(restored.id, 1);
      expect(restored.amountJpy, 1280.0);
      expect(restored.category, 'groceries');
    });
  });
}
