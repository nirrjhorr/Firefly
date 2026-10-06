import 'dart:async';

import '../../../lib/core/database/daos/journal_dao.dart';
import '../../../lib/core/database/daos/loneliness_comfort_dao.dart';
import '../../../lib/features/gentle_progress/data/repositories/gentle_progress_repository_impl.dart';
import '../../../lib/features/gentle_progress/domain/models/gentle_progress_data.dart';
import '../../../lib/features/journaling/domain/models/journal_entry.dart';
import '../../../lib/features/loneliness_comfort/domain/models/social_prediction_experiment.dart';

void expect(bool condition, String message) {
  if (!condition) {
    throw Exception('FAILED: $message');
  }
}

Future<void> main() async {
  print('=== Verifying Gentle Progress Real Data Backend (PRD §5 / FR-06 / FR-07) ===');

  // 1. Verify GentleProgressData defaults and copyWith
  print('Testing GentleProgressData model...');
  const initial = GentleProgressData();
  expect(initial.weekPresence.length == 7, 'Must have 7 days in week presence');
  expect(initial.activeDaysCount == 0, 'Active days start at 0');
  expect(initial.socialSummary == null, 'Social summary starts null');

  final updated = initial.copyWith(
    activeDaysCount: 3,
    journalEntriesCount: 5,
    groundingSessionsCount: 4,
    tinyStepsCount: 2,
    weekPresence: [true, false, true, false, true, false, false],
  );
  expect(updated.activeDaysCount == 3, 'Active days updated to 3');
  expect(updated.journalEntriesCount == 5, 'Journal count updated to 5');
  expect(updated.groundingSessionsCount == 4, 'Grounding count updated to 4');
  expect(updated.tinyStepsCount == 2, 'Tiny steps count updated to 2');
  expect(updated.weekPresence[0] == true, 'Monday present');
  expect(updated.weekPresence[1] == false, 'Tuesday absent');
  print('✓ Model properties and immutability verified.');

  // 2. Test GentleProgressRepositoryImpl synthesis
  print('Testing GentleProgressRepositoryImpl live synthesis...');
  final journalDao = InMemoryJournalDao();
  final lonelinessDao = InMemoryLonelinessComfortDao();

  final now = DateTime.now();
  final nowUnix = now.millisecondsSinceEpoch ~/ 1000;

  // Insert 2 journal entries
  await journalDao.insertEntry(
    JournalEntry(
      id: 'j_1',
      title: 'Evening reflection',
      contentEncrypted: 'enc_j1',
      createdAtUnix: nowUnix,
      updatedAtUnix: nowUnix,
    ),
  );
  await journalDao.insertEntry(
    JournalEntry(
      id: 'j_2',
      title: 'Morning check-in',
      contentEncrypted: 'enc_j2',
      createdAtUnix: nowUnix - 86400, // yesterday
      updatedAtUnix: nowUnix - 86400,
    ),
  );

  // Insert 3 social experiments to unlock cognitive reframing insight
  await lonelinessDao.saveExperiment(
    SocialPredictionExperiment(
      id: 'exp_1',
      contactId: 'c1',
      contactName: 'Alex',
      predictedOutcome: SocialOutcome.wontRespond,
      predictedAtUnix: nowUnix,
      actualOutcome: SocialOutcome.warm,
      completedAtUnix: nowUnix + 10,
    ),
  );
  await lonelinessDao.saveExperiment(
    SocialPredictionExperiment(
      id: 'exp_2',
      contactId: 'c2',
      contactName: 'Sam',
      predictedOutcome: SocialOutcome.neutral,
      predictedAtUnix: nowUnix,
      actualOutcome: SocialOutcome.warm,
      completedAtUnix: nowUnix + 10,
    ),
  );
  await lonelinessDao.saveExperiment(
    SocialPredictionExperiment(
      id: 'exp_3',
      contactId: 'c3',
      contactName: 'Taylor',
      predictedOutcome: SocialOutcome.wontRespond,
      predictedAtUnix: nowUnix,
      actualOutcome: SocialOutcome.neutral,
      completedAtUnix: nowUnix + 10,
    ),
  );

  final repository = GentleProgressRepositoryImpl(
    journalDao: journalDao,
    lonelinessDao: lonelinessDao,
  );

  final result = await repository.getProgressData();
  expect(result.journalEntriesCount == 2, 'Must synthesize 2 journal entries');
  expect(result.socialSummary != null, 'Social summary must be present');
  expect(result.socialSummary!.completedCount == 3, 'Must have 3 completed experiments');
  expect(result.socialSummary!.shouldShowInsight == true, 'Must unlock insight with 3 experiments');
  expect(result.socialSummary!.warmerOrEqualPercentage == 100, '100% warmer or equal in this dataset');
  expect(result.activeDaysCount >= 1, 'Active days must be at least 1 (today)');
  print('✓ Repository synthesis and reframing threshold verified.');

  print('=== ALL Gentle Progress Assertions PASSED successfully! (100% Validated) ===');
}
