import '../models/hope_box_item.dart';

/// Repository interface for storing, encrypting, and disposing Hope Box coping items.
abstract class HopeBoxRepository {
  /// Retrieves all items currently stored in the vault.
  Future<List<HopeBoxItem>> getItems();

  /// Persists a new or updated item with application-layer encryption.
  Future<void> saveItem(HopeBoxItem item);

  /// Permanently removes an item by ID, securely unlinking its physical file
  /// and zeroing memory buffers.
  Future<void> deleteItem(String id);

  /// Decrypts the encrypted content payload of a given [item].
  Future<String> decryptItemContent(HopeBoxItem item);

  /// Toggles whether an item is pinned to the top of the vault.
  Future<void> togglePin(String id);

  /// Wipes all vault records and physically deletes associated media files.
  Future<void> clearVault();
}
