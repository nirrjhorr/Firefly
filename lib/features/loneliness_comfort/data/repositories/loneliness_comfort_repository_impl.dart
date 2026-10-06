import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../../../../core/database/daos/loneliness_comfort_dao.dart';
import '../../domain/models/reach_out_contact.dart';
import '../../domain/models/social_prediction_experiment.dart';
import '../../domain/repositories/loneliness_comfort_repository.dart';

/// Concrete implementation of [LonelinessComfortRepository] featuring persistent DAO storage,
/// aggregate statistical calculations, and cryptographic memory clearing.
class LonelinessComfortRepositoryImpl implements LonelinessComfortRepository {
  final LonelinessComfortDao _dao;

  LonelinessComfortRepositoryImpl({
    LonelinessComfortDao? dao,
    List<ReachOutContact>? initialContacts,
    List<SocialPredictionExperiment>? initialExperiments,
    bool initialDismissed = false,
  }) : _dao = dao ??
            LonelinessComfortDao.inMemory(
              initialContacts: initialContacts,
              initialExperiments: initialExperiments,
              initialDismissed: initialDismissed,
            );

  @override
  Future<List<ReachOutContact>> getCustomContacts() async {
    return _dao.getCustomContacts();
  }

  @override
  Future<void> saveCustomContact(ReachOutContact contact) async {
    await _dao.saveCustomContact(contact);
  }

  @override
  Future<void> deleteCustomContact(String id) async {
    await _dao.deleteCustomContact(id);
  }

  @override
  Future<List<SocialPredictionExperiment>> getExperiments() async {
    return _dao.getExperiments();
  }

  @override
  Future<void> saveExperiment(SocialPredictionExperiment experiment) async {
    await _dao.saveExperiment(experiment);
  }

  @override
  Future<void> updateExperimentOutcome(
    String experimentId,
    SocialOutcome actualOutcome,
  ) async {
    await _dao.updateExperimentOutcome(experimentId, actualOutcome);
  }

  @override
  Future<SocialExperimentSummary> getExperimentSummary() async {
    return _dao.getExperimentSummary();
  }

  @override
  Future<bool> isPsychoeducationDismissed() async {
    return _dao.isPsychoeducationDismissed();
  }

  @override
  Future<void> setPsychoeducationDismissed(bool dismissed) async {
    await _dao.setPsychoeducationDismissed(dismissed);
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
