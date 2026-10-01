import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/journal_repository_impl.dart';
import '../../domain/models/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';

/// State for [JournalListController].
@immutable
class JournalListState {
  const JournalListState({
    this.entries = const [],
    this.isLoading = false,
    this.errorMessage,
    this.lastPurgedCount = 0,
  });

  final List<JournalEntry> entries;
  final bool isLoading;
  final String? errorMessage;
  final int lastPurgedCount;

  JournalListState copyWith({
    List<JournalEntry>? entries,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    int? lastPurgedCount,
  }) {
    return JournalListState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastPurgedCount: lastPurgedCount ?? this.lastPurgedCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalListState &&
          runtimeType == other.runtimeType &&
          listEquals(entries, other.entries) &&
          isLoading == other.isLoading &&
          errorMessage == other.errorMessage &&
          lastPurgedCount == other.lastPurgedCount;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(entries),
        isLoading,
        errorMessage,
        lastPurgedCount,
      );
}

/// Controller managing the journal entries list, stream subscriptions,
/// manual purge triggers, and single-item deletions.
class JournalListController extends StateNotifier<JournalListState> {
  JournalListController({
    required JournalRepository repository,
  })  : _repository = repository,
        super(const JournalListState(isLoading: true)) {
    _initSubscription();
  }

  final JournalRepository _repository;
  StreamSubscription<List<JournalEntry>>? _subscription;

  void _initSubscription() {
    _subscription?.cancel();
    state = state.copyWith(isLoading: true, clearError: true);

    _subscription = _repository.watchEntries().listen(
      (entries) {
        if (!mounted) return;
        state = state.copyWith(
          entries: entries,
          isLoading: false,
          clearError: true,
        );
      },
      onError: (e) {
        if (!mounted) return;
        state = state.copyWith(
          errorMessage: 'Failed to observe journal entries: $e',
          isLoading: false,
        );
      },
    );
  }

  /// Reconnects the journal entries watcher stream.
  void refresh() {
    _initSubscription();
  }

  /// Manually triggers TTL cleanup of expired entries.
  Future<int> purgeExpired() async {
    final result = await _repository.purgeExpiredEntries();
    if (!mounted) return result.unwrapOr(0);

    if (result.isOk) {
      final count = result.unwrap();
      state = state.copyWith(lastPurgedCount: count, clearError: true);
      return count;
    } else {
      state = state.copyWith(errorMessage: result.unwrapErr().toString());
      return 0;
    }
  }

  /// Deletes a single journal entry by [id] with cryptographic erasure.
  Future<bool> deleteEntry(String id) async {
    final result = await _repository.deleteEntry(id, secureErase: true);
    if (!mounted) return result.isOk;

    if (result.isOk) {
      state = state.copyWith(clearError: true);
      return true;
    } else {
      state = state.copyWith(errorMessage: result.unwrapErr().toString());
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Riverpod provider for [JournalListController].
final journalListControllerProvider =
    StateNotifierProvider.autoDispose<JournalListController, JournalListState>((ref) {
  final repository = ref.watch(journalRepositoryProvider);
  return JournalListController(repository: repository);
});
