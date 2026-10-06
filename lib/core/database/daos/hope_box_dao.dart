import 'dart:async';

import '../../../features/hope_box/domain/models/hope_box_item.dart';

/// Data Access Object contract for Hope Box vault storage.
///
/// Decoupled from concrete Drift SQLite / in-memory drivers
/// to allow pure-Dart standalone testing and seamless persistence.
abstract class HopeBoxDao {
  Future<void> insertItem(HopeBoxItem item);
  Future<void> updateItem(HopeBoxItem item);
  Future<HopeBoxItem?> getItemById(String id);
  Future<List<HopeBoxItem>> getAllItems();
  Stream<List<HopeBoxItem>> watchAllItems();
  Future<void> deleteItem(String id);
  Future<void> togglePin(String id);
  Future<void> clearAll();

  factory HopeBoxDao.inMemory([List<HopeBoxItem>? initialItems]) =>
      InMemoryHopeBoxDao(initialItems);
}

/// In-memory implementation of [HopeBoxDao] for isolated unit testing,
/// previews, and headless verification without native database dependencies.
class InMemoryHopeBoxDao implements HopeBoxDao {
  InMemoryHopeBoxDao([List<HopeBoxItem>? initialItems])
      : _items = List.from(initialItems ?? []) {
    _streamController = StreamController<List<HopeBoxItem>>.broadcast();
  }

  final List<HopeBoxItem> _items;
  late final StreamController<List<HopeBoxItem>> _streamController;

  void _notify() {
    _items.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.createdAtUnix.compareTo(a.createdAtUnix);
    });
    _streamController.add(List.unmodifiable(_items));
  }

  @override
  Future<void> insertItem(HopeBoxItem item) async {
    _items.removeWhere((e) => e.id == item.id);
    _items.add(item);
    _notify();
  }

  @override
  Future<void> updateItem(HopeBoxItem item) async {
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _items[index] = item;
      _notify();
    }
  }

  @override
  Future<HopeBoxItem?> getItemById(String id) async {
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<HopeBoxItem>> getAllItems() async {
    final copy = List<HopeBoxItem>.from(_items);
    copy.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.createdAtUnix.compareTo(a.createdAtUnix);
    });
    return copy;
  }

  @override
  Stream<List<HopeBoxItem>> watchAllItems() {
    return _streamController.stream;
  }

  @override
  Future<void> deleteItem(String id) async {
    _items.removeWhere((e) => e.id == id);
    _notify();
  }

  @override
  Future<void> togglePin(String id) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index != -1) {
      final existing = _items[index];
      _items[index] = existing.copyWith(isPinned: !existing.isPinned);
      _notify();
    }
  }

  @override
  Future<void> clearAll() async {
    _items.clear();
    _notify();
  }

  void dispose() {
    _streamController.close();
  }
}
