import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/contracts/voice_recognition_port.dart';
import '../../data/adapters/vosk_voice_adapter.dart';
import '../../data/repositories/journal_repository_impl.dart';
import '../../domain/models/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';

/// Preset intervals for auto-deletion and unsent letters.
enum JournalTtlOption {
  none,
  oneHour,
  twentyFourHours,
  sevenDays;

  int? get durationSeconds {
    switch (this) {
      case JournalTtlOption.none:
        return null;
      case JournalTtlOption.oneHour:
        return 3600;
      case JournalTtlOption.twentyFourHours:
        return 86400;
      case JournalTtlOption.sevenDays:
        return 604800;
    }
  }

  String get displayName {
    switch (this) {
      case JournalTtlOption.none:
        return 'Keep permanently';
      case JournalTtlOption.oneHour:
        return '1 Hour';
      case JournalTtlOption.twentyFourHours:
        return '24 Hours';
      case JournalTtlOption.sevenDays:
        return '7 Days';
    }
  }

  int? calculateExpiryUnix([int? fromUnix]) {
    final secs = durationSeconds;
    if (secs == null) return null;
    final base = fromUnix ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    return base + secs;
  }
}

/// State for [JournalEditorController].
@immutable
class JournalEditorState {
  const JournalEditorState({
    required this.id,
    this.title = '',
    this.content = '',
    this.wordCount = 0,
    this.ttlOption = JournalTtlOption.none,
    this.isListening = false,
    this.isAutoDeleteEnabled = false,
    this.isSaving = false,
    this.isBurned = false,
    this.errorMessage,
    this.contentType = 'text',
    this.initialCreatedAtUnix,
  });

  final String id;
  final String title;
  final String content;
  final int wordCount;
  final JournalTtlOption ttlOption;
  final bool isListening;
  final bool isAutoDeleteEnabled;
  final bool isSaving;
  final bool isBurned;
  final String? errorMessage;
  final String contentType;
  final int? initialCreatedAtUnix;

