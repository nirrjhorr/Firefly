import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/database/daos/activities_dao.dart';
import '../../domain/models/activity_item.dart';

/// Service responsible for idempotent first-launch seeding of the 16-category activity catalog.
class ActivitySeedingService {
  ActivitySeedingService(this._dao);

  final ActivitiesDao _dao;
  static const String assetPath = 'assets/data/curated_activities.json';

  /// Performs idempotent seed check: seeds activities from bundled asset if database is empty.
  Future<int> seedIfNeeded() async {
    final count = await _dao.countActivities();
    if (count > 0) {
      return count;
    }

    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      final activities = decoded
          .map((e) => ActivityItem.fromJson(e as Map<String, dynamic>))
          .toList();

      await _dao.insertAll(activities);
      return activities.length;
    } catch (_) {
      // Fallback: seed minimal core emergency catalog if asset load fails
      final fallback = _getCoreFallbackCatalog();
      await _dao.insertAll(fallback);
      return fallback.length;
    }
  }

  /// Core hardcoded fallback catalog to ensure emergency access even if asset reading fails.
  List<ActivityItem> _getCoreFallbackCatalog() {
    return [
      ActivityItem.fromJson({
        'id': 'act_cyclic_sighing',
        'title': 'Cyclic Sighing',
        'description': 'Double inhale followed by a prolonged exhale to calm the nervous system.',
        'category': 'respiration',
        'energyRequired': 1,
        'targetStates': ['anxious', 'panicked', 'overwhelmed'],
        'guidanceType': 'interactivePainter',
        'evidenceLevel': 'verified',
        'route': '/home/breathe?technique=cyclicSighing',
        'durationMinutes': 3,
        'instructions': ['Inhale deeply', 'Top off with quick second inhale', 'Sigh all air out'],
      }),
      ActivityItem.fromJson({
        'id': 'act_54321_grounding',
        'title': '5-4-3-2-1 Sensory Grounding',
        'description': 'Engage all five senses sequentially to ground in reality.',
        'category': 'sensoryGrounding',
        'energyRequired': 1,
        'targetStates': ['panicked', 'overwhelmed', 'racingThoughts'],
        'guidanceType': 'promptCards',
        'evidenceLevel': 'clinicalConsensus',
        'route': '/home/breathe?mode=grounding',
        'durationMinutes': 3,
        'instructions': ['5 see, 4 touch, 3 hear, 2 smell, 1 taste'],
      }),
      ActivityItem.fromJson({
        'id': 'act_pmr_full',
        'title': 'Muscle Relaxation',
        'description': 'Progressive muscle tension and release.',
        'category': 'pmr',
        'energyRequired': 2,
        'targetStates': ['anxious', 'restless', 'cantSleep'],
        'guidanceType': 'interactiveMap',
        'evidenceLevel': 'verified',
        'route': '/home/pmr',
        'durationMinutes': 5,
        'instructions': ['Tense for 5s', 'Release for 10s'],
      }),
      ActivityItem.fromJson({
        'id': 'act_tiny_drink_water',
        'title': 'Take a Sip of Water',
        'description': 'One small hydrating action.',
        'category': 'behavioralActivation',
        'energyRequired': 1,
        'targetStates': ['lowEnergy', 'flat'],
        'guidanceType': 'stepSequence',
        'evidenceLevel': 'verified',
        'route': '/home/tiny-steps',
        'durationMinutes': 1,
        'instructions': ['Drink fresh water slowly'],
      }),
      ActivityItem.fromJson({
        'id': 'act_hope_box_glance',
        'title': 'Visit Your Hope Box',
        'description': 'Glance at private photos, comforting voice notes, and reasons to keep holding on.',
        'category': 'social',
        'energyRequired': 1,
        'targetStates': ['lonely', 'flat', 'overwhelmed'],
        'guidanceType': 'promptCards',
        'evidenceLevel': 'verified',
        'route': '/home/hope-box',
        'durationMinutes': 3,
        'instructions': ['Open your safe hope box', 'Look at one photo or note', 'Remind yourself why staying matters'],
      }),
      ActivityItem.fromJson({
        'id': 'act_sleep_worry_dump',
        'title': 'Night Worry Dump',
        'description': 'Offload evening racing thoughts into a locked note until morning or dissolve them completely.',
        'category': 'sleep',
        'energyRequired': 1,
        'targetStates': ['cantSleep', 'racingThoughts', 'anxious'],
        'guidanceType': 'promptCards',
        'evidenceLevel': 'verified',
        'route': '/home/sleep?mode=worryDump',
        'durationMinutes': 5,
        'instructions': ['Write whatever feels unfinished', 'Choose to park it until 8:00 AM or dissolve it into mist'],
      }),
      ActivityItem.fromJson({
        'id': 'act_cognitive_categories',
        'title': 'Category Word Switch',
        'description': 'Gently switch attention to soothing neutral categories to break intrusive thought cycles.',
        'category': 'cognitiveGrounding',
        'energyRequired': 2,
        'targetStates': ['racingThoughts', 'anxious', 'overwhelmed'],
        'guidanceType': 'promptCards',
        'evidenceLevel': 'verified',
        'route': '/home/cognitive-grounding',
        'durationMinutes': 3,
        'instructions': ['Read the category prompt', 'Name items at your own steady pace', 'No scoring, no timer, no pressure'],
      }),
      ActivityItem.fromJson({
        'id': 'act_movement_shakeout',
        'title': 'Somatic Shakeout',
        'description': 'Gently shake out hands, arms, and shoulders to release stored somatic nervous tension.',
        'category': 'physical',
        'energyRequired': 2,
        'targetStates': ['restless', 'anxious', 'overwhelmed'],
        'guidanceType': 'timerWithAudio',
        'evidenceLevel': 'verified',
        'route': '/home/move?mode=shakeout',
        'durationMinutes': 2,
        'instructions': ['Stand or sit tall', 'Shake out wrists and hands', 'Let tension drop out through your fingers'],
      }),
      ActivityItem.fromJson({
        'id': 'act_social_reach_out',
        'title': 'One-Tap Reaching Out',
        'description': 'Send a pre-written text message to a trusted contact without feeling awkward.',
        'category': 'social',
        'energyRequired': 2,
        'targetStates': ['lonely', 'overwhelmed', 'needExpression'],
        'guidanceType': 'promptCards',
        'evidenceLevel': 'verified',
        'route': '/home/loneliness',
        'durationMinutes': 3,
        'instructions': ['Select someone from your safe contact list', 'Choose a warm pre-written note', 'Tap send without pressure'],
      }),
      ActivityItem.fromJson({
        'id': 'act_nature_sky_gazing',
        'title': 'Sky & Cloud Gazing',
        'description': 'Soften your vision and observe the vast sky or light through your window.',
        'category': 'nature',
        'energyRequired': 1,
        'targetStates': ['overwhelmed', 'racingThoughts', 'restless'],
        'guidanceType': 'promptCards',
        'evidenceLevel': 'verified',
        'route': '/home/nature?mode=skyGazing',
        'durationMinutes': 3,
        'instructions': ['Look toward the open sky or ceiling', 'Observe the quiet drift of light and space'],
      }),
      ActivityItem.fromJson({
        'id': 'act_somatic_heavy_body',
        'title': 'Heavy Body Gravity Settling',
        'description': 'Notice downward gravitational pull and release muscular vigilance in jaw, shoulders, and limbs.',
        'category': 'mindfulness',
        'energyRequired': 1,
        'targetStates': ['restless', 'anxious', 'overwhelmed', 'cantSleep'],
        'guidanceType': 'promptCards',
        'evidenceLevel': 'verified',
        'route': '/home/somatic?mode=heavyBody',
        'durationMinutes': 3,
        'instructions': ['Notice the solid surface holding you up', 'Let go of muscular vigilance', 'Allow gravity to carry your weight'],
      }),
      ActivityItem.fromJson({
        'id': 'act_labyrinth_classical',
        'title': 'Classical Cretan Labyrinth',
        'description': 'Unicursal geometric finger tracing winding slowly inward to center stillness.',
        'category': 'labyrinth',
        'energyRequired': 1,
        'targetStates': ['racingThoughts', 'restless', 'anxious', 'overwhelmed'],
        'guidanceType': 'interactivePainter',
        'evidenceLevel': 'verified',
        'route': '/home/labyrinth?pattern=classical',
        'durationMinutes': 4,
        'instructions': ['Place your finger at the outer opening', 'Follow the winding track inward', 'Rest in the center circle'],
      }),
      ActivityItem.fromJson({
        'id': 'act_flow_puzzle_constellation',
        'title': 'Constellation Star Flow',
        'description': 'Gently connect celestial stars to reveal serene constellations, absorbing working memory.',
        'category': 'flow',
        'energyRequired': 1,
        'targetStates': ['racingThoughts', 'restless', 'anxious', 'overwhelmed'],
        'guidanceType': 'interactivePainter',
        'evidenceLevel': 'verified',
        'route': '/home/flow-puzzle?mode=constellationConnect',
        'durationMinutes': 4,
        'instructions': ['Touch star 1 to begin', 'Follow the glowing numbers across the tranquil sky', 'Watch the celestial shape emerge'],
      }),
      ActivityItem.fromJson({
        'id': 'act_flow_puzzle_harmony_tiles',
        'title': 'Harmony Sliding Tiles',
        'description': 'Slowly slide numbered tactile tiles into harmonious order with zero pressure, timers, or score.',
        'category': 'flow',
        'energyRequired': 1,
        'targetStates': ['racingThoughts', 'restless', 'flat'],
        'guidanceType': 'interactivePainter',
        'evidenceLevel': 'verified',
        'route': '/home/flow-puzzle?mode=spatialSliding',
        'durationMinutes': 5,
        'instructions': ['Tap any highlighted tile adjacent to the space', 'Move stones with unhurried tactile rhythm', 'Restore gentle balance to the grid'],
      }),
      ActivityItem.fromJson({
        'id': 'act_unsent_letter',
        'title': 'Unsent Letter & Cathartic Burn',
        'description': 'Express difficult or honest feelings in total privacy, with instant cryptographic zeroing when finished.',
        'category': 'emotionalExpression',
        'energyRequired': 2,
        'targetStates': ['needExpression', 'overwhelmed', 'lonely', 'anxious'],
        'guidanceType': 'freeform',
        'evidenceLevel': 'verified',
        'route': '/home/unsent-letter',
        'durationMinutes': 5,
        'instructions': ['Write whatever feels heavy or unsaid', 'No transmission is possible', 'Choose to keep encrypted or burn to zero'],
      }),
      ActivityItem.fromJson({
        'id': 'act_worry_dump',
        'title': 'Encrypted Worry Dump',
        'description': 'Move anxious thoughts from your mind onto dark paper so you can park them until tomorrow.',
        'category': 'emotionalExpression',
        'energyRequired': 1,
        'targetStates': ['cantSleep', 'racingThoughts', 'anxious', 'overwhelmed'],
        'guidanceType': 'freeform',
        'evidenceLevel': 'verified',
        'route': '/home/worry-dump',
        'durationMinutes': 5,
        'instructions': ['Write down the thoughts looping through your head', 'Choose to park them until tomorrow or let them dissolve'],
      }),
      ActivityItem.fromJson({
        'id': 'act_defusion_leaves_stream',
        'title': 'Leaves on a Stream',
        'description': 'Visualize thoughts as autumn leaves floating down a quiet woodland stream, watching them pass by.',
        'category': 'cognitiveDefusion',
        'energyRequired': 1,
        'targetStates': ['racingThoughts', 'overwhelmed', 'anxious'],
        'guidanceType': 'interactivePainter',
        'evidenceLevel': 'verified',
        'route': '/home/defusion?mode=leaves',
        'durationMinutes': 4,
        'instructions': ['Notice the slow-moving woodland current', 'Place an active thought on a leaf', 'Watch it float gently downstream out of sight'],
      }),
      ActivityItem.fromJson({
        'id': 'act_defusion_thought_clouds',
        'title': 'Thought Cloud Dissolve',
        'description': 'Type a heavy thought into a twilight cloud and watch it dissolve into soft mist.',
        'category': 'cognitiveDefusion',
        'energyRequired': 1,
        'targetStates': ['racingThoughts', 'overwhelmed'],
        'guidanceType': 'interactivePainter',
        'evidenceLevel': 'verified',
        'route': '/home/defusion?mode=clouds',
        'durationMinutes': 3,
        'instructions': ['Type a thought weighing on your mind', 'Tap release', 'Watch it dissolve into the peaceful sky'],
      }),
      ActivityItem.fromJson({
        'id': 'act_defusion_thought_labeling',
        'title': 'Thought Labelling & Distance',
        'description': 'Step back from fused thoughts using 3-step mindful distance: "I notice I am having the thought that..."',
        'category': 'cognitiveDefusion',
        'energyRequired': 1,
        'targetStates': ['racingThoughts', 'overwhelmed', 'anxious'],
        'guidanceType': 'promptCards',
        'evidenceLevel': 'verified',
        'route': '/home/defusion?mode=labeling',
        'durationMinutes': 3,
        'instructions': ['Read the fused thought', 'Insert "I notice I am having the thought that..."', 'Recognize yourself as the calm observer'],
      }),
    ];
  }
}
