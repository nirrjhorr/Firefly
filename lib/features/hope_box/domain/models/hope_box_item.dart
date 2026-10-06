/// Supported media and content item types in the Hope Box vault.
enum HopeBoxItemType {
  /// Reason to keep going: prompted "Something worth staying for:"
  reason,

  /// Personal written comforting note or quote
  text,

  /// Private photo memory
  photo,

  /// Comforting offline voice recording
  voice,

  /// Calming offline audio song or sound
  audio,
}

extension HopeBoxItemTypeExtension on HopeBoxItemType {
  String get label {
    switch (this) {
      case HopeBoxItemType.reason:
        return 'Reason to Stay';
      case HopeBoxItemType.text:
        return 'Words & Notes';
      case HopeBoxItemType.photo:
        return 'Photo';
      case HopeBoxItemType.voice:
        return 'Voice Note';
      case HopeBoxItemType.audio:
        return 'Audio & Music';
    }
  }

  String get iconKey {
    switch (this) {
      case HopeBoxItemType.reason:
        return 'heart.fill';
      case HopeBoxItemType.text:
        return 'quote.bubble';
      case HopeBoxItemType.photo:
        return 'photo';
      case HopeBoxItemType.voice:
        return 'mic';
      case HopeBoxItemType.audio:
        return 'music.note';
    }
  }
}

/// An immutable item representing a coping resource stored in the Hope Box vault.
class HopeBoxItem {
  final String id;
  final HopeBoxItemType type;
  final String title;
  final String contentEncrypted;
  final String? contentPlaintext;
  final String? filePath;
  final String? caption;
  final String category;
  final int createdAtUnix;
  final bool isPinned;

  const HopeBoxItem({
    required this.id,
    required this.type,
    required this.title,
    required this.contentEncrypted,
    this.contentPlaintext,
    this.filePath,
    this.caption,
    this.category = 'General',
    required this.createdAtUnix,
    this.isPinned = false,
  });

  /// Creates a copy with optionally modified attributes.
  HopeBoxItem copyWith({
    String? id,
    HopeBoxItemType? type,
    String? title,
    String? contentEncrypted,
    String? contentPlaintext,
    bool clearPlaintext = false,
    String? filePath,
    String? caption,
    String? category,
    int? createdAtUnix,
    bool? isPinned,
  }) {
    return HopeBoxItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      contentEncrypted: contentEncrypted ?? this.contentEncrypted,
      contentPlaintext: clearPlaintext ? null : (contentPlaintext ?? this.contentPlaintext),
      filePath: filePath ?? this.filePath,
      caption: caption ?? this.caption,
      category: category ?? this.category,
      createdAtUnix: createdAtUnix ?? this.createdAtUnix,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'contentEncrypted': contentEncrypted,
      'filePath': filePath,
      'caption': caption,
      'category': category,
      'createdAtUnix': createdAtUnix,
      'isPinned': isPinned ? 1 : 0,
    };
  }

  factory HopeBoxItem.fromMap(Map<String, dynamic> map) {
    return HopeBoxItem(
      id: map['id'] as String,
      type: HopeBoxItemType.values.byName(map['type'] as String),
      title: map['title'] as String,
      contentEncrypted: map['contentEncrypted'] as String,
      filePath: map['filePath'] as String?,
      caption: map['caption'] as String?,
      category: (map['category'] as String?) ?? 'General',
      createdAtUnix: map['createdAtUnix'] as int,
      isPinned: (map['isPinned'] as int? ?? 0) == 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HopeBoxItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          title == other.title &&
          contentEncrypted == other.contentEncrypted &&
          filePath == other.filePath &&
          caption == other.caption &&
          category == other.category &&
          createdAtUnix == other.createdAtUnix &&
          isPinned == other.isPinned;

  @override
  int get hashCode => Object.hash(
        id,
        type,
        title,
        contentEncrypted,
        filePath,
        caption,
        category,
        createdAtUnix,
        isPinned,
      );
}
