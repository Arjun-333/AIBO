import 'package:flutter_test/flutter_test.dart';
import 'package:aibo/features/planner/models/task_model.dart';

void main() {
  group('TaskModel Unit Tests', () {
    test('Default status is incomplete and serializes correctly', () {
      final task = TaskModel(
        id: 42,
        title: 'Recyclable Plastic (資源プラスチック)',
        category: 'garbage',
        priority: 'high',
      );

      expect(task.isCompleted, false);
      expect(task.priority, 'high');

      final map = task.toMap();
      expect(map['is_completed'], 0);
      expect(map['title'], 'Recyclable Plastic (資源プラスチック)');

      final fromMap = TaskModel.fromMap(map);
      expect(fromMap.id, 42);
      expect(fromMap.title, 'Recyclable Plastic (資源プラスチック)');
      expect(fromMap.isCompleted, false);
    });

    test('Completed task properly parses integer flag', () {
      final map = {
        'id': 10,
        'title': 'Pay City Residence Tax (住民税)',
        'description': 'At 7-Eleven with barcoded slip',
        'is_completed': 1,
        'priority': 'urgent',
        'category': 'bills',
        'created_at': DateTime.now().toIso8601String(),
      };

      final task = TaskModel.fromMap(map);
      expect(task.isCompleted, true);
      expect(task.priority, 'urgent');
      expect(task.category, 'bills');
    });
  });
}
