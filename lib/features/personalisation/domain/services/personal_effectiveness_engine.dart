import '../../../activities/domain/models/activity_effectiveness_log.dart';
import '../models/activity_affinity.dart';
import '../models/personal_regulation_profile.dart';

/// Pure mathematical engine for computing on-device activity effectiveness
/// and Bayesian affinity scores. Zero external dependencies, runs in < 2ms.
abstract final class PersonalEffectivenessEngine {
  /// Smoothing factor for sample count damping.
  /// Prevents a single isolated rating from skewing personal affinity.
  static const double dampingFactor = 1.0;

  /// Maximum scale rating bound in EMA (-2 to +2).
  static const double maxRatingBound = 2.0;

  /// Computes affinity scores grouped by activity and starting state.
  static List<ActivityAffinity> calculateAffinities(List<ActivityEffectivenessLog> logs) {
    if (logs.isEmpty) return const [];

    final Map<String, List<ActivityEffectivenessLog>> grouped = {};

    for (final log in logs) {
      final normalizedState = log.stateAtStart.toLowerCase().trim();
      final key = '${log.activityId}::$normalizedState';
      grouped.putIfAbsent(key, () => []).add(log);
    }

    final List<ActivityAffinity> affinities = [];

    for (final entry in grouped.entries) {
      final parts = entry.key.split('::');
      final activityId = parts[0];
      final targetState = parts[1];
      final groupLogs = entry.value;

      final sampleCount = groupLogs.length;
      final sumRatings = groupLogs.fold<int>(0, (acc, l) => acc + l.rating);
      final avgRating = sumRatings / sampleCount;

      // Sample-damped affinity score bounded in [-1.0, 1.0]
      final normalizedAvg = (avgRating / maxRatingBound).clamp(-1.0, 1.0);
      final dampingWeight = sampleCount / (sampleCount + dampingFactor);
      final affinityScore = (normalizedAvg * dampingWeight).clamp(-1.0, 1.0);

      // Recency & counts
      DateTime? latest;
      int positive = 0;
      int negative = 0;
      int neutral = 0;

      for (final l in groupLogs) {
        if (latest == null || l.timestamp.isAfter(latest)) {
          latest = l.timestamp;
        }
        if (l.rating > 0) {
          positive++;
        } else if (l.rating < 0) {
          negative++;
        } else {
          neutral++;
        }
      }

      affinities.add(
        ActivityAffinity(
          activityId: activityId,
          targetState: targetState,
          sampleCount: sampleCount,
          averageRating: avgRating,
          affinityScore: affinityScore,
          lastPracticed: latest,
          positiveCount: positive,
          negativeCount: negative,
          neutralCount: neutral,
        ),
      );
    }

    affinities.sort((a, b) => b.affinityScore.compareTo(a.affinityScore));
    return affinities;
  }

  /// Builds a complete [PersonalRegulationProfile] from historical logs.
  static PersonalRegulationProfile buildProfile(List<ActivityEffectivenessLog> logs) {
    if (logs.isEmpty) {
      return PersonalRegulationProfile.empty();
    }

    final affinities = calculateAffinities(logs);

    // Group by target state
    final Map<String, List<ActivityAffinity>> topByState = {};
    for (final aff in affinities) {
      if (aff.affinityScore > 0) {
        topByState.putIfAbsent(aff.targetState, () => []).add(aff);
      }
    }

    // Sort each state's practices
    for (final stateList in topByState.values) {
      stateList.sort((a, b) => b.affinityScore.compareTo(a.affinityScore));
    }

    // Overall practices across all states (aggregate by activityId)
    final Map<String, List<ActivityEffectivenessLog>> byActivity = {};
    for (final l in logs) {
      byActivity.putIfAbsent(l.activityId, () => []).add(l);
    }

    final List<ActivityAffinity> overall = [];
    for (final entry in byActivity.entries) {
      final actId = entry.key;
      final actLogs = entry.value;
      final count = actLogs.length;
      final sum = actLogs.fold<int>(0, (acc, l) => acc + l.rating);
      final avg = sum / count;
      final normAvg = (avg / maxRatingBound).clamp(-1.0, 1.0);
      final damp = count / (count + dampingFactor);
      final score = (normAvg * damp).clamp(-1.0, 1.0);

      overall.add(
        ActivityAffinity(
          activityId: actId,
          targetState: 'all',
          sampleCount: count,
          averageRating: avg,
          affinityScore: score,
          lastPracticed: actLogs.map((e) => e.timestamp).reduce((a, b) => a.isAfter(b) ? a : b),
          positiveCount: actLogs.where((l) => l.rating > 0).length,
          negativeCount: actLogs.where((l) => l.rating < 0).length,
          neutralCount: actLogs.where((l) => l.rating == 0).length,
        ),
      );
    }

    overall.sort((a, b) => b.affinityScore.compareTo(a.affinityScore));

    final totalMoments = logs.length;
    final calmingCount = logs.where((l) => l.rating > 0).length;
    final calmingRate = totalMoments > 0 ? (calmingCount / totalMoments) : 0.0;

    return PersonalRegulationProfile(
      affinities: affinities,
      topPracticesByState: topByState,
      overallTopPractices: overall,
      totalMomentsOfCare: totalMoments,
      calmingSessionCount: calmingCount,
      calmingRate: calmingRate,
      lastUpdated: DateTime.now(),
    );
  }

  /// Formats a serene, non-clinical explanation for why this activity is recommended.
  static String? generatePersonalizedReason(ActivityAffinity affinity) {
    if (affinity.affinityScore <= 0.15) return null;

    final state = affinity.targetState;
    if (affinity.averageRating >= 1.5) {
      return 'Consistently settled your body when feeling $state';
    } else if (affinity.averageRating >= 0.5) {
      return 'Previously helped you feel more settled when $state';
    } else {
      return 'Brought gentle relief when feeling $state';
    }
  }
}
