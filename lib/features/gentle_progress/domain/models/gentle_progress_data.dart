import '../../../loneliness_comfort/domain/models/social_prediction_experiment.dart';

/// Read model capturing gentle presence, quiet milestones,
/// and cognitive reframing evidence without streaks, scores, or gamification.
class GentleProgressData {
  const GentleProgressData({
    this.weekPresence = const [false, false, false, false, false, false, false],
    this.activeDaysCount = 0,
    this.groundingSessionsCount = 0,
    this.journalEntriesCount = 0,
    this.tinyStepsCount = 0,
    this.socialSummary,
  });

  /// 7-day presence indicators for Monday through Sunday of the current week.
  final List<bool> weekPresence;

  /// Number of days user had at least one session/check-in this week.
  final int activeDaysCount;

  /// Total count of completed respiration, grounding, and PMR sessions.
  final int groundingSessionsCount;

  /// Total count of encrypted reflections/journal entries written.
  final int journalEntriesCount;

  /// Total count of micro-actions / tiny steps completed.
  final int tinyStepsCount;

  /// Aggregate summary from "Guess vs. Reality" experiments if ≥ 3 logged.
  final SocialExperimentSummary? socialSummary;

  GentleProgressData copyWith({
    List<bool>? weekPresence,
    int? activeDaysCount,
    int? groundingSessionsCount,
    int? journalEntriesCount,
    int? tinyStepsCount,
    SocialExperimentSummary? socialSummary,
  }) {
    return GentleProgressData(
      weekPresence: weekPresence ?? this.weekPresence,
      activeDaysCount: activeDaysCount ?? this.activeDaysCount,
      groundingSessionsCount: groundingSessionsCount ?? this.groundingSessionsCount,
      journalEntriesCount: journalEntriesCount ?? this.journalEntriesCount,
      tinyStepsCount: tinyStepsCount ?? this.tinyStepsCount,
      socialSummary: socialSummary ?? this.socialSummary,
    );
  }
}
