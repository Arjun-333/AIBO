import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  static final BackupService instance = BackupService._init();
  BackupService._init();

  /// Derives a 32-byte (256-bit) AES key from the user passphrase using SHA-256
  enc.Key _deriveKey(String passphrase) {
    final bytes = utf8.encode(passphrase);
    final digest = sha256.convert(bytes);
    return enc.Key(Uint8List.fromList(digest.bytes));
  }

  /// Exports the local database to an encrypted file and triggers Android system share sheet
  Future<String> exportEncryptedBackup(String passphrase) async {
    final dbPath = await getDatabasesPath();
    final dbFile = File(join(dbPath, 'aibo_master.db'));

    if (!await dbFile.exists()) {
      throw Exception('Database file does not exist to back up.');
    }

    final dbBytes = await dbFile.readAsBytes();
    final key = _deriveKey(passphrase);
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

    final encrypted = encrypter.encryptBytes(dbBytes, iv: iv);

    // Prepare container with IV prefix
    final container = {
      'version': '1.0',
      'created_at': DateTime.now().toIso8601String(),
      'iv': iv.base64,
      'payload': encrypted.base64,
    };

    final tempDir = await getTemporaryDirectory();
    final dateStr = DateTime.now().toIso8601String().substring(0, 10).replaceAll('-', '');
    final backupFile = File(join(tempDir.path, 'aibo_backup_$dateStr.enc'));

    await backupFile.writeAsString(jsonEncode(container));

    // Trigger share sheet
    await Share.shareXFiles(
      [XFile(backupFile.path)],
      text: 'AIBO Encrypted Backup ($dateStr)',
    );

    return backupFile.path;
  }

  /// Restores database from an encrypted backup file
  Future<bool> restoreFromEncryptedBackup(File backupFile, String passphrase) async {
    try {
      final jsonString = await backupFile.readAsString();
      final Map<String, dynamic> container = jsonDecode(jsonString);

      final iv = enc.IV.fromBase64(container['iv'] as String);
      final payloadBase64 = container['payload'] as String;

      final key = _deriveKey(passphrase);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

      final decryptedBytes = encrypter.decryptBytes(
        enc.Encrypted.fromBase64(payloadBase64),
        iv: iv,
      );

      final dbPath = await getDatabasesPath();
      final targetFile = File(join(dbPath, 'aibo_master.db'));

      // Close open database connections first before replacing file
      await targetFile.writeAsBytes(decryptedBytes, flush: true);
      return true;
    } catch (e) {
      return false; // Decryption failed or corrupted file
    }
  }
}
