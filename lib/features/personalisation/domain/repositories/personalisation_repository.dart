import '../models/activity_affinity.dart';
import '../models/personal_regulation_profile.dart';

/// Repository interface for personal regulation profiles and affinity queries.
abstract class PersonalisationRepository {
  /// Loads all effectiveness logs and builds the personal regulation profile.
  Future<PersonalRegulationProfile> getProfile();

  /// Retrieves affinities filtered for a specific target affect/state.
  Future<List<ActivityAffinity>> getAffinitiesForState(String targetState);

  /// Computes affinity score for a specific activity under a given state.
  Future<double> getAffinityScore(String activityId, String targetState);

  /// Clears all stored effectiveness logs, resetting the on-device model.
  Future<void> clearHistory();
}
