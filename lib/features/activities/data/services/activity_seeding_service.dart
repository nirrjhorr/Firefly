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
    ];
  }
}
