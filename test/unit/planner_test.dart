import 'package:flutter_test/flutter_test.dart';
import 'package:aibo/features/planner/models/task_model.dart';

void main() {
  group('Planner Filtering & Overdue Logic Tests', () {
    test('Correctly filters tasks by Japanese life categories', () {
      final tasks = [
        TaskModel(id: 1, title: 'Burnable Garbage', category: 'garbage'),
        TaskModel(id: 2, title: 'Pay Electricity Bill', category: 'bills'),
        TaskModel(id: 3, title: 'Renew Residence Card', category: 'admin'),
        TaskModel(id: 4, title: 'Plastics Collection', category: 'garbage'),
        TaskModel(id: 5, title: 'Buy groceries', category: 'daily'),
      ];

      final garbageTasks = tasks.where((t) => t.category == 'garbage').toList();
      final billsTasks = tasks.where((t) => t.category == 'bills').toList();
      final adminTasks = tasks.where((t) => t.category == 'admin').toList();

      expect(garbageTasks.length, 2);
      expect(billsTasks.length, 1);
      expect(adminTasks.length, 1);
      expect(garbageTasks.any((t) => t.title.contains('Burnable')), true);
      expect(garbageTasks.any((t) => t.title.contains('Plastics')), true);
    });

    test('Correctly detects overdue tasks vs upcoming tasks', () {
      final now = DateTime(2026, 10, 25, 12, 0);

      final overdueTask = TaskModel(
        id: 1,
        title: 'Morning Garbage drop-off',
        dueDate: DateTime(2026, 10, 25, 8, 0), // earlier today
        isCompleted: false,
      );

      final completedPastTask = TaskModel(
        id: 2,
        title: 'Pay Gas Bill',
        dueDate: DateTime(2026, 10, 24, 18, 0),
        isCompleted: true,
      );

      final upcomingTask = TaskModel(
        id: 3,
        title: 'Ward Office appointment',
        dueDate: DateTime(2026, 10, 26, 14, 0), // tomorrow
        isCompleted: false,
      );

      bool isOverdue(TaskModel t) =>
          t.dueDate != null && t.dueDate!.isBefore(now) && !t.isCompleted;

      expect(isOverdue(overdueTask), true);
      expect(isOverdue(completedPastTask), false); // completed tasks aren't overdue
      expect(isOverdue(upcomingTask), false); // future task
    });
  });
}
