/// Represents a pre-bed worry entry with cryptographic isolation and morning lockup.
class WorryDumpEntry {
  final String id;
  final String? contentPlaintext;
  final String contentEncrypted;
  final bool isParked;
  final bool isDissolved;
  final int lockedUntilUnix;
  final int ttlDeleteAtUnix;
  final int createdAtUnix;

  const WorryDumpEntry({
    required this.id,
    this.contentPlaintext,
    this.contentEncrypted = '',
    this.isParked = true,
    this.isDissolved = false,
    required this.lockedUntilUnix,
    required this.ttlDeleteAtUnix,
    required this.createdAtUnix,
  });

  /// Factory calculating next morning 8:00 AM lockup time and default 24h TTL.
  factory WorryDumpEntry.createParked({
    required String id,
    required String contentPlaintext,
    String contentEncrypted = '',
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final currentUnix = current.millisecondsSinceEpoch ~/ 1000;

    // Calculate next 8:00 AM:
    // If current time is before 8:00 AM today, lock until 8:00 AM today.
    // If current time is >= 8:00 AM, lock until 8:00 AM tomorrow.
    final DateTime morningUnlock;
    if (current.hour < 8) {
      morningUnlock = DateTime(current.year, current.month, current.day, 8, 0, 0);
    } else {
      final tomorrow = current.add(const Duration(days: 1));
      morningUnlock = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8, 0, 0);
    }

    final lockedUntilUnix = morningUnlock.millisecondsSinceEpoch ~/ 1000;
    // Default 24h TTL
    final ttlDeleteAtUnix = currentUnix + (24 * 60 * 60);

    return WorryDumpEntry(
      id: id,
      contentPlaintext: contentPlaintext,
      contentEncrypted: contentEncrypted,
      isParked: true,
      isDissolved: false,
      lockedUntilUnix: lockedUntilUnix,
      ttlDeleteAtUnix: ttlDeleteAtUnix,
      createdAtUnix: currentUnix,
    );
  }

  /// Whether the entry is currently locked and inaccessible to prevent rumination.
  bool get isLockedNow {
    if (!isParked) return false;
    final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return nowUnix < lockedUntilUnix;
  }

  /// Whether the entry has exceeded its 24-hour TTL and should be purged.
  bool get isExpired {
    final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return nowUnix >= ttlDeleteAtUnix;
  }

  /// Formatted remaining lock time description.
  String get lockStatusDescription {
    if (!isLockedNow) {
      return 'Unlocked for daytime review';
    }
    final unlockDate = DateTime.fromMillisecondsSinceEpoch(lockedUntilUnix * 1000);
    final hourStr = unlockDate.hour.toString().padLeft(2, '0');
    final minStr = unlockDate.minute.toString().padLeft(2, '0');
    return 'Parked safely until $hourStr:$minStr';
  }

  WorryDumpEntry copyWith({
    String? id,
    String? contentPlaintext,
    bool clearPlaintext = false,
    String? contentEncrypted,
    bool? isParked,
    bool? isDissolved,
    int? lockedUntilUnix,
    int? ttlDeleteAtUnix,
    int? createdAtUnix,
  }) {
    return WorryDumpEntry(
      id: id ?? this.id,
      contentPlaintext: clearPlaintext ? null : (contentPlaintext ?? this.contentPlaintext),
      contentEncrypted: contentEncrypted ?? this.contentEncrypted,
      isParked: isParked ?? this.isParked,
      isDissolved: isDissolved ?? this.isDissolved,
      lockedUntilUnix: lockedUntilUnix ?? this.lockedUntilUnix,
      ttlDeleteAtUnix: ttlDeleteAtUnix ?? this.ttlDeleteAtUnix,
      createdAtUnix: createdAtUnix ?? this.createdAtUnix,
    );
  }
}
