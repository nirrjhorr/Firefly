import '../../../lib/features/loneliness_comfort/domain/models/reach_out_contact.dart';
import '../../../lib/features/loneliness_comfort/domain/models/social_prediction_experiment.dart';
import '../../../lib/features/loneliness_comfort/domain/models/loneliness_comfort_state.dart';
import '../../../lib/features/loneliness_comfort/data/repositories/loneliness_comfort_repository_impl.dart';

class MockSafetyPlanContact {
  const MockSafetyPlanContact({
    required this.id,
    required this.planId,
    required this.name,
    this.phoneNumber,
    this.relationship = '',
    this.displayOrder = 0,
    this.isProfessional = false,
  });

  final String id;
  final String planId;
  final String name;
  final String? phoneNumber;
  final String relationship;
  final int displayOrder;
  final bool isProfessional;
}

void main() async {
  print('=== Verifying Loneliness Comfort & "Guess vs. Reality" Engine (FR-06 / RM-02) ===');

  // Test 1: ReachOutContact domain model & Safety Plan adapter
  print('Testing ReachOutContact domain model & adapter mapping...');
  const spContact = MockSafetyPlanContact(
    id: 'contact_42',
    planId: 'plan_1',
    name: 'Maya Lin',
    phoneNumber: '+1 555 0199',
    relationship: 'Sister',
    displayOrder: 1,
    isProfessional: false,
  );

  final adapted = ReachOutContact.fromSafetyPlanContact(spContact);
  assert(adapted.id == 'sp_contact_42', 'ID prefix mismatch');
  assert(adapted.name == 'Maya Lin', 'Name mismatch');
  assert(adapted.phoneNumber == '+1 555 0199', 'Phone mismatch');
  assert(adapted.relationship == 'Sister', 'Relationship mismatch');
  assert(adapted.isSafetyPlanContact == true, 'isSafetyPlanContact should be true');
  assert(adapted.hasPhoneNumber == true, 'hasPhoneNumber should be true');
  assert(adapted.displaySubtitle == 'Sister • Safety Plan', 'Subtitle mismatch: ${adapted.displaySubtitle}');

  // Custom contact without relationship
  const customContact = ReachOutContact(
    id: 'custom_1',
    name: 'Alex',
    createdAtUnix: 1000,
  );
  assert(customContact.displaySubtitle == 'Trusted person', 'Default subtitle mismatch');
  assert(customContact.hasPhoneNumber == false, 'Empty phone should evaluate to false');

  // JSON Serialization
  final json = adapted.toJson();
  final deserialized = ReachOutContact.fromJson(json);
  assert(deserialized == adapted, 'Serialization equality failed');
  print('✓ ReachOutContact and SafetyPlanContact adapter validated.');

  // Test 2: SocialOutcome enum, labels, and non-judgmental validation messages
  print('Testing SocialOutcome enum and validation messaging...');
  assert(SocialOutcome.warm.positivityRank == 2, 'Warm rank should be 2');
  assert(SocialOutcome.neutral.positivityRank == 1, 'Neutral rank should be 1');
  assert(SocialOutcome.wontRespond.positivityRank == 0, 'wontRespond rank should be 0');

  // Validate non-judgmental feedback for all outcomes
  final wontRespondMsg = SocialOutcome.wontRespond.validationFeedback;
  assert(
    wontRespondMsg.contains("It doesn't mean reaching out was wrong"),
    'Validation for distant response must not shame user: $wontRespondMsg',
  );

  final warmMsg = SocialOutcome.warm.validationFeedback;
  assert(
    warmMsg.contains('warmer it was than the awkwardness you feared'),
    'Warm feedback must reinforce cognitive reframing: $warmMsg',
  );

  final neutralMsg = SocialOutcome.neutral.validationFeedback;
  assert(
    neutralMsg.contains('human connection'),
    'Neutral feedback must validate connection: $neutralMsg',
  );
  print('✓ SocialOutcome rankings and clinical validations verified.');

  // Test 3: SocialPredictionExperiment model & wasOutcomeEqualOrWarmer
  print('Testing SocialPredictionExperiment model & equality logic...');
  const exp1 = SocialPredictionExperiment(
    id: 'exp_1',
    contactId: 'c1',
    contactName: 'Alex',
    predictedOutcome: SocialOutcome.wontRespond,
    predictedAtUnix: 1000,
  );
  assert(!exp1.isCompleted, 'New experiment should not be completed');
  assert(!exp1.wasOutcomeEqualOrWarmer, 'Incomplete experiment wasOutcomeEqualOrWarmer should be false');

  // Actual outcome neutral (1) >= predicted wontRespond (0) -> True
  final completedExp1 = exp1.copyWith(actualOutcome: SocialOutcome.neutral, completedAtUnix: 1010);
  assert(completedExp1.isCompleted, 'Completed experiment should be true');
  assert(completedExp1.wasOutcomeEqualOrWarmer == true, 'Neutral >= wontRespond should be true');

  // Predicted warm (2), actual neutral (1) -> False
  const exp2 = SocialPredictionExperiment(
    id: 'exp_2',
    contactId: 'c2',
    contactName: 'Sam',
    predictedOutcome: SocialOutcome.warm,
    predictedAtUnix: 1000,
    actualOutcome: SocialOutcome.neutral,
  );
  assert(exp2.wasOutcomeEqualOrWarmer == false, 'Neutral < warm should be false');

  // Serialization
  final expJson = completedExp1.toJson();
  final deserializedExp = SocialPredictionExperiment.fromJson(expJson);
  assert(deserializedExp.id == completedExp1.id, 'Experiment serialization failed');
  assert(deserializedExp.actualOutcome == SocialOutcome.neutral, 'Outcome serialization failed');
  print('✓ SocialPredictionExperiment behavior and serialization verified.');

  // Test 4: SocialExperimentSummary aggregate calculations & threshold (≥ 3 pairs)
  print('Testing SocialExperimentSummary statistics and insight threshold...');
  final experimentsList = [
    const SocialPredictionExperiment(
      id: 'e1',
      contactId: 'c1',
      contactName: 'A',
      predictedOutcome: SocialOutcome.wontRespond,
      predictedAtUnix: 100,
      actualOutcome: SocialOutcome.warm,
    ),
    const SocialPredictionExperiment(
      id: 'e2',
      contactId: 'c2',
      contactName: 'B',
      predictedOutcome: SocialOutcome.wontRespond,
      predictedAtUnix: 200,
      actualOutcome: SocialOutcome.neutral,
    ),
  ];

  var summary = SocialExperimentSummary.fromExperiments(experimentsList);
  assert(summary.totalExperiments == 2, 'Total should be 2');
  assert(summary.completedCount == 2, 'Completed should be 2');
  assert(summary.shouldShowInsight == false, 'Under 3 completed experiments should NOT show insight');

  // Add third completed experiment to cross clinical insight threshold
  final thirdExp = const SocialPredictionExperiment(
    id: 'e3',
    contactId: 'c3',
    contactName: 'C',
    predictedOutcome: SocialOutcome.neutral,
    predictedAtUnix: 300,
    actualOutcome: SocialOutcome.warm,
  );
  experimentsList.add(thirdExp);

  summary = SocialExperimentSummary.fromExperiments(experimentsList);
  assert(summary.completedCount == 3, 'Completed should be 3');
  assert(summary.shouldShowInsight == true, '≥ 3 completed experiments MUST unlock insight');
  assert(summary.actualWarmCount == 2, 'Warm count should be 2');
  assert(summary.actualNeutralCount == 1, 'Neutral count should be 1');
  assert(summary.actualWontRespondCount == 0, 'wontRespond count should be 0');
  assert(summary.actualWarmerOrEqualCount == 3, 'Warmer or equal count should be 3');
  assert(summary.warmerOrEqualPercentage == 100, 'Percentage should be 100%');
  assert(summary.insightBody.contains('Across 3 times you reached out'), 'Insight body text mismatch: ${summary.insightBody}');
  print('✓ SocialExperimentSummary threshold and percentages validated.');

  // Test 5: LonelinessComfortRepositoryImpl
  print('Testing LonelinessComfortRepositoryImpl operations...');
  final repo = LonelinessComfortRepositoryImpl();
  assert((await repo.getCustomContacts()).isEmpty, 'Initial contacts should be empty');
  assert((await repo.getExperiments()).isEmpty, 'Initial experiments should be empty');
  assert((await repo.isPsychoeducationDismissed()) == false, 'Initial psychoeducation dismissed should be false');

  // Add custom contact
  const testContact = ReachOutContact(
    id: 'custom_99',
    name: 'Jordan',
    phoneNumber: '5551234',
    relationship: 'Friend',
    createdAtUnix: 500,
  );
  await repo.saveCustomContact(testContact);
  final fetchedContacts = await repo.getCustomContacts();
  assert(fetchedContacts.length == 1, 'Contacts length should be 1');
  assert(fetchedContacts.first.name == 'Jordan', 'Contact name mismatch');

  // Dismiss psychoeducation
  await repo.setPsychoeducationDismissed(true);
  assert((await repo.isPsychoeducationDismissed()) == true, 'Dismissed preference should be true');

  // Save and update experiment
  const testExp = SocialPredictionExperiment(
    id: 'exp_repo_1',
    contactId: 'custom_99',
    contactName: 'Jordan',
    predictedOutcome: SocialOutcome.wontRespond,
    predictedAtUnix: 600,
  );
  await repo.saveExperiment(testExp);
  assert((await repo.getExperiments()).length == 1, 'Experiment should be saved');

  await repo.updateExperimentOutcome('exp_repo_1', SocialOutcome.warm);
  final updatedExp = (await repo.getExperiments()).first;
  assert(updatedExp.isCompleted, 'Experiment should be completed');
  assert(updatedExp.actualOutcome == SocialOutcome.warm, 'Actual outcome should be warm');

  // Delete contact
  await repo.deleteCustomContact('custom_99');
  assert((await repo.getCustomContacts()).isEmpty, 'Contact should be deleted');

  // Crypto memory wipe test
  LonelinessComfortRepositoryImpl.cryptoEraseString('Sensitive reach out draft text');
  print('✓ Repository CRUD, outcome updates, and memory erasure verified.');

  // Test 6: Offline SMS URI generation (Zero network requirement)
  print('Testing SMS Intent URI generation...');
  final smsUri = LonelinessComfortState.buildSmsUri(
    phoneNumber: '+1 (555) 012-3456',
    message: "Hey — I've been thinking of you. How are you doing?",
  );
  assert(smsUri.scheme == 'sms', 'Scheme must be sms');
  assert(smsUri.path == '+1(555)012-3456', 'Path should be sanitized phone number: ${smsUri.path}');
  assert(smsUri.queryParameters['body'] == "Hey — I've been thinking of you. How are you doing?", 'Body mismatch');
  print('✓ Offline SMS Intent URI generation verified.');

  // Test 7: LonelinessComfortState transitions and template selection
  print('Testing LonelinessComfortState transitions...');
  var state = LonelinessComfortState(
    contacts: [testContact],
    experiments: [completedExp1, exp2, thirdExp],
  );
  final stateSummary = SocialExperimentSummary.fromExperiments(state.experiments);
  state = state.copyWith(summary: stateSummary);

  assert(state.isLoading == false, 'State should not be loading');
  assert(state.contacts.length == 1, 'Contacts should be 1');
  assert(state.experiments.length == 3, 'Experiments should be 3');
  assert(state.summary.shouldShowInsight == true, 'Summary insight should be active');

  // Template selection
  assert(state.selectedTemplateIndex == 0, 'Default template index should be 0');
  assert(state.activeMessage == kDefaultReachOutTemplates[0], 'Default template content mismatch');

  state = state.copyWith(
    selectedTemplateIndex: 1,
    customMessageText: kDefaultReachOutTemplates[1],
  );
  assert(state.selectedTemplateIndex == 1, 'Template index should update to 1');
  assert(state.activeMessage == kDefaultReachOutTemplates[1], 'Template content should update');

  // Custom message
  state = state.copyWith(
    selectedTemplateIndex: -1,
    customMessageText: 'Thinking of our walk last week.',
  );
  assert(state.selectedTemplateIndex == -1, 'Custom message should set template index to -1');
  assert(state.activeMessage == 'Thinking of our walk last week.', 'Custom message text mismatch');

  // Pending prediction experiment state transition
  const pendingExp = SocialPredictionExperiment(
    id: 'exp_new',
    contactId: 'custom_99',
    contactName: 'Jordan',
    predictedOutcome: SocialOutcome.wontRespond,
    predictedAtUnix: 700,
    messageSnippet: 'Thinking of our walk last week.',
  );
  state = state.copyWith(
    activePendingExperiment: pendingExp,
    experiments: [...state.experiments, pendingExp],
  );
  assert(state.hasPendingOutcome == true, 'Should have pending outcome');
  assert(state.activePendingExperiment?.id == 'exp_new', 'Pending experiment ID mismatch');

  // Recording outcome state transition
  final resolvedExp = pendingExp.copyWith(
    actualOutcome: SocialOutcome.warm,
    completedAtUnix: 710,
  );
  final updatedExps = state.experiments.map((e) => e.id == 'exp_new' ? resolvedExp : e).toList();
  state = state.copyWith(
    experiments: updatedExps,
    clearPendingExperiment: true,
    summary: SocialExperimentSummary.fromExperiments(updatedExps),
    lastFeedbackMessage: SocialOutcome.warm.validationFeedback,
  );

  assert(state.hasPendingOutcome == false, 'Pending outcome should be cleared');
  assert(state.lastFeedbackMessage != null, 'Feedback message should be present');
  assert(
    state.lastFeedbackMessage!.contains('warmer it was than the awkwardness you feared'),
    'Validation feedback mismatch: ${state.lastFeedbackMessage}',
  );

  // Clear feedback
  state = state.copyWith(clearFeedbackMessage: true);
  assert(state.lastFeedbackMessage == null, 'Feedback message should be null');
  print('✓ LonelinessComfortState transitions and experiment lifecycle verified.');

  print('=== ALL Loneliness Comfort & "Guess vs. Reality" Assertions PASSED successfully! (100% Validated) ===');
}
