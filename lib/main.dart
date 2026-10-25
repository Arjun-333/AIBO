import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/database/database_helper.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/lock_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env) safely
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // If .env is missing or not packaged in assets, gracefully continue
  }

  // Pre-initialize local database
  try {
    await DatabaseHelper.instance.database;
  } catch (e) {
    debugPrint('Database initialization notice: $e');
  }

  runApp(const AiboApp());
}

class AiboApp extends StatelessWidget {
  const AiboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIBO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LockScreen(),
    );
  }
}
