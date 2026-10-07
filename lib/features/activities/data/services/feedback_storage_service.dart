import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/models/activity_effectiveness_log.dart';

/// Local persistent storage service saving user post-activity feedback responses.
///
/// Ensures all user ratings, timestamps, shift data, and reflection chips
/// survive app restarts and are securely stored on-device.
class FeedbackStorageService {
  static const String _fileName = 'firefly_feedback_logs.json';
  File? _file;
  List<ActivityEffectivenessLog>? _cache;

  Future<File> _getFile() async {
    if (_file != null) return _file!;
    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/$_fileName');
    return _file!;
  }

  /// Retrieves all saved feedback responses from disk.
  Future<List<ActivityEffectivenessLog>> getLogs() async {
    if (_cache != null) return List.unmodifiable(_cache!);
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        _cache = [];
        return List.unmodifiable(_cache!);
      }
      final contents = await file.readAsString();
      if (contents.trim().isEmpty) {
        _cache = [];
        return List.unmodifiable(_cache!);
      }
      final decoded = jsonDecode(contents) as List<dynamic>;
      _cache = decoded
          .map((item) => ActivityEffectivenessLog.fromJson(item as Map<String, dynamic>))
          .toList();
      return List.unmodifiable(_cache!);
    } catch (_) {
      _cache = [];
      return List.unmodifiable(_cache!);
    }
  }

  /// Persists a new feedback response log locally on device.
  Future<void> saveLog(ActivityEffectivenessLog log) async {
    final currentLogs = (await getLogs()).toList();
    currentLogs.add(log);
    _cache = currentLogs;
    try {
      final file = await _getFile();
      final jsonList = currentLogs.map((e) => e.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList), flush: true);
    } catch (_) {}
  }

  /// Clears stored feedback logs (used for data purging).
  Future<void> clearLogs() async {
    _cache = [];
    try {
      final file = await _getFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}

/// Provider for [FeedbackStorageService].
final feedbackStorageServiceProvider = Provider<FeedbackStorageService>((ref) {
  return FeedbackStorageService();
});
