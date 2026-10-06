import '../models/reach_out_contact.dart';
import '../models/social_prediction_experiment.dart';

/// Contract for persistent storage of reach-out contacts,
/// "Guess vs. Reality" prediction experiments, and psychoeducation visibility.
abstract class LonelinessComfortRepository {
  /// Fetches user-defined custom reaching-out contacts.
  Future<List<ReachOutContact>> getCustomContacts();

  /// Saves or updates a custom reaching-out contact.
  Future<void> saveCustomContact(ReachOutContact contact);

  /// Deletes a custom reaching-out contact by ID.
  Future<void> deleteCustomContact(String id);

  /// Retrieves all logged prediction experiments in chronological order.
  Future<List<SocialPredictionExperiment>> getExperiments();

  /// Saves a newly initiated prediction experiment.
  Future<void> saveExperiment(SocialPredictionExperiment experiment);

  /// Records the real-world outcome for a pending experiment.
  Future<void> updateExperimentOutcome(String experimentId, SocialOutcome actualOutcome);

  /// Calculates aggregate statistics across all completed experiments.
  Future<SocialExperimentSummary> getExperimentSummary();

  /// Checks whether the user has dismissed the Kumar & Epley psychoeducation callout.
  Future<bool> isPsychoeducationDismissed();

  /// Sets the dismissal preference for the psychoeducation callout.
  Future<void> setPsychoeducationDismissed(bool dismissed);
}
