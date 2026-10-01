import 'dart:math';
import 'package:flutter/foundation.dart';

/// Domain entity representing an encrypted journal entry or unsent letter.
@immutable
class JournalEntry {
  const JournalEntry({
    required this.id,
    this.checkInId,
    this.title = '',
    this.contentPlaintext,
    this.contentEncrypted = '',
    this.contentType = 'text',
    this.ttlDeleteAtUnix,
    this.isAutoDeleteEnabled = false,
    this.wordCount = 0,
    required this.createdAtUnix,
    required this.updatedAtUnix,
  });

  /// Unique identifier (UUID).
  final String id;

  /// Optional foreign key to a preceding mood check-in.
  final String? checkInId;

  /// Cleartext title (non-confidential summary, or empty).
  final String title;

  /// Transient plaintext content in memory.
  /// NEVER directly written to persistent storage in unencrypted form.
  final String? contentPlaintext;

  /// Application-layer AES-256-GCM double-encrypted payload (Base64).
  final String contentEncrypted;

  /// Type of entry: 'text' | 'voice'.
  final String contentType;

  /// Unix timestamp (seconds) when entry expires and must be purged.
  /// Null indicates the entry is kept permanently.
  final int? ttlDeleteAtUnix;

  /// Whether auto-delete TTL is active.
  final bool isAutoDeleteEnabled;

  /// Word count of the entry.
  final int wordCount;

  /// Creation timestamp in Unix seconds.
  final int createdAtUnix;

  /// Last modification timestamp in Unix seconds.
  final int updatedAtUnix;

  /// Whether this entry has reached its TTL expiration timestamp.
  bool get isExpired {
    if (!isAutoDeleteEnabled || ttlDeleteAtUnix == null) return false;
    final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return nowUnix >= ttlDeleteAtUnix!;
  }

  /// Remaining seconds until TTL expiry, or null if permanent.
  int? get remainingTtlSeconds {
    if (ttlDeleteAtUnix == null) return null;
    final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return max(0, ttlDeleteAtUnix! - nowUnix);
  }

  /// Whether the entry is an ephemeral unsent letter.
  bool get isUnsentLetter => isAutoDeleteEnabled && ttlDeleteAtUnix != null;

  /// Whether plaintext content has been decrypted into memory.
  bool get hasDecryptedContent => contentPlaintext != null;

  JournalEntry copyWith({
    String? id,
    String? checkInId,
    String? title,
    String? contentPlaintext,
    bool clearPlaintext = false,
    String? contentEncrypted,
    String? contentType,
    int? ttlDeleteAtUnix,
    bool clearTtl = false,
    bool? isAutoDeleteEnabled,
    int? wordCount,
    int? createdAtUnix,
    int? updatedAtUnix,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      checkInId: checkInId ?? this.checkInId,
      title: title ?? this.title,
      contentPlaintext: clearPlaintext ? null : (contentPlaintext ?? this.contentPlaintext),
      contentEncrypted: contentEncrypted ?? this.contentEncrypted,
      contentType: contentType ?? this.contentType,
      ttlDeleteAtUnix: clearTtl ? null : (ttlDeleteAtUnix ?? this.ttlDeleteAtUnix),
      isAutoDeleteEnabled: isAutoDeleteEnabled ?? this.isAutoDeleteEnabled,
      wordCount: wordCount ?? this.wordCount,
      createdAtUnix: createdAtUnix ?? this.createdAtUnix,
      updatedAtUnix: updatedAtUnix ?? this.updatedAtUnix,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (checkInId != null) 'check_in_id': checkInId,
      'title': title,
      'content_encrypted': contentEncrypted,
      'content_type': contentType,
      if (ttlDeleteAtUnix != null) 'ttl_delete_at_unix': ttlDeleteAtUnix,
      'is_auto_delete_enabled': isAutoDeleteEnabled,
      'word_count': wordCount,
      'created_at_unix': createdAtUnix,
      'updated_at_unix': updatedAtUnix,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      checkInId: json['check_in_id'] as String?,
      title: (json['title'] as String?) ?? '',
      contentEncrypted: (json['content_encrypted'] as String?) ?? '',
      contentType: (json['content_type'] as String?) ?? 'text',
      ttlDeleteAtUnix: json['ttl_delete_at_unix'] as int?,
      isAutoDeleteEnabled: (json['is_auto_delete_enabled'] is bool)
          ? json['is_auto_delete_enabled'] as bool
          : ((json['is_auto_delete_enabled'] as int?) == 1),
      wordCount: (json['word_count'] as int?) ?? 0,
      createdAtUnix: json['created_at_unix'] as int,
      updatedAtUnix: json['updated_at_unix'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          checkInId == other.checkInId &&
          title == other.title &&
          contentPlaintext == other.contentPlaintext &&
          contentEncrypted == other.contentEncrypted &&
          contentType == other.contentType &&
          ttlDeleteAtUnix == other.ttlDeleteAtUnix &&
          isAutoDeleteEnabled == other.isAutoDeleteEnabled &&
          wordCount == other.wordCount &&
          createdAtUnix == other.createdAtUnix &&
          updatedAtUnix == other.updatedAtUnix;

  @override
  int get hashCode => Object.hash(
        id,
        checkInId,
        title,
        contentPlaintext,
        contentEncrypted,
        contentType,
        ttlDeleteAtUnix,
        isAutoDeleteEnabled,
        wordCount,
        createdAtUnix,
        updatedAtUnix,
      );

  @override
  String toString() =>
      'JournalEntry(id: $id, title: $title, wordCount: $wordCount, ttl: $ttlDeleteAtUnix, autoDelete: $isAutoDeleteEnabled)';
}
