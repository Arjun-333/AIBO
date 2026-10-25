import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/theme/app_theme.dart';
import '../models/task_model.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  List<TaskModel> _allTasks = [];
  String _selectedCategory = 'all';
  bool _isLoading = true;

  final List<Map<String, String>> _categories = const [
    {'id': 'all', 'label': 'All Tasks'},
    {'id': 'garbage', 'label': '🗑️ Garbage (ごみ)'},
    {'id': 'bills', 'label': '💴 Bills (支払い)'},
    {'id': 'admin', 'label': '🏛️ Ward Office (手続き)'},
    {'id': 'daily', 'label': '☀️ Daily (日常)'},
    {'id': 'work', 'label': '💼 Work (仕事)'},
  ];

  final List<Map<String, dynamic>> _garbagePresets = const [
    {
      'title': 'Burnable Garbage (燃えるごみ)',
      'description': 'Food scraps, paper waste, clothing, and burnable household items. Put out before 8:00 AM.',
      'category': 'garbage',
      'priority': 'high',
    },
    {
      'title': 'Plastics Packaging (プラ容器包装)',
      'description': 'Clean food containers, plastic wrappers, trays marked with the プラ mark.',
      'category': 'garbage',
      'priority': 'medium',
    },
    {
      'title': 'PET Bottles & Cans (ペットボトル・缶)',
      'description': 'Remove caps and labels, rinse bottles, crush slightly. Place in designated net/bins.',
      'category': 'garbage',
      'priority': 'medium',
    },
    {
      'title': 'Non-Burnable & Glass (不燃ごみ・ビン)',
      'description': 'Ceramics, glass, small metals, light bulbs in designated transparent bags.',
      'category': 'garbage',
      'priority': 'low',
    },
    {
      'title': 'Cardboard & Paper Bundles (古紙・段ボール)',
      'description': 'Fold flat and tie securely with paper twine. Keep dry if raining.',
      'category': 'garbage',
      'priority': 'low',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await DatabaseHelper.instance.getTasks();
    if (mounted) {
      setState(() {
        _allTasks = tasks;
        _isLoading = false;
      });
    }
  }

  List<TaskModel> get _filteredTasks {
    if (_selectedCategory == 'all') {
      return _allTasks;
    }
    return _allTasks.where((t) => t.category == _selectedCategory).toList();
  }

  Future<void> _toggleTaskCompletion(TaskModel task) async {
    final updated = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
      category: task.category,
      isCompleted: !task.isCompleted,
      createdAt: task.createdAt,
    );
    await DatabaseHelper.instance.updateTask(updated);
    _loadTasks();
  }

  Future<void> _deleteTask(int id) async {
    await DatabaseHelper.instance.deleteTask(id);
    _loadTasks();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted')),
      );
    }
  }

  Future<void> _showAddTaskDialog({String? presetTitle, String? presetDesc, String? presetCategory, String? presetPriority}) async {
    final titleCtrl = TextEditingController(text: presetTitle ?? '');
    final descCtrl = TextEditingController(text: presetDesc ?? '');
    String category = presetCategory ?? (_selectedCategory == 'all' ? 'daily' : _selectedCategory);
    String priority = presetPriority ?? 'medium';
    DateTime dueDate = DateTime.now();
    TimeOfDay dueTime = const TimeOfDay(hour: 8, minute: 0);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      presetTitle != null ? 'Schedule Preset Task' : 'New Task or Reminder',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    hintText: 'e.g. Ward Office Juminhyo Copy (住民票)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Notes / Details',
                    hintText: 'Bring Residence Card and My Number Card',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Category', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.where((c) => c['id'] != 'all').map((c) {
                    final isSelected = category == c['id'];
                    return ChoiceChip(
                      label: Text(c['label']!),
                      selected: isSelected,
                      selectedColor: AppTheme.primary,
                      backgroundColor: AppTheme.surfaceLightDark,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) setModalState(() => category = c['id']!);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          '${dueDate.year}/${dueDate.month.toString().padLeft(2, '0')}/${dueDate.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dueDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 1)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setModalState(() => dueDate = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time, size: 16),
                        label: Text(
                          dueTime.format(context),
                          style: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: dueTime,
                          );
                          if (picked != null) {
                            setModalState(() => dueTime = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppTheme.primary,
                    ),
                    onPressed: () async {
                      if (titleCtrl.text.trim().isEmpty) return;
                      final scheduledDateTime = DateTime(
                        dueDate.year,
                        dueDate.month,
                        dueDate.day,
                        dueTime.hour,
                        dueTime.minute,
                      );
                      final newTask = TaskModel(
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        dueDate: scheduledDateTime,
                        priority: priority,
                        category: category,
                      );
                      await DatabaseHelper.instance.insertTask(newTask);
                      Navigator.pop(ctx);
                      _loadTasks();
                    },
                    child: const Text('Save Task', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGarbagePresetsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Japan Garbage Presets (ごみ分別)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a preset to quickly schedule reminder for your neighborhood collection days:',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _garbagePresets.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
                itemBuilder: (context, index) {
                  final preset = _garbagePresets[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      preset['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
                    ),
                    subtitle: Text(
                      preset['description'] as String,
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    trailing: const Icon(Icons.add_circle_outline, color: AppTheme.accentTeal),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showAddTaskDialog(
                        presetTitle: preset['title'] as String,
                        presetDesc: preset['description'] as String,
                        presetCategory: preset['category'] as String,
                        presetPriority: preset['priority'] as String,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _allTasks.where((t) => !t.isCompleted).length;
    final completedCount = _allTasks.where((t) => t.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Planner & Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.recycling, color: AppTheme.accentTeal),
            tooltip: 'Japan Garbage Presets',
            onPressed: _showGarbagePresetsModal,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => _showAddTaskDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top Summary Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.surfaceLightDark, AppTheme.surfaceDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('$pendingCount', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                          const SizedBox(height: 2),
                          const Text('Pending', style: TextStyle(fontSize: 12, color: Colors.white60)),
                        ],
                      ),
                      Container(width: 1, height: 32, color: Colors.white12),
                      Column(
                        children: [
                          Text('$completedCount', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                          const SizedBox(height: 2),
                          const Text('Completed', style: TextStyle(fontSize: 12, color: Colors.white60)),
                        ],
                      ),
                      Container(width: 1, height: 32, color: Colors.white12),
                      InkWell(
                        onTap: _showGarbagePresetsModal,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Column(
                            children: [
                              Icon(Icons.recycling, color: AppTheme.accentTeal, size: 24),
                              SizedBox(height: 2),
                              Text('ごみ Presets', style: TextStyle(fontSize: 11, color: AppTheme.accentTeal, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Category Filter Bar
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final cat = _categories[idx];
                      final isSelected = _selectedCategory == cat['id'];
                      return ChoiceChip(
                        label: Text(cat['label']!),
                        selected: isSelected,
                        selectedColor: AppTheme.primary,
                        backgroundColor: AppTheme.surfaceDark,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() => _selectedCategory = cat['id']!);
                          }
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Task List
                Expanded(
                  child: _filteredTasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_available_outlined, size: 48, color: Colors.white.withOpacity(0.3)),
                              const SizedBox(height: 12),
                              Text(
                                _selectedCategory == 'all'
                                    ? 'No scheduled tasks yet.'
                                    : 'No tasks in this category.',
                                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () => _showAddTaskDialog(),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add your first task'),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                          itemCount: _filteredTasks.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final task = _filteredTasks[index];
                            final isOverdue = task.dueDate != null &&
                                task.dueDate!.isBefore(DateTime.now()) &&
                                !task.isCompleted;

                            return Card(
                              color: AppTheme.surfaceDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isOverdue ? AppTheme.accentRose.withOpacity(0.6) : Colors.white10,
                                ),
                              ),
                              child: ListTile(
                                leading: IconButton(
                                  icon: Icon(
                                    task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: task.isCompleted ? AppTheme.accentTeal : Colors.white38,
                                  ),
                                  onPressed: () => _toggleTaskCompletion(task),
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                    color: task.isCompleted ? Colors.white38 : Colors.white,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (task.description.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        task.description,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: task.isCompleted ? Colors.white24 : Colors.white70,
                                        ),
                                      ),
                                    ],
                                    if (task.dueDate != null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 13,
                                            color: isOverdue ? AppTheme.accentRose : Colors.white38,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${task.dueDate!.year}/${task.dueDate!.month.toString().padLeft(2, '0')}/${task.dueDate!.day.toString().padLeft(2, '0')} ${task.dueDate!.hour.toString().padLeft(2, '0')}:${task.dueDate!.minute.toString().padLeft(2, '0')}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isOverdue ? AppTheme.accentRose : Colors.white38,
                                              fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                          if (isOverdue) ...[
                                            const SizedBox(width: 6),
                                            const Text('(Overdue)', style: TextStyle(color: AppTheme.accentRose, fontSize: 11, fontWeight: FontWeight.bold)),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.white38),
                                  onPressed: () {
                                    if (task.id != null) _deleteTask(task.id!);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
