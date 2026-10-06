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
    ];
  }
}
