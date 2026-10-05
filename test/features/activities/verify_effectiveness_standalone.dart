import '../../../lib/features/activities/domain/models/activity_effectiveness_log.dart';

class TestEffectivenessStore {
  final List<ActivityEffectivenessLog> _logs = [];

  Future<void> logEffectiveness(ActivityEffectivenessLog log) async {
    _logs.add(log);
  }

  Future<List<ActivityEffectivenessLog>> getLogsForActivity(String activityId) async {
    return _logs.where((l) => l.activityId == activityId).toList();
  }
}

void main() async {
  print('=== Verifying Activity Effectiveness Model & Logging Logic ===');

  // 1. Verify discrete rating bounds (-2 to +2)
  for (int r = -2; r <= 2; r++) {
    final log = ActivityEffectivenessLog(
      id: 'test-$r',
      activityId: 'breathing_cyclicSighing',
      stateAtStart: 'anxious_tense',
      rating: r,
      timestamp: DateTime.now(),
      durationSeconds: 120,
    );
    assert(log.rating == r, 'Rating must match $r');
    final json = log.toJson();
    final reconstructed = ActivityEffectivenessLog.fromJson(json);
    assert(reconstructed.id == log.id);
    assert(reconstructed.rating == log.rating);
    assert(reconstructed.durationSeconds == 120);
    print('Rating $r serialized & reconstructed successfully.');
  }

  // 2. Verify invalid rating outside [-2, +2] throws AssertionError
  bool threwOnInvalid = false;
  try {
    ActivityEffectivenessLog(
      id: 'invalid-test',
      activityId: 'breathing',
      stateAtStart: 'calm',
      rating: 5, // Invalid, out of -2..+2 bounds!
      timestamp: DateTime.now(),
      durationSeconds: 60,
    );
  } catch (e) {
    threwOnInvalid = true;
    print('Correctly rejected rating 5 out of bounds: $e');
  }
  assert(threwOnInvalid, 'Must throw when rating is outside [-2, 2]');

  // 3. Verify logging store
  final store = TestEffectivenessStore();
  final log1 = ActivityEffectivenessLog(
    id: 'log-1',
    activityId: 'act-box-breathing',
    stateAtStart: 'high_distress',
    rating: 2,
    timestamp: DateTime.now(),
    durationSeconds: 180,
  );
  final log2 = ActivityEffectivenessLog(
    id: 'log-2',
    activityId: 'act-box-breathing',
    stateAtStart: 'moderate_stress',
    rating: 1,
    timestamp: DateTime.now(),
    durationSeconds: 240,
  );

  await store.logEffectiveness(log1);
  await store.logEffectiveness(log2);

  final logs = await store.getLogsForActivity('act-box-breathing');
  assert(logs.length == 2, 'Must have 2 logs');
  assert(logs.first.id == 'log-1');
  assert(logs.last.id == 'log-2');
  print('Retrieved ${logs.length} logged sessions for act-box-breathing successfully.');

  print('=== All Activity Effectiveness Assertions PASSED successfully! ===');
}
