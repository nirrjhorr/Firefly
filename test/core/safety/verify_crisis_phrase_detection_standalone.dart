import 'dart:io';

import '../../../lib/core/safety/crisis_phrase_detector.dart';

void main() {
  stdout.writeln('=== Verifying Story 16.1: Deterministic Crisis Phrase Detection & Local Safety Interceptor ===');

  const detector = CrisisPhraseDetector();

  // 1. Verify Benign / Normal Everyday Text
  final benignInputs = [
    'Today was a quiet day. Took a walk in the park.',
    'Feeling a bit tired and low energy after work.',
    'Made some soup, listened to the rain.',
    'Worrying about my exam tomorrow.',
    'Why is life so complicated sometimes?',
    '',
    '    ',
    '12345 67890 !@#\$%^&*()',
  ];

  for (final input in benignInputs) {
    final result = detector.checkText(input);
    assert(!result.hasMatch, 'Benign text triggered false positive: "$input"');
  }
  stdout.writeln('✓ Benign text inputs evaluated with zero false positives.');

  // 2. Verify Conversational Idiom Exclusions (PRD 6.2 False Positive Policy)
  final idiomInputs = [
    'I almost died of laughter watching that comedy show.',
    'I would die of embarrassment if someone saw my old photos.',
    'That chocolate dessert was to die for!',
    'I am dead tired after driving all night.',
    'I was bored to death in that two hour meeting.',
    'My parents were worried to death when my phone died.',
    'I was just killing time at the train station.',
  ];

  for (final input in idiomInputs) {
    final result = detector.checkText(input);
    assert(!result.hasMatch, 'Conversational idiom triggered false positive: "$input"');
  }
  stdout.writeln('✓ Conversational idiom exceptions properly filtered with zero false positives.');

  // 3. Verify Suicidal Ideation Detection
  final suicidalInputs = [
    'I just want to die tonight.',
    'Sometimes I feel like I wanna die.',
    'I feel like I want to kill myself.',
    'Everyone would be better off dead.',
    'I am going to end my life.',
    'Thinking about taking my own life.',
    'I just want to end it all.',
    'I hope I do not wake up tomorrow.',
    'There is no reason to live anymore.',
    "I can't go on living like this.",
    'Ready to die.',
  ];

  for (final input in suicidalInputs) {
    final result = detector.checkText(input);
    assert(result.hasMatch, 'Failed to detect suicidal ideation in: "$input"');
    assert(
      result.matchedCategory == CrisisMatchCategory.suicidalIdeation,
      'Incorrect category for "$input": ${result.matchedCategory}',
    );
    assert(result.matchedPhrase != null, 'Matched phrase must be present');
  }
  stdout.writeln('✓ Suicidal ideation patterns detected accurately across all test vectors.');

  // 4. Verify Self-Harm Detection
  final selfHarmInputs = [
    'I feel an urge to cut myself.',
    'I want to harm myself physically.',
    'I am afraid I might hurt myself.',
    'Struggling with self harm urges today.',
    'Having intense self-harm thoughts again.',
    'I burned myself on purpose.',
  ];

  for (final input in selfHarmInputs) {
    final result = detector.checkText(input);
    assert(result.hasMatch, 'Failed to detect self-harm in: "$input"');
    assert(
      result.matchedCategory == CrisisMatchCategory.selfHarm,
      'Incorrect category for "$input": ${result.matchedCategory}',
    );
  }
  stdout.writeln('✓ Self-harm patterns detected accurately across all test vectors.');

  // 5. Verify Acute Hopelessness Detection
  final hopelessnessInputs = [
    'There is no way out for me.',
    'I feel like there is no way out of this darkness.',
    'I give up on life completely.',
    'Giving up on life today.',
    'Everyone would be better without me.',
    'The whole world would be better without me.',
  ];

  for (final input in hopelessnessInputs) {
    final result = detector.checkText(input);
    assert(result.hasMatch, 'Failed to detect acute hopelessness in: "$input"');
    assert(
      result.matchedCategory == CrisisMatchCategory.acuteHopelessness,
      'Incorrect category for "$input": ${result.matchedCategory}',
    );
  }
  stdout.writeln('✓ Acute hopelessness patterns detected accurately across all test vectors.');

  // 6. Verify Punctuation, Whitespace & Case Insensitivity
  final casePunctuationInputs = [
    '   WANT TO DIE!   ',
    'I want to... DIE???',
    'KILL MYSELF.',
    'cut    myself   ',
    'NO WAY OUT FOR ME!!!',
  ];

  for (final input in casePunctuationInputs) {
    final result = detector.checkText(input);
    assert(result.hasMatch, 'Punctuation/casing resilient check failed for: "$input"');
  }
  stdout.writeln('✓ Punctuation, casing, and irregular whitespace resilience verified.');

  // 7. Verify Model Invariants & Value Equality
  const res1 = CrisisDetectionResult(
    hasMatch: true,
    matchedCategory: CrisisMatchCategory.suicidalIdeation,
    matchedPhrase: 'want to die',
  );
  const res2 = CrisisDetectionResult(
    hasMatch: true,
    matchedCategory: CrisisMatchCategory.suicidalIdeation,
    matchedPhrase: 'want to die',
  );
  const res3 = CrisisDetectionResult.none();

  assert(res1 == res2, 'Value equality failed');
  assert(res1 != res3, 'Inequality check failed');
  assert(res1.hashCode == res2.hashCode, 'Hash code equality failed');
  assert(!res3.hasMatch, 'None result must have hasMatch == false');
  stdout.writeln('✓ CrisisDetectionResult immutable value semantics verified.');

  stdout.writeln('=== ALL Story 16.1 Crisis Phrase Detection Tests PASSED! (100% Validated) ===');
}
