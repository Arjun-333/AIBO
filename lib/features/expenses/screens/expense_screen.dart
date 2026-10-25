import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/theme/app_theme.dart';
import '../models/expense_model.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<ExpenseModel> _allExpenses = [];
  String _selectedCategory = 'all';
  bool _isLoading = true;

  final List<Map<String, dynamic>> _categories = const [
    {'id': 'all', 'label': 'All', 'icon': Icons.all_inclusive, 'color': AppTheme.primary},
    {'id': 'groceries', 'label': 'Groceries (食料品)', 'icon': Icons.shopping_basket_outlined, 'color': Colors.greenAccent},
    {'id': 'dining', 'label': 'Dining (外食)', 'icon': Icons.restaurant_outlined, 'color': Colors.orangeAccent},
    {'id': 'konbini', 'label': 'Konbini (コンビニ)', 'icon': Icons.storefront_outlined, 'color': Colors.amberAccent},
    {'id': 'transit', 'label': 'Transit (交通費)', 'icon': Icons.train_outlined, 'color': Colors.lightBlueAccent},
    {'id': 'utilities', 'label': 'Utilities (光熱費)', 'icon': Icons.bolt_outlined, 'color': Colors.purpleAccent},
    {'id': 'rent', 'label': 'Rent (家賃)', 'icon': Icons.home_outlined, 'color': Colors.tealAccent},
    {'id': 'shopping', 'label': 'Shopping (買い物)', 'icon': Icons.shopping_bag_outlined, 'color': Colors.pinkAccent},
    {'id': 'misc', 'label': 'Misc (その他)', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final expenses = await DatabaseHelper.instance.getExpenses();
    if (mounted) {
      setState(() {
        _allExpenses = expenses;
        _isLoading = false;
      });
    }
  }

  List<ExpenseModel> get _filteredExpenses {
    if (_selectedCategory == 'all') {
      return _allExpenses;
    }
    return _allExpenses.where((e) => e.category == _selectedCategory).toList();
  }

  double get _totalMonthlySpend {
    final now = DateTime.now();
    return _allExpenses
        .where((e) => e.timestamp.year == now.year && e.timestamp.month == now.month)
        .fold<double>(0, (sum, e) => sum + e.amountJpy);
  }

  double get _totalFilteredSpend {
    return _filteredExpenses.fold<double>(0, (sum, e) => sum + e.amountJpy);
  }

  Map<String, double> get _categoryBreakdown {
    final now = DateTime.now();
    final Map<String, double> breakdown = {};
    for (final e in _allExpenses) {
      if (e.timestamp.year == now.year && e.timestamp.month == now.month) {
        breakdown[e.category] = (breakdown[e.category] ?? 0) + e.amountJpy;
      }
    }
    return breakdown;
  }

  Future<void> _deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    _loadExpenses();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense deleted')),
      );
    }
  }

  Future<void> _showAddExpenseModal() async {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String category = 'dining';
    DateTime expenseDate = DateTime.now();

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
                    const Text(
                      'Log Expense (日本円)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.accentTeal),
                  decoration: const InputDecoration(
                    labelText: 'Amount (JPY)',
                    prefixText: '¥ ',
                    prefixStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.accentTeal),
                    hintText: '580',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Description / Note',
                    hintText: 'e.g. 7-Eleven bento lunch + tea',
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
                      avatar: Icon(c['icon'] as IconData, size: 16, color: isSelected ? Colors.white : c['color'] as Color),
                      label: Text(c['label'] as String),
                      selected: isSelected,
                      selectedColor: AppTheme.primary,
                      backgroundColor: AppTheme.surfaceLightDark,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) setModalState(() => category = c['id'] as String);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    'Date: ${expenseDate.year}/${expenseDate.month.toString().padLeft(2, '0')}/${expenseDate.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: expenseDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setModalState(() => expenseDate = picked);
                    }
                  },
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
                      final amount = double.tryParse(amountCtrl.text.trim());
                      if (amount == null || amount <= 0) return;

                      final newExpense = ExpenseModel(
                        amountJpy: amount,
                        category: category,
                        note: noteCtrl.text.trim(),
                        timestamp: expenseDate,
                      );
                      await DatabaseHelper.instance.insertExpense(newExpense);
                      Navigator.pop(ctx);
                      _loadExpenses();
                    },
                    child: const Text('Record Expense', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthName = '${now.year}年${now.month}月';
    final breakdown = _categoryBreakdown;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker (円)'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: _showAddExpenseModal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Monthly Overview Header
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryDark, AppTheme.surfaceLightDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$monthName Monthly Total',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Colors.white70),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.accentTeal.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'JPY ¥',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentTeal),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '¥${_totalMonthlySpend.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 12),

                      // Category Breakdown Chips
                      if (breakdown.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: breakdown.entries.map((entry) {
                            final catInfo = _categories.firstWhere(
                              (c) => c['id'] == entry.key,
                              orElse: () => {'label': entry.key, 'color': Colors.white},
                            );
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: catInfo['color'] as Color? ?? Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${catInfo['label'].toString().split(' ').first}: ¥${entry.value.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
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
                        avatar: Icon(cat['icon'] as IconData, size: 14, color: isSelected ? Colors.white : Colors.white60),
                        label: Text(cat['label'] as String),
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
                            setState(() => _selectedCategory = cat['id'] as String);
                          }
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Expense List
                Expanded(
                  child: _filteredExpenses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 48, color: Colors.white.withOpacity(0.3)),
                              const SizedBox(height: 12),
                              Text(
                                _selectedCategory == 'all'
                                    ? 'No expenses logged yet.'
                                    : 'No expenses in this category.',
                                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: _showAddExpenseModal,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Log your first expense'),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                          itemCount: _filteredExpenses.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final expense = _filteredExpenses[index];
                            final catInfo = _categories.firstWhere(
                              (c) => c['id'] == expense.category,
                              orElse: () => {'label': expense.category, 'icon': Icons.more_horiz, 'color': Colors.grey},
                            );

                            return Card(
                              color: AppTheme.surfaceDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.white10),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: (catInfo['color'] as Color? ?? Colors.grey).withOpacity(0.2),
                                  child: Icon(
                                    catInfo['icon'] as IconData? ?? Icons.currency_yen,
                                    color: catInfo['color'] as Color? ?? Colors.white,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  expense.note.isNotEmpty ? expense.note : (catInfo['label'] as String),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                                subtitle: Text(
                                  '${expense.timestamp.year}/${expense.timestamp.month.toString().padLeft(2, '0')}/${expense.timestamp.day.toString().padLeft(2, '0')} • ${catInfo['label'].toString().split(' ').first}',
                                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '¥${expense.amountJpy.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.accentTeal,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white38),
                                      onPressed: () {
                                        if (expense.id != null) _deleteExpense(expense.id!);
                                      },
                                    ),
                                  ],
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
