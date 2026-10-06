import 'hope_box_item.dart';

/// Vault category/type filtering options.
enum HopeBoxFilter {
  all,
  reasons,
  photos,
  words,
  voice,
  audio,
}

extension HopeBoxFilterExtension on HopeBoxFilter {
  String get label {
    switch (this) {
      case HopeBoxFilter.all:
        return 'All Items';
      case HopeBoxFilter.reasons:
        return 'Reasons to Stay';
      case HopeBoxFilter.photos:
        return 'Photos';
      case HopeBoxFilter.words:
        return 'Words & Notes';
      case HopeBoxFilter.voice:
        return 'Voice Notes';
      case HopeBoxFilter.audio:
        return 'Music & Sounds';
    }
  }

  bool matches(HopeBoxItem item) {
    switch (this) {
      case HopeBoxFilter.all:
        return true;
      case HopeBoxFilter.reasons:
        return item.type == HopeBoxItemType.reason;
      case HopeBoxFilter.photos:
        return item.type == HopeBoxItemType.photo;
      case HopeBoxFilter.words:
        return item.type == HopeBoxItemType.text;
      case HopeBoxFilter.voice:
        return item.type == HopeBoxItemType.voice;
      case HopeBoxFilter.audio:
        return item.type == HopeBoxItemType.audio;
    }
  }
}

/// Immutable state model representing the Hope Box vault.
class HopeBoxState {
  final List<HopeBoxItem> items;
  final HopeBoxFilter filter;
  final bool isLoading;
  final String? errorMessage;
  final HopeBoxItem? selectedItem;
  final String? playingItemId;
  final bool isPlaying;

  const HopeBoxState({
    this.items = const [],
    this.filter = HopeBoxFilter.all,
    this.isLoading = false,
    this.errorMessage,
    this.selectedItem,
    this.playingItemId,
    this.isPlaying = false,
  });

  /// Filtered items based on current category selection, with pinned items first.
  List<HopeBoxItem> get filteredItems {
    final filtered = items.where((item) => filter.matches(item)).toList();
    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAtUnix.compareTo(a.createdAtUnix);
    });
    return List.unmodifiable(filtered);
  }

  /// Whether the vault is completely empty of items.
  bool get isEmpty => items.isEmpty;

  /// Count of reasons to stay saved in vault.
  int get reasonCount =>
      items.where((e) => e.type == HopeBoxItemType.reason).length;

  /// Creates a copy of the state with modified attributes.
  HopeBoxState copyWith({
    List<HopeBoxItem>? items,
    HopeBoxFilter? filter,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    HopeBoxItem? selectedItem,
    bool clearSelectedItem = false,
    String? playingItemId,
    bool clearPlayingItem = false,
    bool? isPlaying,
  }) {
    return HopeBoxState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedItem:
          clearSelectedItem ? null : (selectedItem ?? this.selectedItem),
      playingItemId:
          clearPlayingItem ? null : (playingItemId ?? this.playingItemId),
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HopeBoxState) return false;
    if (items.length != other.items.length) return false;
    for (int i = 0; i < items.length; i++) {
      if (items[i] != other.items[i]) return false;
    }
    return filter == other.filter &&
        isLoading == other.isLoading &&
        errorMessage == other.errorMessage &&
        selectedItem == other.selectedItem &&
        playingItemId == other.playingItemId &&
        isPlaying == other.isPlaying;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(items),
        filter,
        isLoading,
        errorMessage,
        selectedItem,
        playingItemId,
        isPlaying,
      );
}
