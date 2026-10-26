import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/backup/backup_service.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/sound_motion_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../chat/screens/chat_screen.dart';
import '../../emergency/screens/emergency_screen.dart';
import '../../language/screens/phrasebook_screen.dart';
import '../../planner/models/task_model.dart';
import '../../planner/screens/planner_screen.dart';
import '../../expenses/models/expense_model.dart';
import '../../expenses/screens/expense_screen.dart';
import '../../vault/screens/vault_screen.dart';
import '../../maps/screens/map_screen.dart';
import '../../medication/screens/medication_screen.dart';
import '../../transit/screens/transit_screen.dart';
import '../widgets/tokyo_companion_card.dart';
import '../widgets/japanese_motifs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<TaskModel> _tasks = [];
  List<ExpenseModel> _expenses = [];
  bool _isLoading = true;

  // Carousel Controller for Hero Banners
  final PageController _pageController = PageController();
  int _currentHeroPage = 0;

  final List<String> _omikujiFortunes = [
    '大吉 (Daikichi): Excellent Luck! Great day to explore a new Tokyo neighborhood.',
    '中吉 (Chukichi): Moderate Luck! A warm bowl of ramen will bring positive energy.',
    '吉 (Kichi): Good Fortune! Today is an optimal day for completing ward office tasks.',
    '末吉 (Suekichi): Future Luck! Step by step, your life in Japan is flourishing.',
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    final tasks = await DatabaseHelper.instance.getTasks();
    final expenses = await DatabaseHelper.instance.getExpenses();
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _expenses = expenses;
        _isLoading = false;
      });
    }
  }

  String _getJapaneseDateString(DateTime date) {
    const weekdaysJp = ['月', '火', '水', '木', '金', '土', '日'];
    final weekday = weekdaysJp[date.weekday - 1];
    return '${date.year}年${date.month}月${date.day}日 ($weekday)';
  }

  void _drawOmikuji() {
    final fortune = _omikujiFortunes[Random().nextInt(_omikujiFortunes.length)];
    SoundMotionService.instance.showJapaneseNotification(
      context,
      title: 'Omikuji Fortune (おみくじ結果)',
      messageJa: fortune,
      iconEmoji: '⛩️',
      accentColor: AppTheme.vermilionRed,
    );
  }

  void _onCulturalIconTap(String title, String meaning, String emoji) {
    SoundMotionService.instance.showJapaneseNotification(
      context,
      title: '$title ($emoji)',
      messageJa: meaning,
      iconEmoji: emoji,
      accentColor: AppTheme.matchaTeal,
    );
  }

  Future<void> _exportBackup() async {
    final passCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppTheme.warmBorder)),
        title: const Text('Export Encrypted Backup', style: TextStyle(color: AppTheme.inkBlack, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter a password to encrypt your database backup with AES-256:',
              style: TextStyle(fontSize: 13, color: AppTheme.charcoal),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Backup Password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppTheme.mutedGrey))),
          ElevatedButton(
            onPressed: () async {
              if (passCtrl.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                try {
                  await BackupService.instance.exportEncryptedBackup(passCtrl.text.trim());
                  if (mounted) {
                    SoundMotionService.instance.showJapaneseNotification(
                      context,
                      title: 'Backup Successful (バックアップ完了)',
                      messageJa: 'AES-256 encrypted database exported safely.',
                      iconEmoji: '🛡️',
                      accentColor: AppTheme.matchaTeal,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Backup failed: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Export & Share'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildDashboardView(),
      const ChatScreen(),
      const PhrasebookScreen(),
      const EmergencyScreen(isQuickAccess: false),
    ];

    return Scaffold(
      backgroundColor: AppTheme.washiCream,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.04, 0.0), end: Offset.zero).animate(animation),
              child: child,
            ),
          );
        },
        child: pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.warmBorder, width: 1.2)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            SoundMotionService.instance.playTapSound();
            setState(() => _currentIndex = index);
            if (index == 0) _loadDashboardData();
          },
          backgroundColor: AppTheme.washiCream,
          indicatorColor: AppTheme.inkBlack.withOpacity(0.08),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: AppTheme.charcoal),
              selectedIcon: Icon(Icons.dashboard, color: AppTheme.inkBlack),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.forum_outlined, color: AppTheme.charcoal),
              selectedIcon: Icon(Icons.forum, color: AppTheme.inkBlack),
              label: 'AI Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.translate_outlined, color: AppTheme.charcoal),
              selectedIcon: Icon(Icons.translate, color: AppTheme.matchaTeal),
              label: 'Phrases',
            ),
            NavigationDestination(
              icon: Icon(Icons.emergency_outlined, color: AppTheme.charcoal),
              selectedIcon: Icon(Icons.emergency, color: AppTheme.vermilionRed),
              label: 'Emergency',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardView() {
    final now = DateTime.now();
    final todayExpenses = _expenses
        .where((e) => e.timestamp.year == now.year && e.timestamp.month == now.month && e.timestamp.day == now.day)
        .fold<double>(0, (sum, item) => sum + item.amountJpy);

    final monthlyExpenses = _expenses
        .where((e) => e.timestamp.year == now.year && e.timestamp.month == now.month)
        .fold<double>(0, (sum, item) => sum + item.amountJpy);

    final pendingTasks = _tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = _tasks.where((t) => t.isCompleted).toList();

    final garbageTasksToday = _tasks.where((t) {
      if (t.category != 'garbage') return false;
      if (t.dueDate == null) return false;
      return t.dueDate!.year == now.year && t.dueDate!.month == now.month && t.dueDate!.day == now.day;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.washiCream,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'A I B O',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 3.0, fontSize: 18),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.inkBlack,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('あいぼう', style: TextStyle(fontSize: 10, color: AppTheme.washiCream, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              SoundMotionService.instance.playTapSound();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MedicationScreen()),
              );
            },
            icon: const Icon(Icons.medication_outlined, color: AppTheme.matchaTeal),
            tooltip: 'Tablet Reminder & Pharmacy',
          ),
          IconButton(
            onPressed: () {
              SoundMotionService.instance.playTapSound();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransitScreen()),
              );
            },
            icon: const Icon(Icons.directions_subway_outlined, color: AppTheme.inkBlack),
            tooltip: 'Tokyo Transit Navigator',
          ),
          IconButton(
            onPressed: () {
              SoundMotionService.instance.playTapSound();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapScreen()),
              );
            },
            icon: const Icon(Icons.map_outlined, color: AppTheme.inkBlack),
            tooltip: 'Offline Maps & Navigation',
          ),
          PopupMenuButton<String>(
            tooltip: 'More tools',
            icon: const Icon(Icons.more_horiz, color: AppTheme.charcoal),
            onSelected: (value) {
              SoundMotionService.instance.playTapSound();
              if (value == 'vault') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const VaultScreen()));
              } else if (value == 'backup') {
                _exportBackup();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'vault', child: Text('Document Vault')),
              PopupMenuItem(value: 'backup', child: Text('Export Encrypted Backup')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.inkBlack))
          : RefreshIndicator(
              color: AppTheme.inkBlack,
              backgroundColor: AppTheme.washiCream,
              onRefresh: _loadDashboardData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  // Interactive Motion Carousel: Muchi Neko Cat <-> Welcome to Japan Torii Banner
                  SizedBox(
                    height: 360,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (page) => setState(() => _currentHeroPage = page),
                      children: [
                        // Slide 1: "Muchi Neko" Bauhaus Companion
                        TokyoCompanionCard(
                          completedTasks: completedTasks.length,
                          totalTasks: _tasks.length,
                          totalSpendJpy: monthlyExpenses,
                        ),

                        // Slide 2: "Welcome to Japan" Torii Gate & Omikuji Banner
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: JapaneseToriiHeroBanner(onToriiTap: _drawOmikuji),
                        ),
                      ],
                    ),
                  ),

                  // Carousel Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPageIndicator(0),
                      const SizedBox(width: 8),
                      _buildPageIndicator(1),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Date Banner & Security
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getJapaneseDateString(now),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: AppTheme.charcoal,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.warmBorder),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_outlined, size: 12, color: AppTheme.matchaTeal),
                            SizedBox(width: 4),
                            Text('100% Offline • AES-256', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.charcoal)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Active Garbage Reminder Banner if scheduled today
                  if (garbageTasksToday.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.matchaTeal, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFFE8F2F0),
                            child: Icon(Icons.recycling, color: AppTheme.matchaTeal, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'TODAY\'S GARBAGE COLLECTION (ごみ収集日)',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.matchaTeal, letterSpacing: 0.8),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  garbageTasksToday.map((g) => g.title).join(' • '),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.inkBlack),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // Interactive Japanese Icon Grid (Flaticon Style Inspired by Image 2)
                  JapaneseIconGridWidget(onIconTap: _onCulturalIconTap),

                  const SizedBox(height: 18),

                  // Feature Navigation Cards: Daily Planner & JPY Expenses
                  Row(
                    children: [
                      // Planner Card
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            SoundMotionService.instance.playTapSound();
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PlannerScreen()),
                            );
                            _loadDashboardData();
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.warmBorder, width: 1.2),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.calendar_month, color: AppTheme.inkBlack, size: 22),
                                    Icon(Icons.arrow_forward, size: 14, color: AppTheme.mutedGrey),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Daily Planner',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.inkBlack),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${pendingTasks.length} pending tasks',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.mutedGrey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Expenses Card
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            SoundMotionService.instance.playTapSound();
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ExpenseScreen()),
                            );
                            _loadDashboardData();
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.warmBorder, width: 1.2),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.account_balance_wallet_outlined, color: AppTheme.inkBlack, size: 22),
                                    Icon(Icons.arrow_forward, size: 14, color: AppTheme.mutedGrey),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Expense Tracker',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.inkBlack),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Month: ¥${monthlyExpenses.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.mutedGrey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Today's Spending Capsule
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.warmBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: Color(0xFFF0EDE5),
                              child: Text('¥', style: TextStyle(color: AppTheme.inkBlack, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Today\'s Spending (本日支出)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.charcoal),
                            ),
                          ],
                        ),
                        Text(
                          '¥${todayExpenses.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.inkBlack),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Pending Tasks Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PENDING TASKS & SCHEDULE',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.charcoal),
                      ),
                      TextButton(
                        onPressed: () async {
                          SoundMotionService.instance.playTapSound();
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PlannerScreen()),
                          );
                          _loadDashboardData();
                        },
                        child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.inkBlack)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (pendingTasks.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.warmBorder),
                      ),
                      child: const Center(
                        child: Text(
                          'All caught up! No pending tasks.',
                          style: TextStyle(color: AppTheme.mutedGrey, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ...pendingTasks.take(4).map(
                          (task) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.warmBorder),
                            ),
                            child: ListTile(
                              leading: IconButton(
                                icon: const Icon(Icons.radio_button_unchecked, color: AppTheme.sandAccent),
                                onPressed: () async {
                                  final updated = TaskModel(
                                    id: task.id,
                                    title: task.title,
                                    description: task.description,
                                    dueDate: task.dueDate,
                                    priority: task.priority,
                                    category: task.category,
                                    isCompleted: true,
                                    createdAt: task.createdAt,
                                  );
                                  await DatabaseHelper.instance.updateTask(updated);
                                  SoundMotionService.instance.showJapaneseNotification(
                                    context,
                                    title: 'Task Completed! (完了)',
                                    messageJa: 'お疲れ様でした！「${task.title}」',
                                    iconEmoji: '✅',
                                    accentColor: AppTheme.matchaTeal,
                                  );
                                  _loadDashboardData();
                                },
                              ),
                              title: Text(
                                task.title,
                                style: const TextStyle(color: AppTheme.inkBlack, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              subtitle: task.dueDate != null
                                  ? Text(
                                      '${task.dueDate!.month}/${task.dueDate!.day} • ${task.category}',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.mutedGrey),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = _currentHeroPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 24 : 8,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.inkBlack : AppTheme.sandAccent.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
