import 'dart:io';
import '../../../lib/features/compassion/data/repositories/compassion_repository_impl.dart';
import '../../../lib/features/compassion/domain/models/compassion_exercise_type.dart';
import '../../../lib/features/compassion/domain/models/compassion_session.dart';
import '../../../lib/features/compassion/domain/models/self_compassion_component.dart';
import '../../../lib/features/compassion/domain/models/untangled_thought.dart';

void main() async {
  stdout.writeln('=== Verifying Story 19.1: Self-Compassion Domain Models & Repository ===');

  // 1. SelfCompassionComponent (Kristin Neff's 3 Pillars)
  assert(SelfCompassionComponent.values.length == 3, 'Must have exactly 3 components');
  assert(SelfCompassionComponent.mindfulness.stepNumber == 1);
  assert(SelfCompassionComponent.commonHumanity.stepNumber == 2);
  assert(SelfCompassionComponent.selfKindness.stepNumber == 3);

  assert(SelfCompassionComponent.mindfulness.title == 'Mindfulness');
  assert(SelfCompassionComponent.commonHumanity.title == 'Common Humanity');
  assert(SelfCompassionComponent.selfKindness.title == 'Self-Kindness');

  assert(SelfCompassionComponent.mindfulness.shortPhrase.contains('moment of difficulty'));
  assert(SelfCompassionComponent.commonHumanity.shortPhrase.contains('natural part of human life'));
  assert(SelfCompassionComponent.selfKindness.shortPhrase.contains('warmth'));

  assert(SelfCompassionComponent.selfKindness.somaticPrompt.contains('hand over your heart'));
  stdout.writeln('✓ SelfCompassionComponent Neff 3-pillar validation passed.');

  // 2. CompassionExerciseType
  assert(CompassionExerciseType.values.length == 3);
  assert(CompassionExerciseType.selfCompassionBreak.estimatedMinutes == 3);
  assert(CompassionExerciseType.thoughtUntangler.estimatedMinutes == 4);
  assert(CompassionExerciseType.lovingKindnessPhrases.estimatedMinutes == 3);
  stdout.writeln('✓ CompassionExerciseType validation passed.');

  // 3. UntangledThought Serialization
  final thought = UntangledThought.create(
    triggerContext: 'Made an error in front of colleagues.',
    harshCriticVoice: 'You always mess up. You do not belong here.',
    commonHumanityPerspective: 'Everyone makes mistakes under stress. It is human.',
    compassionateFriendReframe: 'You are tired, but you handled it honorably. Take a deep breath.',
  );

  final thoughtJson = thought.toJson();
  final restoredThought = UntangledThought.fromJson(thoughtJson);
  assert(restoredThought.id == thought.id);
  assert(restoredThought.triggerContext == thought.triggerContext);
  assert(restoredThought.harshCriticVoice == thought.harshCriticVoice);
  assert(restoredThought.commonHumanityPerspective == thought.commonHumanityPerspective);
  assert(restoredThought.compassionateFriendReframe == thought.compassionateFriendReframe);
  stdout.writeln('✓ UntangledThought serialization roundtrip passed.');

  // 4. CompassionSession Serialization
  final session = CompassionSession.create(
    exerciseType: CompassionExerciseType.selfCompassionBreak,
    preDistressRating: 4,
  ).copyWith(
    completedAt: DateTime.now(),
    postDistressRating: 2,
    reflectionNote: 'Hand-to-heart touch lowered my racing heart rate.',
    untangledThought: thought,
  );

  final sessionJson = session.toJson();
  final restoredSession = CompassionSession.fromJson(sessionJson);
  assert(restoredSession.id == session.id);
  assert(restoredSession.exerciseType == CompassionExerciseType.selfCompassionBreak);
  assert(restoredSession.preDistressRating == 4);
  assert(restoredSession.postDistressRating == 2);
  assert(restoredSession.isCompleted);
  assert(restoredSession.untangledThought?.id == thought.id);
  stdout.writeln('✓ CompassionSession serialization roundtrip passed.');

  // 5. CompassionRepository Operations
  final repo = CompassionRepositoryImpl();
  await repo.saveSession(session);
  final sessions = await repo.getRecentSessions();
  assert(sessions.length == 1);
  assert(sessions.first.id == session.id);

  await repo.saveUntangledThought(thought);
  var thoughts = await repo.getUntangledThoughts();
  assert(thoughts.length == 1);
  assert(thoughts.first.id == thought.id);

  await repo.deleteUntangledThought(thought.id);
  thoughts = await repo.getUntangledThoughts();
  assert(thoughts.isEmpty);
  stdout.writeln('✓ CompassionRepository operations (save, query, delete) passed.');

  stdout.writeln('=== STORY 19.1 DOMAIN TESTS PASSED (100% OK) ===');
}
