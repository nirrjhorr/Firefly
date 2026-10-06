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

  Duration? get duration {
    final s = durationSeconds;
    return s != null ? Duration(seconds: s) : null;
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
