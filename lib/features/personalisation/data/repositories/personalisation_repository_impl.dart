import '../../../../core/database/daos/activities_dao.dart';
import '../../domain/models/activity_affinity.dart';
import '../../domain/models/personal_regulation_profile.dart';
import '../../domain/repositories/personalisation_repository.dart';
import '../../domain/services/personal_effectiveness_engine.dart';

/// Implementation of [PersonalisationRepository] backed by [ActivitiesDao].
class PersonalisationRepositoryImpl implements PersonalisationRepository {
  const PersonalisationRepositoryImpl(this._dao);

  final ActivitiesDao _dao;

  @override
  Future<PersonalRegulationProfile> getProfile() async {
    final logs = await _dao.getAllEffectivenessLogs();
    return PersonalEffectivenessEngine.buildProfile(logs);
  }

  @override
  Future<List<ActivityAffinity>> getAffinitiesForState(String targetState) async {
    final logs = await _dao.getAllEffectivenessLogs();
    final allAffinities = PersonalEffectivenessEngine.calculateAffinities(logs);
    final normalized = targetState.toLowerCase().trim();
    return allAffinities.where((a) => a.targetState == normalized).toList();
  }

  @override
  Future<double> getAffinityScore(String activityId, String targetState) async {
    final logs = await _dao.getEffectivenessLogsForActivity(activityId);
    if (logs.isEmpty) return 0.0;
    final affinities = PersonalEffectivenessEngine.calculateAffinities(logs);
    final normalized = targetState.toLowerCase().trim();
    final match = affinities.where((a) => a.targetState == normalized);
    if (match.isEmpty) return 0.0;
    return match.first.affinityScore;
  }

  @override
  Future<void> clearHistory() async {
    await _dao.clearEffectivenessLogs();
  }
}
