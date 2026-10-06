import 'dart:math' as math;
import 'sleep_sound_track.dart';
import 'worry_dump_entry.dart';

/// Navigation tabs within the Sleep Suite sanctuary.
enum SleepSuiteTab {
  worryDump('Worry Dump', 'moon.stars'),
  soundscape('Fading Ambient', 'waveform'),
  wakeAnchor('Wake Companion', 'alarm');

  final String label;
  final String iconKey;
  const SleepSuiteTab(this.label, this.iconKey);
}

/// Immutable state representation for the Pre-Bed Sleep Suite.
class SleepSessionState {
  final SleepSuiteTab activeTab;
  final String worryText;
  final bool isDissolving;
  final double dissolveProgress;
  final List<WorryDumpEntry> parkedEntries;
  final SleepSoundTrack selectedTrack;
  final bool isPlaying;
  final double baseVolume;
  final double currentVolume;
  final int? timerMinutes;
  final int? timerSecondsRemaining;
  final int wakeTargetHour;
  final int wakeTargetMinute;
  final bool isWakeTargetSet;
  final String? statusMessage;

  const SleepSessionState({
    this.activeTab = SleepSuiteTab.worryDump,
    this.worryText = '',
    this.isDissolving = false,
    this.dissolveProgress = 0.0,
    this.parkedEntries = const [],
    this.selectedTrack = kDefaultSleepTrack,
    this.isPlaying = false,
    this.baseVolume = 0.70,
    this.currentVolume = 0.70,
    this.timerMinutes,
    this.timerSecondsRemaining,
    this.wakeTargetHour = 7,
    this.wakeTargetMinute = 0,
    this.isWakeTargetSet = false,
    this.statusMessage,
  });

  /// Calculates the logarithmic volume attenuation factor when in final 5 minutes.
  /// Over the last 300 seconds, the volume smoothly curves logarithmically to 0.0.
  static double computeLogarithmicFadeFactor(int secondsRemaining, int totalDurationSeconds) {
    if (secondsRemaining <= 0) return 0.0;
    
    // Fade duration: 5 minutes (300s) or the full duration if duration < 300s
    final fadeDuration = totalDurationSeconds < 300 ? totalDurationSeconds : 300;
    if (secondsRemaining >= fadeDuration) return 1.0;

    // Logarithmic curve: factor = ln(1 + 9 * (t / T)) / ln(10)
    // At t = fadeDuration: ln(10) / ln(10) = 1.0
    // At t = 0: ln(1) / ln(10) = 0.0
    final ratio = (secondsRemaining / fadeDuration).clamp(0.0, 1.0);
    return math.log(1.0 + 9.0 * ratio) / math.ln10;
  }

  /// Human-readable remaining timer text (e.g. "24:18").
  String? get formattedTimeRemaining {
    if (timerSecondsRemaining == null) return null;
    final mins = timerSecondsRemaining! ~/ 60;
    final secs = timerSecondsRemaining! % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Formatted wake anchor time (e.g. "07:00 AM").
  String get formattedWakeTarget {
    final period = wakeTargetHour >= 12 ? 'PM' : 'AM';
    final displayHour = wakeTargetHour == 0
        ? 12
        : (wakeTargetHour > 12 ? wakeTargetHour - 12 : wakeTargetHour);
    final minStr = wakeTargetMinute.toString().padLeft(2, '0');
    return '$displayHour:$minStr $period';
  }

  SleepSessionState copyWith({
    SleepSuiteTab? activeTab,
    String? worryText,
    bool? isDissolving,
    double? dissolveProgress,
    List<WorryDumpEntry>? parkedEntries,
    SleepSoundTrack? selectedTrack,
    bool? isPlaying,
    double? baseVolume,
    double? currentVolume,
    int? timerMinutes,
    bool clearTimer = false,
    int? timerSecondsRemaining,
    int? wakeTargetHour,
    int? wakeTargetMinute,
    bool? isWakeTargetSet,
    String? statusMessage,
    bool clearStatusMessage = false,
  }) {
    return SleepSessionState(
      activeTab: activeTab ?? this.activeTab,
      worryText: worryText ?? this.worryText,
      isDissolving: isDissolving ?? this.isDissolving,
      dissolveProgress: dissolveProgress ?? this.dissolveProgress,
      parkedEntries: parkedEntries ?? this.parkedEntries,
      selectedTrack: selectedTrack ?? this.selectedTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      baseVolume: baseVolume ?? this.baseVolume,
      currentVolume: currentVolume ?? this.currentVolume,
      timerMinutes: clearTimer ? null : (timerMinutes ?? this.timerMinutes),
      timerSecondsRemaining: clearTimer ? null : (timerSecondsRemaining ?? this.timerSecondsRemaining),
      wakeTargetHour: wakeTargetHour ?? this.wakeTargetHour,
      wakeTargetMinute: wakeTargetMinute ?? this.wakeTargetMinute,
      isWakeTargetSet: isWakeTargetSet ?? this.isWakeTargetSet,
      statusMessage: clearStatusMessage ? null : (statusMessage ?? this.statusMessage),
    );
  }
}
