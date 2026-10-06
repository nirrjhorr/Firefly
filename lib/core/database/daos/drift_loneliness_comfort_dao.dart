import 'package:drift/drift.dart';

import '../../../features/loneliness_comfort/domain/models/reach_out_contact.dart';
import '../../../features/loneliness_comfort/domain/models/social_prediction_experiment.dart';
import '../app_database.dart';
import 'loneliness_comfort_dao.dart';

/// Drift SQL database implementation of [LonelinessComfortDao] targeting the encrypted SQLCipher DB.
class DriftLonelinessComfortDao implements LonelinessComfortDao {
  DriftLonelinessComfortDao(this._db);

  final AppDatabase _db;
  bool _psychoeducationDismissed = false;

  @override
  Future<List<ReachOutContact>> getCustomContacts() async {
    final rows = await _db.customSelect(
      'SELECT * FROM reach_out_contacts_table ORDER BY display_order ASC, created_at_unix ASC',
    ).get();

    return rows.map((r) => _mapRowToContact(r.data)).toList();
  }

  @override
  Future<void> saveCustomContact(ReachOutContact contact) async {
    await _db.customInsert(
      'INSERT OR REPLACE INTO reach_out_contacts_table '
      '(id, name, phone_number, relationship, is_safety_plan_contact, display_order, created_at_unix) '
      'VALUES (?, ?, ?, ?, ?, ?, ?)',
      variables: [
        Variable.withString(contact.id),
        Variable.withString(contact.name),
        Variable.withString(contact.phoneNumber ?? ''),
        Variable.withString(contact.relationship),
        Variable.withBool(contact.isSafetyPlanContact),
        Variable.withInt(contact.displayOrder),
        Variable.withInt(contact.createdAtUnix),
      ],
    );
  }

  @override
  Future<void> deleteCustomContact(String id) async {
    await _db.customUpdate(
      'DELETE FROM reach_out_contacts_table WHERE id = ?',
      variables: [Variable<String>(id)],
    );
  }

  @override
  Future<List<SocialPredictionExperiment>> getExperiments() async {
    final rows = await _db.customSelect(
      'SELECT * FROM social_prediction_experiments_table ORDER BY predicted_at_unix DESC',
    ).get();

    return rows.map((r) => _mapRowToExperiment(r.data)).toList();
  }

  @override
  Stream<List<SocialPredictionExperiment>> watchExperiments() {
    return _db.customSelect(
      'SELECT * FROM social_prediction_experiments_table ORDER BY predicted_at_unix DESC',
    ).watch().map((rows) => rows.map((r) => _mapRowToExperiment(r.data)).toList());
  }

  @override
  Future<void> saveExperiment(SocialPredictionExperiment experiment) async {
    await _db.customInsert(
      'INSERT OR REPLACE INTO social_prediction_experiments_table '
      '(id, contact_id, contact_name, predicted_outcome, predicted_at_unix, actual_outcome, completed_at_unix, message_snippet) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      variables: [
        Variable.withString(experiment.id),
        Variable.withString(experiment.contactId),
        Variable.withString(experiment.contactName),
        Variable.withString(experiment.predictedOutcome.name),
        Variable.withInt(experiment.predictedAtUnix),
        Variable.withString(experiment.actualOutcome?.name ?? ''),
        Variable.withInt(experiment.completedAtUnix ?? 0),
        Variable.withString(experiment.messageSnippet ?? ''),
      ],
    );
  }

  @override
  Future<void> updateExperimentOutcome(
    String experimentId,
    SocialOutcome actualOutcome,
  ) async {
    final completedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _db.customUpdate(
      'UPDATE social_prediction_experiments_table SET actual_outcome = ?, completed_at_unix = ? WHERE id = ?',
      variables: [
        Variable.withString(actualOutcome.name),
        Variable.withInt(completedAt),
        Variable.withString(experimentId),
      ],
    );
  }

  @override
  Future<SocialExperimentSummary> getExperimentSummary() async {
    final experiments = await getExperiments();
    return SocialExperimentSummary.fromExperiments(experiments);
  }

  @override
  Future<bool> isPsychoeducationDismissed() async {
    return _psychoeducationDismissed;
  }

  @override
  Future<void> setPsychoeducationDismissed(bool dismissed) async {
    _psychoeducationDismissed = dismissed;
  }

  ReachOutContact _mapRowToContact(Map<String, dynamic> data) {
    final phone = data['phone_number'] as String?;
    return ReachOutContact(
      id: data['id'] as String,
      name: data['name'] as String,
      phoneNumber: (phone != null && phone.isNotEmpty) ? phone : null,
      relationship: (data['relationship'] as String?) ?? '',
      isSafetyPlanContact:
          data['is_safety_plan_contact'] == 1 || data['is_safety_plan_contact'] == true,
      displayOrder: (data['display_order'] as int?) ?? 0,
      createdAtUnix: (data['created_at_unix'] as int?) ?? 0,
    );
  }

  SocialPredictionExperiment _mapRowToExperiment(Map<String, dynamic> data) {
    final actualStr = data['actual_outcome'] as String?;
    final snippetStr = data['message_snippet'] as String?;
    final completedAt = data['completed_at_unix'] as int?;

    return SocialPredictionExperiment(
      id: data['id'] as String,
      contactId: data['contact_id'] as String,
      contactName: data['contact_name'] as String,
      predictedOutcome:
          SocialOutcome.values.byName(data['predicted_outcome'] as String),
      predictedAtUnix: data['predicted_at_unix'] as int,
      actualOutcome: (actualStr != null && actualStr.isNotEmpty)
          ? SocialOutcome.values.byName(actualStr)
          : null,
      completedAtUnix: (completedAt != null && completedAt > 0) ? completedAt : null,
      messageSnippet: (snippetStr != null && snippetStr.isNotEmpty) ? snippetStr : null,
    );
  }
}
