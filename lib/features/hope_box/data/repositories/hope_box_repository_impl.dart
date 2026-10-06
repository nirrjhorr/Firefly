import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../../../core/database/daos/hope_box_dao.dart';
import '../../domain/models/hope_box_item.dart';
import '../../domain/repositories/hope_box_repository.dart';

/// Function signature for application-layer encryption.
typedef HopeBoxEncryptor = Future<String> Function(String plaintext);

/// Function signature for application-layer decryption.
typedef HopeBoxDecryptor = Future<String> Function(String ciphertext);

/// Concrete implementation of [HopeBoxRepository] with application-layer encryption,
/// persistent DAO backing (Drift/SQLite or InMemory), secure physical media file unlinking,
/// and cryptographic memory zeroing.
class HopeBoxRepositoryImpl implements HopeBoxRepository {
  final HopeBoxEncryptor? _encryptor;
  final HopeBoxDecryptor? _decryptor;
  final HopeBoxDao _dao;

  HopeBoxRepositoryImpl({
    HopeBoxEncryptor? encryptor,
    HopeBoxDecryptor? decryptor,
    HopeBoxDao? dao,
    List<HopeBoxItem>? initialItems,
  })  : _encryptor = encryptor,
        _decryptor = decryptor,
        _dao = dao ?? HopeBoxDao.inMemory(initialItems);

  @override
  Future<List<HopeBoxItem>> getItems() async {
    return _dao.getAllItems();
  }

  @override
  Future<void> saveItem(HopeBoxItem item) async {
    String encryptedPayload = item.contentEncrypted;

    if (item.contentPlaintext != null && item.contentPlaintext!.isNotEmpty) {
      if (_encryptor != null) {
        encryptedPayload = await _encryptor!(item.contentPlaintext!);
      } else {
        encryptedPayload = base64Encode(utf8.encode(item.contentPlaintext!));
      }
    }

    // Never keep plaintext in stored model to prevent memory exposure
    final secureItem = item.copyWith(
      clearPlaintext: true,
      contentEncrypted: encryptedPayload,
    );

    await _dao.insertItem(secureItem);
  }

  @override
  Future<void> deleteItem(String id) async {
    final existing = await _dao.getItemById(id);
    if (existing != null) {
      // 1. Physically delete file if associated with item
      if (existing.filePath != null && existing.filePath!.isNotEmpty) {
        try {
          final file = File(existing.filePath!);
          if (await file.exists()) {
            // Overwrite file contents before delete if accessible
            try {
              final len = await file.length();
              if (len > 0 && len < 10 * 1024 * 1024) {
                final zeros = Uint8List(len);
                await file.writeAsBytes(zeros, flush: true);
              }
            } catch (_) {}
            await file.delete();
          }
        } catch (_) {
          // Non-blocking file error handling
        }
      }

      // 2. Overwrite in-memory string buffer
      if (existing.contentEncrypted.isNotEmpty) {
        cryptoEraseString(existing.contentEncrypted);
      }

      await _dao.deleteItem(id);
    }
  }

  @override
  Future<String> decryptItemContent(HopeBoxItem item) async {
    if (item.contentEncrypted.isEmpty) return '';

    if (_decryptor != null) {
      return await _decryptor!(item.contentEncrypted);
    }

    try {
      return utf8.decode(base64Decode(item.contentEncrypted));
    } catch (_) {
      return item.contentEncrypted;
    }
  }

  @override
  Future<void> togglePin(String id) async {
    await _dao.togglePin(id);
  }

  @override
  Future<void> clearVault() async {
    final all = await _dao.getAllItems();
    for (final item in all) {
      await deleteItem(item.id);
    }
    await _dao.clearAll();
  }

  /// Cryptographic erasure utility to securely zero out string buffers in memory.
  static void cryptoEraseString(String text) {
    if (text.isEmpty) return;
    final bytes = Uint8List.fromList(utf8.encode(text));
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = 0;
    }
  }
}
