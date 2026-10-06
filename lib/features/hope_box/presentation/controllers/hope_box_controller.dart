import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/daos/hope_box_dao.dart';
import '../../data/repositories/hope_box_repository_impl.dart';
import '../../domain/models/hope_box_item.dart';
import '../../domain/models/hope_box_state.dart';
import '../../domain/repositories/hope_box_repository.dart';

/// Provider for [HopeBoxDao] allowing database or test overrides.
final hopeBoxDaoProvider = Provider<HopeBoxDao>((ref) {
  return HopeBoxDao.inMemory();
});

/// Provider exposing the [HopeBoxRepository] instance.
final hopeBoxRepositoryProvider = Provider<HopeBoxRepository>((ref) {
  final dao = ref.watch(hopeBoxDaoProvider);
  return HopeBoxRepositoryImpl(dao: dao);
});

/// StateNotifierProvider managing the [HopeBoxController].
final hopeBoxControllerProvider =
    StateNotifierProvider<HopeBoxController, HopeBoxState>((ref) {
  final repository = ref.watch(hopeBoxRepositoryProvider);
  return HopeBoxController(repository);
});

/// StateNotifier controller managing the Hope Box vault state, category filtering,
/// cryptographic storage, and secure item disposal.
class HopeBoxController extends StateNotifier<HopeBoxState> {
  final HopeBoxRepository _repository;

  HopeBoxController(this._repository) : super(const HopeBoxState()) {
    loadItems();
  }

  /// Refreshes all items from the repository.
  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _repository.getItems();
      state = state.copyWith(
        items: items,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load your Hope Box right now.',
      );
    }
  }

  /// Sets the active category filter chip.
  void setFilter(HopeBoxFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Selects an item for detailed viewing.
  void selectItem(HopeBoxItem? item) {
    if (item == null) {
      state = state.copyWith(clearSelectedItem: true);
    } else {
      state = state.copyWith(selectedItem: item);
    }
  }

  /// Adds a "Reason to keep going" item.
  Future<void> addReason(String reasonText, {String category = 'General'}) async {
    if (reasonText.trim().isEmpty) return;

    final item = HopeBoxItem(
      id: 'reason_${DateTime.now().millisecondsSinceEpoch}',
      type: HopeBoxItemType.reason,
      title: 'Reason to Stay',
      contentEncrypted: '',
      contentPlaintext: reasonText.trim(),
      category: category,
      createdAtUnix: DateTime.now().millisecondsSinceEpoch,
    );

    await _repository.saveItem(item);
    await loadItems();
  }

  /// Adds a personal comforting text note or quote.
  Future<void> addTextNote(
    String title,
    String content, {
    String category = 'General',
  }) async {
    if (content.trim().isEmpty) return;

    final resolvedTitle = title.trim().isEmpty ? 'Note' : title.trim();
    final item = HopeBoxItem(
      id: 'note_${DateTime.now().millisecondsSinceEpoch}',
      type: HopeBoxItemType.text,
      title: resolvedTitle,
      contentEncrypted: '',
      contentPlaintext: content.trim(),
      category: category,
      createdAtUnix: DateTime.now().millisecondsSinceEpoch,
    );

    await _repository.saveItem(item);
    await loadItems();
  }

  /// Adds a photo memory reference.
  Future<void> addPhoto({
    required String title,
    required String filePath,
    String? caption,
    String category = 'General',
  }) async {
    final resolvedTitle = title.trim().isEmpty ? 'Photo Memory' : title.trim();
    final item = HopeBoxItem(
      id: 'photo_${DateTime.now().millisecondsSinceEpoch}',
      type: HopeBoxItemType.photo,
      title: resolvedTitle,
      contentEncrypted: '',
      contentPlaintext: caption ?? '',
      filePath: filePath,
      caption: caption,
      category: category,
      createdAtUnix: DateTime.now().millisecondsSinceEpoch,
    );

    await _repository.saveItem(item);
    await loadItems();
  }

  /// Adds a comforting offline voice note.
  Future<void> addVoiceNote({
    required String title,
    required String filePath,
    String category = 'General',
  }) async {
    final resolvedTitle = title.trim().isEmpty ? 'Voice Message' : title.trim();
    final item = HopeBoxItem(
      id: 'voice_${DateTime.now().millisecondsSinceEpoch}',
      type: HopeBoxItemType.voice,
      title: resolvedTitle,
      contentEncrypted: '',
      contentPlaintext: 'Voice Note: $resolvedTitle',
      filePath: filePath,
      category: category,
      createdAtUnix: DateTime.now().millisecondsSinceEpoch,
    );

    await _repository.saveItem(item);
    await loadItems();
  }

  /// Adds an offline comforting audio song or sound reference.
  Future<void> addAudio({
    required String title,
    required String filePath,
    String category = 'General',
  }) async {
    final resolvedTitle = title.trim().isEmpty ? 'Calming Audio' : title.trim();
    final item = HopeBoxItem(
      id: 'audio_${DateTime.now().millisecondsSinceEpoch}',
      type: HopeBoxItemType.audio,
      title: resolvedTitle,
      contentEncrypted: '',
      contentPlaintext: 'Audio: $resolvedTitle',
      filePath: filePath,
      category: category,
      createdAtUnix: DateTime.now().millisecondsSinceEpoch,
    );

    await _repository.saveItem(item);
    await loadItems();
  }

  /// Permanently removes an item with physical unlinking and memory zeroing.
  Future<void> deleteItem(String id) async {
    if (state.selectedItem?.id == id) {
      state = state.copyWith(clearSelectedItem: true);
    }
    await _repository.deleteItem(id);
    await loadItems();
  }

  /// Toggles the pinned status of an item.
  Future<void> togglePin(String id) async {
    await _repository.togglePin(id);
    await loadItems();
  }

  /// Decrypts the content payload of an item for detail presentation.
  Future<String> decryptContent(HopeBoxItem item) async {
    return await _repository.decryptItemContent(item);
  }

  /// Wipes all vault items securely.
  Future<void> clearVault() async {
    state = state.copyWith(clearSelectedItem: true);
    await _repository.clearVault();
    await loadItems();
  }
}
