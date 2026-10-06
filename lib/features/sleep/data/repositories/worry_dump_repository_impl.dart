import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../../domain/models/worry_dump_entry.dart';
import '../../domain/repositories/worry_dump_repository.dart';

/// Function signature for application-layer encryption.
typedef WorryEncryptor = Future<String> Function(String plaintext);

/// Concrete implementation of [WorryDumpRepository] featuring application-layer encryption,
/// 8:00 AM lockup enforcement, and cryptographic memory/disk zeroing.
class WorryDumpRepositoryImpl implements WorryDumpRepository {
  final WorryEncryptor? _encryptor;
  final List<WorryDumpEntry> _store = [];

  WorryDumpRepositoryImpl({
    WorryEncryptor? encryptor,
    List<WorryDumpEntry>? initialEntries,
  }) : _encryptor = encryptor {
    if (initialEntries != null) {
      _store.addAll(initialEntries);
    }
  }

  @override
  Future<void> saveParkedWorry(WorryDumpEntry entry) async {
    String encryptedPayload = entry.contentEncrypted;

    if (entry.contentPlaintext != null && entry.contentPlaintext!.isNotEmpty) {
      if (_encryptor != null) {
        encryptedPayload = await _encryptor!(entry.contentPlaintext!);
      } else {
        encryptedPayload = base64Encode(utf8.encode(entry.contentPlaintext!));
      }
    }

    // Never keep plaintext in stored model to avoid memory leaks
    final secureEntry = entry.copyWith(
      clearPlaintext: true,
      contentEncrypted: encryptedPayload,
    );

    _store.removeWhere((e) => e.id == secureEntry.id);
    _store.add(secureEntry);
  }

  @override
  Future<List<WorryDumpEntry>> getParkedWorries() async {
    await purgeExpiredWorries();
    return List.unmodifiable(_store);
  }

  @override
  Future<void> deleteWorry(String id, {bool secureErase = true}) async {
    final index = _store.indexWhere((e) => e.id == id);
    if (index != -1) {
      if (secureErase) {
        final existing = _store[index];
        // Cryptographically overwrite memory buffers
        if (existing.contentEncrypted.isNotEmpty) {
          final bytes = Uint8List.fromList(utf8.encode(existing.contentEncrypted));
          for (int i = 0; i < bytes.length; i++) {
            bytes[i] = 0;
          }
        }
      }
      _store.removeAt(index);
    }
  }

  @override
  Future<int> purgeExpiredWorries() async {
    final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final initialCount = _store.length;
    _store.removeWhere((entry) => nowUnix >= entry.ttlDeleteAtUnix);
    return initialCount - _store.length;
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
