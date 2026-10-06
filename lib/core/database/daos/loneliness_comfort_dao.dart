import 'dart:async';

import '../../../features/loneliness_comfort/domain/models/reach_out_contact.dart';
import '../../../features/loneliness_comfort/domain/models/social_prediction_experiment.dart';

/// Data Access Object contract for Loneliness Comfort & "Guess vs. Reality" data.
///
/// Decoupled from native platform database libraries for seamless testing and persistence.
abstract class LonelinessComfortDao {
  Future<List<ReachOutContact>> getCustomContacts();
  Future<void> saveCustomContact(ReachOutContact contact);
  Future<void> deleteCustomContact(String id);

  Future<List<SocialPredictionExperiment>> getExperiments();
  Stream<List<SocialPredictionExperiment>> watchExperiments();
  Future<void> saveExperiment(SocialPredictionExperiment experiment);
  Future<void> updateExperimentOutcome(
    String experimentId,
    SocialOutcome actualOutcome,
  );
  Future<SocialExperimentSummary> getExperimentSummary();

  Future<bool> isPsychoeducationDismissed();
  Future<void> setPsychoeducationDismissed(bool dismissed);

  factory LonelinessComfortDao.inMemory({
    List<ReachOutContact>? initialContacts,
    List<SocialPredictionExperiment>? initialExperiments,
    bool initialDismissed = false,
  }) =>
      InMemoryLonelinessComfortDao(
        initialContacts: initialContacts,
        initialExperiments: initialExperiments,
        initialDismissed: initialDismissed,
      );
}

/// In-memory implementation of [LonelinessComfortDao] for fast tests and ephemeral sessions.
class InMemoryLonelinessComfortDao implements LonelinessComfortDao {
  InMemoryLonelinessComfortDao({
    List<ReachOutContact>? initialContacts,
    List<SocialPredictionExperiment>? initialExperiments,
    bool initialDismissed = false,
  })  : _customContacts = List.from(initialContacts ?? []),
        _experiments = List.from(initialExperiments ?? []),
        _psychoeducationDismissed = initialDismissed {
    _experimentsStreamController =
        StreamController<List<SocialPredictionExperiment>>.broadcast();
  }

  final List<ReachOutContact> _customContacts;
  final List<SocialPredictionExperiment> _experiments;
  bool _psychoeducationDismissed;
  late final StreamController<List<SocialPredictionExperiment>>
      _experimentsStreamController;

  void _notifyExperiments() {
    _experimentsStreamController.add(List.unmodifiable(_experiments));
  }

  @override
  Future<List<ReachOutContact>> getCustomContacts() async {
    return List.unmodifiable(_customContacts);
  }

  @override
  Future<void> saveCustomContact(ReachOutContact contact) async {
    final index = _customContacts.indexWhere((c) => c.id == contact.id);
    if (index >= 0) {
      _customContacts[index] = contact;
    } else {
      _customContacts.add(contact);
    }
  }

  @override
  Future<void> deleteCustomContact(String id) async {
    _customContacts.removeWhere((c) => c.id == id);
  }

  @override
  Future<List<SocialPredictionExperiment>> getExperiments() async {
    return List.unmodifiable(_experiments);
  }

  @override
  Stream<List<SocialPredictionExperiment>> watchExperiments() {
    return _experimentsStreamController.stream;
  }

  @override
  Future<void> saveExperiment(SocialPredictionExperiment experiment) async {
    final index = _experiments.indexWhere((e) => e.id == experiment.id);
    if (index >= 0) {
      _experiments[index] = experiment;
    } else {
      _experiments.add(experiment);
    }
    _notifyExperiments();
  }

  @override
  Future<void> updateExperimentOutcome(
    String experimentId,
    SocialOutcome actualOutcome,
  ) async {
    final index = _experiments.indexWhere((e) => e.id == experimentId);
    if (index >= 0) {
      final existing = _experiments[index];
      _experiments[index] = existing.copyWith(
        actualOutcome: actualOutcome,
        completedAtUnix: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );
      _notifyExperiments();
    }
  }

  @override
  Future<SocialExperimentSummary> getExperimentSummary() async {
    return SocialExperimentSummary.fromExperiments(_experiments);
  }

  @override
  Future<bool> isPsychoeducationDismissed() async {
    return _psychoeducationDismissed;
  }

  @override
  Future<void> setPsychoeducationDismissed(bool dismissed) async {
    _psychoeducationDismissed = dismissed;
  }

  void dispose() {
    _experimentsStreamController.close();
  }
}
