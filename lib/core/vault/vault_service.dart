import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class VaultService {
  static final VaultService instance = VaultService._init();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _vaultKeyName = 'aibo_vault_encryption_key';

  VaultService._init();

  Future<enc.Key> _getVaultKey() async {
    String? keyStr = await _storage.read(key: _vaultKeyName);
    if (keyStr == null) {
      keyStr = DateTime.now().microsecondsSinceEpoch.toString() + '_vault_master';
      await _storage.write(key: _vaultKeyName, value: keyStr);
    }
    final digest = sha256.convert(utf8.encode(keyStr));
    return enc.Key(Uint8List.fromList(digest.bytes));
  }

  /// Encrypts raw image bytes and saves to private app storage, returning relative encrypted file path
  Future<String> saveEncryptedDocument({
    required Uint8List imageBytes,
    required String originalFileName,
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final vaultDir = Directory(join(docsDir.path, 'vault_secure'));
    if (!await vaultDir.exists()) {
      await vaultDir.create(recursive: true);
    }

    final key = await _getVaultKey();
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

    final encryptedBytes = encrypter.encryptBytes(imageBytes, iv: iv);

    // Save with metadata prefix: 16 bytes IV + encrypted ciphertext
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final encryptedFileName = 'doc_${timestamp}.enc';
    final targetFile = File(join(vaultDir.path, encryptedFileName));

    final combinedBytes = Uint8List(16 + encryptedBytes.bytes.length);
    combinedBytes.setRange(0, 16, iv.bytes);
    combinedBytes.setRange(16, combinedBytes.length, encryptedBytes.bytes);

    await targetFile.writeAsBytes(combinedBytes, flush: true);
    return encryptedFileName;
  }

  /// Decrypts document bytes on-the-fly into memory for in-app viewing
  Future<Uint8List> readDecryptedDocument(String encryptedFileName) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final file = File(join(docsDir.path, 'vault_secure', encryptedFileName));

    if (!await file.exists()) {
      throw Exception('Encrypted document file not found.');
    }

    final rawBytes = await file.readAsBytes();
    if (rawBytes.length <= 16) {
      throw Exception('Corrupted encrypted document file.');
    }

    final ivBytes = rawBytes.sublist(0, 16);
    final cipherBytes = rawBytes.sublist(16);

    final key = await _getVaultKey();
    final iv = enc.IV(ivBytes);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

    final decrypted = encrypter.decryptBytes(
      enc.Encrypted(cipherBytes),
      iv: iv,
    );

    return Uint8List.fromList(decrypted);
  }

  /// Deletes encrypted document from sandbox disk
  Future<void> deleteEncryptedDocument(String encryptedFileName) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final file = File(join(docsDir.path, 'vault_secure', encryptedFileName));
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
