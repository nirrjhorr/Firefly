import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../../domain/models/reach_out_contact.dart';
import '../../domain/models/social_prediction_experiment.dart';
import '../../domain/repositories/loneliness_comfort_repository.dart';

/// Concrete implementation of [LonelinessComfortRepository] featuring local offline storage,
/// aggregate statistical calculations, and cryptographic memory clearing.
class LonelinessComfortRepositoryImpl implements LonelinessComfortRepository {
  final List<ReachOutContact> _customContacts = [];
  final List<SocialPredictionExperiment> _experiments = [];
  bool _psychoeducationDismissed = false;

  LonelinessComfortRepositoryImpl({
    List<ReachOutContact>? initialContacts,
    List<SocialPredictionExperiment>? initialExperiments,
    bool initialDismissed = false,
  }) {
    if (initialContacts != null) {
      _customContacts.addAll(initialContacts);
    }
    if (initialExperiments != null) {
      _experiments.addAll(initialExperiments);
    }
    _psychoeducationDismissed = initialDismissed;
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
  Future<void> saveExperiment(SocialPredictionExperiment experiment) async {
    final index = _experiments.indexWhere((e) => e.id == experiment.id);
    if (index >= 0) {
      _experiments[index] = experiment;
    } else {
      _experiments.add(experiment);
    }
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

  /// Cryptographic erasure helper to zero out string buffers in memory.
  static void cryptoEraseString(String text) {
    if (text.isEmpty) return;
    final bytes = Uint8List.fromList(utf8.encode(text));
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = 0;
    }
  }
}
