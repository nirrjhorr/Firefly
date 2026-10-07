import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/security/key_manager.dart';
import '../../domain/models/crisis_support_config.dart';

/// Storage service persisting custom or preset crisis support targets.
class CrisisSupportStorageService {
  CrisisSupportStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const String _storageKey = 'firefly_crisis_support_config_v1';
  CrisisSupportConfig? _inMemoryCache;

  Future<CrisisSupportConfig?> loadConfig() async {
    if (_inMemoryCache != null) return _inMemoryCache;
    try {
      final raw = await _storage.read(key: _storageKey);
      if (raw != null && raw.trim().isNotEmpty) {
        _inMemoryCache = CrisisSupportConfig.deserialize(raw);
        return _inMemoryCache;
      }
    } catch (_) {}
    return _inMemoryCache;
  }

  Future<void> saveConfig(CrisisSupportConfig config) async {
    _inMemoryCache = config;
    try {
      await _storage.write(key: _storageKey, value: config.serialize());
    } catch (_) {}
  }

  Future<void> clearConfig() async {
    _inMemoryCache = null;
    try {
      await _storage.delete(key: _storageKey);
    } catch (_) {}
  }
}

final crisisSupportStorageServiceProvider =
    Provider<CrisisSupportStorageService>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return CrisisSupportStorageService(storage: storage);
});
