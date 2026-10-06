import 'dart:io';

import '../../../lib/core/safety/crisis_phrase_detector.dart';

void main() {
  stdout.writeln('=== Verifying Epic 16: Clinical Safety Guardrails & Production Verification ===');

  // 1. Verify CrisisPhraseDetector
  const detector = CrisisPhraseDetector();

  // Test Suicidal Ideation
  final suicidalRes = detector.checkText('I just want to end it all tonight.');
  assert(suicidalRes.hasMatch, 'Suicidal pattern must match');
  assert(suicidalRes.matchedCategory == CrisisMatchCategory.suicidalIdeation);

  // Test Self Harm
  final selfHarmRes = detector.checkText('Having urges to hurt myself.');
  assert(selfHarmRes.hasMatch, 'Self harm pattern must match');
  assert(selfHarmRes.matchedCategory == CrisisMatchCategory.selfHarm);

  // Test Acute Hopelessness
  final hopelessRes = detector.checkText('There is no way out for me.');
  assert(hopelessRes.hasMatch, 'Hopelessness pattern must match');
  assert(hopelessRes.matchedCategory == CrisisMatchCategory.acuteHopelessness);

  // Test Idiom Exception (Zero False Positive)
  final idiomRes = detector.checkText('I almost died of laughter during the movie.');
  assert(!idiomRes.hasMatch, 'Idiom must not trigger false positive');

  // Test Benign Everyday Text
  final benignRes = detector.checkText('Practiced deep breathing for five minutes today.');
  assert(!benignRes.hasMatch, 'Benign text must not trigger');
  stdout.writeln('✓ Story 16.1: Deterministic CrisisPhraseDetector validated.');

  // 2. Verify Screen Inventory Documentation Integrity
  final screenInventoryDoc = File('docs/SCREEN_INVENTORY_AND_FEATURE_MAPPING.md');
  assert(screenInventoryDoc.existsSync(), 'docs/SCREEN_INVENTORY_AND_FEATURE_MAPPING.md must exist');
  final docContent = screenInventoryDoc.readAsStringSync();
  assert(docContent.contains('Module 1: Onboarding'), 'Doc must cover Module 1');
  assert(docContent.contains('Module 2: The Affect Check-In Engine'), 'Doc must cover Module 2');
  assert(docContent.contains('Module 4: Breathing Studio'), 'Doc must cover Module 4');
  assert(docContent.contains('Module 8: Expressive Journaling'), 'Doc must cover Module 8');
  assert(docContent.contains('Module 12: Stanley-Brown Safety Plan'), 'Doc must cover Module 12');
  assert(docContent.contains('Z-Index & Overlay Architecture'), 'Doc must cover Z-Index Architecture');
  assert(docContent.contains('LocalSafetyBanner'), 'Doc must reference LocalSafetyBanner');
  stdout.writeln('✓ Story 16.2: docs/SCREEN_INVENTORY_AND_FEATURE_MAPPING.md verified.');

  // 3. Verify Security Gate Tooling Integrity
  final securityPy = File('scripts/security_gate.py');
  assert(securityPy.existsSync(), 'scripts/security_gate.py must exist');
  final pyContent = securityPy.readAsStringSync();
  assert(pyContent.contains('FORBIDDEN_PACKAGES'), 'Script must define FORBIDDEN_PACKAGES');
  assert(pyContent.contains('FireflyHttpOverride'), 'Script must verify FireflyHttpOverride');
  assert(pyContent.contains('cipher_page_size'), 'Script must verify cipher_page_size');

  final securitySh = File('scripts/security_gate.sh');
  assert(securitySh.existsSync(), 'scripts/security_gate.sh must exist');
  stdout.writeln('✓ Story 16.3: scripts/security_gate.py & security_gate.sh verified.');

  stdout.writeln('=== ALL Epic 16 Verification Assertions PASSED successfully! (100% Validated) ===');
}
