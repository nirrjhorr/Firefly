import '../../../../core/database/daos/activities_dao.dart';
import '../../../../core/database/daos/journal_dao.dart';
import '../../../../core/database/daos/loneliness_comfort_dao.dart';
import '../../domain/models/gentle_progress_data.dart';
import '../../domain/repositories/gentle_progress_repository.dart';

/// Concrete implementation of [GentleProgressRepository] synthesizing
/// live presence data across journal reflections, grounding sessions, and social experiments.
class GentleProgressRepositoryImpl implements GentleProgressRepository {
  final JournalDao? _journalDao;
  final LonelinessComfortDao? _lonelinessDao;
  final ActivitiesDao? _activitiesDao;
  final GentleProgressData? _mockOverride;

  GentleProgressRepositoryImpl({
    JournalDao? journalDao,
    LonelinessComfortDao? lonelinessDao,
    ActivitiesDao? activitiesDao,
    GentleProgressData? mockOverride,
  })  : _journalDao = journalDao,
        _lonelinessDao = lonelinessDao,
        _activitiesDao = activitiesDao,
        _mockOverride = mockOverride;

  @override
  Future<GentleProgressData> getProgressData() async {
    if (_mockOverride != null) {
      return _mockOverride!;
    }

    // 1. Gather timestamps from available DAOs
    final activeTimestamps = <DateTime>[];

    int journalCount = 0;
    if (_journalDao != null) {
      final entries = await _journalDao!.getAllEntries();
      journalCount = entries.length;
      for (final e in entries) {
        activeTimestamps.add(DateTime.fromMillisecondsSinceEpoch(e.createdAtUnix * 1000));
      }
    }

    int groundingCount = 0;
    int tinyStepsCount = 0;
    if (_activitiesDao != null) {
      // Check logged sessions
      final breathingLogs =
          await _activitiesDao!.getEffectivenessLogsForActivity('breathing_cyclicSighing');
      final pmrLogs =
          await _activitiesDao!.getEffectivenessLogsForActivity('act_pmr_full');
      final groundingLogs =
          await _activitiesDao!.getEffectivenessLogsForActivity('act_54321_sensory');
      final tinyStepLogs =
          await _activitiesDao!.getEffectivenessLogsForActivity('act_tiny_steps');

      groundingCount = breathingLogs.length + pmrLogs.length + groundingLogs.length;
      tinyStepsCount = tinyStepLogs.length;

      for (final l in [...breathingLogs, ...pmrLogs, ...groundingLogs, ...tinyStepLogs]) {
        activeTimestamps.add(l.timestamp);
      }
    }

    // 2. Fetch social experiment insights
    dynamic socialSummary;
    if (_lonelinessDao != null) {
      final experiments = await _lonelinessDao!.getExperiments();
      for (final exp in experiments) {
        activeTimestamps.add(
          DateTime.fromMillisecondsSinceEpoch(exp.predictedAtUnix * 1000),
        );
      }
      socialSummary = await _lonelinessDao!.getExperimentSummary();
    }

    // 3. Calculate 7-day presence for the current week (Monday to Sunday)
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    final weekPresence = List<bool>.filled(7, false);
    for (int i = 0; i < 7; i++) {
      final dayStart = monday.add(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));

      // Mark true if any recorded session fell on this day, or if today and app is open
      final hasSession = activeTimestamps.any(
        (t) => t.isAfter(dayStart) && t.isBefore(dayEnd),
      );

      // Always grant quiet presence for today when checking progress
      final isToday = now.year == dayStart.year &&
          now.month == dayStart.month &&
          now.day == dayStart.day;

      weekPresence[i] = hasSession || isToday;
    }

    final activeDaysCount = weekPresence.where((p) => p).length;

    return GentleProgressData(
      weekPresence: weekPresence,
      activeDaysCount: activeDaysCount,
      groundingSessionsCount: groundingCount,
      journalEntriesCount: journalCount,
      tinyStepsCount: tinyStepsCount,
      socialSummary: socialSummary,
    );
  }
}
