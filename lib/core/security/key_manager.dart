import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'key_manager.g.dart';

/// Manages the secure generation, storage, and retrieval of the master database key.
class KeyManager {
  final FlutterSecureStorage _storage;

  static const String _dbKeyStorageKey = 'firefly_db_master_key';

  KeyManager(this._storage);

  /// Retrieves the database key, or generates and stores a new one if it doesn't exist.
  Future<String> getOrGenerateDatabaseKey() async {
    final existingKey = await _storage.read(key: _dbKeyStorageKey);
    if (existingKey != null && existingKey.isNotEmpty) {
      return existingKey;
    }

    // Generate a new 256-bit (32 bytes) random key
    final random = Random.secure();
    final keyBytes = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      keyBytes[i] = random.nextInt(256);
    }
    
    final newKey = base64Encode(keyBytes);

    // Store securely:
    // synchronizable: false prevents syncing to iCloud/Google Drive
    // accessible: first_unlock or unlocked ensures hardware binding where applicable
    await _storage.write(
      key: _dbKeyStorageKey,
      value: newKey,
      iOptions: const IOSOptions(
        accessibility: KeychainAccessibility.passcode,
        synchronizable: false,
      ),
      aOptions: const AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );

    return newKey;
  }
}

@riverpod
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  return const FlutterSecureStorage();
}

@riverpod
KeyManager keyManager(KeyManagerRef ref) {
  return KeyManager(ref.watch(secureStorageProvider));
}