  JournalEditorState copyWith({
    String? id,
    String? title,
    String? content,
    int? wordCount,
    JournalTtlOption? ttlOption,
    bool? isListening,
    bool? isAutoDeleteEnabled,
    bool? isSaving,
    bool? isBurned,
    String? errorMessage,
    bool clearError = false,
    String? contentType,
    int? initialCreatedAtUnix,
  }) {
    return JournalEditorState(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      wordCount: wordCount ?? this.wordCount,
      ttlOption: ttlOption ?? this.ttlOption,
      isListening: isListening ?? this.isListening,
      isAutoDeleteEnabled: isAutoDeleteEnabled ?? this.isAutoDeleteEnabled,
      isSaving: isSaving ?? this.isSaving,
      isBurned: isBurned ?? this.isBurned,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      contentType: contentType ?? this.contentType,
      initialCreatedAtUnix: initialCreatedAtUnix ?? this.initialCreatedAtUnix,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEditorState &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          content == other.content &&
          wordCount == other.wordCount &&
          ttlOption == other.ttlOption &&
          isListening == other.isListening &&
          isAutoDeleteEnabled == other.isAutoDeleteEnabled &&
          isSaving == other.isSaving &&
          isBurned == other.isBurned &&
          errorMessage == other.errorMessage &&
          contentType == other.contentType &&
          initialCreatedAtUnix == other.initialCreatedAtUnix;

  @override
  int get hashCode => Object.hash(
        id,
        title,
        content,
        wordCount,
        ttlOption,
        isListening,
        isAutoDeleteEnabled,
        isSaving,
        isBurned,
        errorMessage,
        contentType,
        initialCreatedAtUnix,
      );
}

/// Controller managing journal entry composition, reactive word counting,
/// voice dictation, TTL auto-delete configuration, and cryptographic burn erasure.
class JournalEditorController extends StateNotifier<JournalEditorState> {
  JournalEditorController({
    required JournalRepository repository,
    required VoiceRecognitionPort voicePort,
    String? entryId,
    JournalTtlOption initialTtl = JournalTtlOption.none,
  })  : _repository = repository,
        _voicePort = voicePort,
        super(JournalEditorState(
          id: entryId ?? _generateUniqueId(),
          ttlOption: initialTtl,
          isAutoDeleteEnabled: initialTtl != JournalTtlOption.none,
        )) {
    if (entryId != null && entryId.isNotEmpty) {
      loadEntry(entryId);
    }
  }

  final JournalRepository _repository;
  final VoiceRecognitionPort _voicePort;
  StreamSubscription<String>? _voiceSubscription;
  StreamSubscription<String>? _voiceErrorSubscription;
  String _preVoiceContent = '';

  /// Updates the journal entry title.
  void setTitle(String title) {
    if (!mounted) return;
    state = state.copyWith(title: title);
  }

  /// Updates the content buffer and recalculates the reactive word count.
  void setContent(String content) {
    if (!mounted) return;
    state = state.copyWith(
      content: content,
      wordCount: _countWords(content),
    );
  }

  /// Sets the TTL auto-delete horizon.
  void setTtlOption(JournalTtlOption option) {
    if (!mounted) return;
    state = state.copyWith(
      ttlOption: option,
      isAutoDeleteEnabled: option != JournalTtlOption.none,
    );
  }

  /// Toggles offline voice dictation on or off.
  Future<void> toggleVoiceDictation() async {
    if (state.isListening) {
      await stopVoiceDictation();
    } else {
      await startVoiceDictation();
    }
  }

  /// Starts voice dictation, streaming recognized words directly into editor content.
  Future<void> startVoiceDictation() async {
    if (state.isListening || !mounted) return;

    _preVoiceContent = state.content;
    state = state.copyWith(isListening: true, contentType: 'voice', clearError: true);

    _voiceSubscription?.cancel();
    _voiceErrorSubscription?.cancel();

    _voiceSubscription = _voicePort.transcribePartial().listen((hypothesis) {
      if (!mounted) return;
      final updatedContent = _preVoiceContent.isEmpty
          ? hypothesis
          : '$_preVoiceContent $hypothesis';
      setContent(updatedContent);
    });

    _voiceErrorSubscription = _voicePort.onError.listen((err) async {
      if (!mounted) return;
      await _cancelVoiceSubscriptions();
      try {
        await _voicePort.stopListening();
      } catch (_) {}
      if (mounted) {
        state = state.copyWith(errorMessage: err, isListening: false);
      }
    });

    try {
      await _voicePort.startListening();
    } catch (e) {
      await _cancelVoiceSubscriptions();
      if (mounted) {
        state = state.copyWith(isListening: false, errorMessage: 'Mic error: $e');
      }
    }
  }

  /// Stops voice dictation and integrates final recognized text.
  Future<void> stopVoiceDictation() async {
    if (!state.isListening) return;

    try {
      await _voicePort.stopListening();
      final finalText = await _voicePort.transcribeFinal();
      if (mounted && finalText.isNotEmpty) {
        final updatedContent = _preVoiceContent.isEmpty
            ? finalText
            : '$_preVoiceContent $finalText';
        setContent(updatedContent);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(errorMessage: 'Failed to stop dictation: $e');
      }
    } finally {
      await _cancelVoiceSubscriptions();
      if (mounted) {
        state = state.copyWith(isListening: false);
      }
    }
  }

  /// Persists current entry via [JournalRepository] with double encryption.
  Future<bool> saveEntry() async {
    if (!mounted) return false;
    state = state.copyWith(isSaving: true, clearError: true);

    final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final createdAt = state.initialCreatedAtUnix ?? nowUnix;

    final entry = JournalEntry(
      id: state.id,
      title: state.title,
      contentPlaintext: state.content,
      contentType: state.contentType,
      ttlDeleteAtUnix: state.ttlOption.calculateExpiryUnix(createdAt),
      isAutoDeleteEnabled: state.isAutoDeleteEnabled,
      wordCount: state.wordCount,
      createdAtUnix: createdAt,
      updatedAtUnix: nowUnix,
    );

    final result = await _repository.saveEntry(entry);
    if (!mounted) return result.isOk;

    if (result.isOk) {
      state = state.copyWith(
        isSaving: false,
        initialCreatedAtUnix: createdAt,
      );
      return true;
    } else {
      state = state.copyWith(
        isSaving: false,
        errorMessage: result.unwrapErr().toString(),
      );
      return false;
    }
  }

  /// Unsent letter instant purge: permanently deletes the entry from disk and wipes memory.
  Future<bool> burnEntry([String? targetId]) async {
    final idToBurn = targetId ?? state.id;
    if (!mounted) return false;

    // Halt active recording immediately
    if (state.isListening) {
      await stopVoiceDictation();
    }

    state = state.copyWith(isSaving: true, clearError: true);
    final result = await _repository.deleteEntry(idToBurn, secureErase: true);

    if (!mounted) return result.isOk;

    if (result.isOk) {
      state = state.copyWith(
        content: '',
        title: '',
        wordCount: 0,
        isBurned: true,
        isSaving: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to burn letter: ${result.unwrapErr()}',
      );
      return false;
    }
  }

  /// Loads an existing entry into the editor.
  Future<void> loadEntry(String entryId) async {
    final result = await _repository.getEntryById(entryId, decrypt: true);
    if (!mounted) return;

    if (result.isOk) {
      final entry = result.unwrap();
      if (entry != null) {
        final option = _matchTtlOption(entry.ttlDeleteAtUnix, entry.createdAtUnix);
        state = state.copyWith(
          id: entry.id,
          title: entry.title,
          content: entry.contentPlaintext ?? '',
          wordCount: entry.wordCount,
          ttlOption: option,
          isAutoDeleteEnabled: entry.isAutoDeleteEnabled,
          contentType: entry.contentType,
          initialCreatedAtUnix: entry.createdAtUnix,
          clearError: true,
        );
      } else {
        state = state.copyWith(errorMessage: 'Entry not found');
      }
    } else {
      state = state.copyWith(errorMessage: 'Failed to load entry: ${result.unwrapErr()}');
    }
  }

  Future<void> _cancelVoiceSubscriptions() async {
    await _voiceSubscription?.cancel();
    _voiceSubscription = null;
    await _voiceErrorSubscription?.cancel();
    _voiceErrorSubscription = null;
  }

  static int _countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  static String _generateUniqueId() {
    final random = Random();
    return 'journal-${DateTime.now().millisecondsSinceEpoch}-${random.nextInt(100000)}';
  }

  static JournalTtlOption _matchTtlOption(int? ttlDeleteAtUnix, int createdAtUnix) {
    if (ttlDeleteAtUnix == null) return JournalTtlOption.none;
    final diff = ttlDeleteAtUnix - createdAtUnix;
    if (diff <= 3600) return JournalTtlOption.oneHour;
    if (diff <= 86400) return JournalTtlOption.twentyFourHours;
    return JournalTtlOption.sevenDays;
  }

  @override
  void dispose() {
    if (state.isListening) {
      try {
        _voicePort.stopListening();
      } catch (_) {}
    }
    _voiceSubscription?.cancel();
    _voiceErrorSubscription?.cancel();
    super.dispose();
  }
}

/// Riverpod family provider for [JournalEditorController].
final journalEditorControllerProvider = StateNotifierProvider.autoDispose
    .family<JournalEditorController, JournalEditorState, String?>((ref, entryId) {
  final repository = ref.watch(journalRepositoryProvider);
  final voicePort = ref.watch(voiceRecognitionPortProvider);
  return JournalEditorController(
    repository: repository,
    voicePort: voicePort,
    entryId: entryId,
  );
});
