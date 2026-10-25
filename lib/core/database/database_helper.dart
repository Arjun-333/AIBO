import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/emergency/models/emergency_card.dart';
import '../../features/planner/models/task_model.dart';
import '../../features/expenses/models/expense_model.dart';
import '../../features/vault/models/document_record.dart';
import '../../features/chat/models/chat_message.dart';
import '../../features/maps/models/saved_location.dart';
import '../../features/medication/models/medication_reminder.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static const _secureStorage = FlutterSecureStorage();
  static const _dbPassphraseKey = 'aibo_db_encryption_key';

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('aibo_master.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Retrieve or generate master encryption key in Android Keystore
    String? password = await _secureStorage.read(key: _dbPassphraseKey);
    if (password == null) {
      password = _generateRandomKey();
      await _secureStorage.write(key: _dbPassphraseKey, value: password);
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  String _generateRandomKey() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Emergency Card Table
    await db.execute('''
      CREATE TABLE emergency_card (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        blood_type TEXT NOT NULL,
        emergency_contact_name TEXT NOT NULL,
        emergency_contact_phone TEXT NOT NULL,
        allergies TEXT,
        medical_notes TEXT,
        residence_card_number TEXT,
        insurance_number TEXT,
        updated_at TEXT NOT NULL
      )
    ''');

    // 2. Tasks / Planner Table
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        priority TEXT NOT NULL,
        category TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // 3. Expenses Table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount_jpy REAL NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        timestamp TEXT NOT NULL
      )
    ''');

    // 4. Document Vault Table
    await db.execute('''
      CREATE TABLE document_vault (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        doc_type TEXT NOT NULL,
        encrypted_file_path TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 5. Chat History Table
    await db.execute('''
      CREATE TABLE chat_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // 6. User Settings / Key-Value Store
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // 7. Saved Locations Table (Offline Maps)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS saved_locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name_en TEXT NOT NULL,
        name_ja TEXT,
        category TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT,
        notes TEXT,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // 8. Medication / Tablet Reminders Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medication_reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name_en TEXT NOT NULL,
        name_ja TEXT,
        dosage TEXT NOT NULL,
        timing TEXT NOT NULL,
        scheduled_time TEXT NOT NULL,
        instructions TEXT,
        category TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        last_taken_at TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Seed default emergency card if empty
    await db.insert('emergency_card', {
      'full_name': 'My Emergency Card',
      'blood_type': 'Unknown',
      'emergency_contact_name': 'Emergency Contact',
      'emergency_contact_phone': '',
      'allergies': 'None listed',
      'medical_notes': '',
      'residence_card_number': '',
      'insurance_number': '',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // --- CRUD: Emergency Card ---
  Future<EmergencyCard?> getEmergencyCard() async {
    final db = await database;
    final maps = await db.query('emergency_card', limit: 1);
    if (maps.isNotEmpty) {
      return EmergencyCard.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateEmergencyCard(EmergencyCard card) async {
    final db = await database;
    if (card.id != null) {
      return await db.update(
        'emergency_card',
        card.toMap(),
        where: 'id = ?',
        whereArgs: [card.id],
      );
    } else {
      return await db.insert('emergency_card', card.toMap());
    }
  }

  // --- CRUD: Tasks ---
  Future<int> insertTask(TaskModel task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<TaskModel>> getTasks({bool? completed}) async {
    final db = await database;
    final where = completed != null ? 'is_completed = ?' : null;
    final whereArgs = completed != null ? [completed ? 1 : 0] : null;
    final result = await db.query(
      'tasks',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'due_date ASC, created_at DESC',
    );
    return result.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<int> updateTask(TaskModel task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD: Expenses ---
  Future<int> insertExpense(ExpenseModel expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<ExpenseModel>> getExpenses() async {
    final db = await database;
    final result = await db.query('expenses', orderBy: 'timestamp DESC');
    return result.map((m) => ExpenseModel.fromMap(m)).toList();
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD: Chat History ---
  Future<int> insertChatMessage(ChatMessage message) async {
    final db = await database;
    return await db.insert('chat_history', message.toMap());
  }

  Future<List<ChatMessage>> getChatMessages(String sessionId) async {
    final db = await database;
    final result = await db.query(
      'chat_history',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );
    return result.map((m) => ChatMessage.fromMap(m)).toList();
  }

  Future<int> clearChatHistory(String sessionId) async {
    final db = await database;
    return await db.delete(
      'chat_history',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  // --- CRUD: Document Vault ---
  Future<int> insertDocument(DocumentRecord doc) async {
    final db = await database;
    return await db.insert('document_vault', doc.toMap());
  }

  Future<List<DocumentRecord>> getDocuments({String? docType}) async {
    final db = await database;
    final where = (docType != null && docType != 'all') ? 'doc_type = ?' : null;
    final whereArgs = (docType != null && docType != 'all') ? [docType] : null;
    final result = await db.query(
      'document_vault',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'updated_at DESC',
    );
    return result.map((m) => DocumentRecord.fromMap(m)).toList();
  }

  Future<int> deleteDocument(int id) async {
    final db = await database;
    return await db.delete('document_vault', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD: Saved Locations (Offline Maps) ---
  Future<int> insertLocation(SavedLocation loc) async {
    final db = await database;
    await _ensureLocationsTable(db);
    return await db.insert('saved_locations', loc.toMap());
  }

  Future<List<SavedLocation>> getSavedLocations() async {
    final db = await database;
    await _ensureLocationsTable(db);
    final result = await db.query('saved_locations', orderBy: 'is_favorite DESC, created_at DESC');
    return result.map((m) => SavedLocation.fromMap(m)).toList();
  }

  Future<int> deleteLocation(int id) async {
    final db = await database;
    await _ensureLocationsTable(db);
    return await db.delete('saved_locations', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> _ensureLocationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS saved_locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name_en TEXT NOT NULL,
        name_ja TEXT,
        category TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT,
        notes TEXT,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // --- CRUD: Medication & Tablet Reminders ---
  Future<int> insertMedication(MedicationReminder med) async {
    final db = await database;
    await _ensureMedicationTable(db);
    return await db.insert('medication_reminders', med.toMap());
  }

  Future<List<MedicationReminder>> getMedications() async {
    final db = await database;
    await _ensureMedicationTable(db);
    final result = await db.query(
      'medication_reminders',
      orderBy: 'scheduled_time ASC, created_at DESC',
    );
    return result.map((m) => MedicationReminder.fromMap(m)).toList();
  }

  Future<int> updateMedication(MedicationReminder med) async {
    final db = await database;
    await _ensureMedicationTable(db);
    return await db.update(
      'medication_reminders',
      med.toMap(),
      where: 'id = ?',
      whereArgs: [med.id],
    );
  }

  Future<int> deleteMedication(int id) async {
    final db = await database;
    await _ensureMedicationTable(db);
    return await db.delete(
      'medication_reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _ensureMedicationTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medication_reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name_en TEXT NOT NULL,
        name_ja TEXT,
        dosage TEXT NOT NULL,
        timing TEXT NOT NULL,
        scheduled_time TEXT NOT NULL,
        instructions TEXT,
        category TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        last_taken_at TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
