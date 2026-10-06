import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/errors/result.dart';
import '../../../safety_plan/domain/models/safety_plan.dart';
import '../../../safety_plan/domain/repositories/safety_plan_repository.dart';
import '../../data/repositories/loneliness_comfort_repository_impl.dart';
import '../../domain/models/loneliness_comfort_state.dart';
import '../../domain/models/reach_out_contact.dart';
import '../../domain/models/social_prediction_experiment.dart';
import '../../domain/repositories/loneliness_comfort_repository.dart';

/// Provider exposing the repository singleton.
final lonelinessComfortRepositoryProvider =
    Provider<LonelinessComfortRepository>((ref) {
  return LonelinessComfortRepositoryImpl();
});

/// Optional safety plan repository provider for seamless cross-feature contact integration.
final lonelinessSafetyPlanRepositoryProvider =
    Provider<SafetyPlanRepository?>((ref) => null);

/// Provider exposing the state notifier controller.
final lonelinessComfortControllerProvider =
    StateNotifierProvider<LonelinessComfortController, LonelinessComfortState>(
        (ref) {
  final lonelinessRepo = ref.watch(lonelinessComfortRepositoryProvider);
  final safetyPlanRepo = ref.watch(lonelinessSafetyPlanRepositoryProvider);
  return LonelinessComfortController(
    repository: lonelinessRepo,
    safetyPlanRepository: safetyPlanRepo,
  );
});

/// Controller coordinating reach-out contacts, message templates,
/// SMS launching, and the "Guess vs. Reality" experiment loop.
class LonelinessComfortController extends StateNotifier<LonelinessComfortState> {
  LonelinessComfortController({
    required LonelinessComfortRepository repository,
    SafetyPlanRepository? safetyPlanRepository,
  })  : _repository = repository,
        _safetyPlanRepository = safetyPlanRepository,
        super(const LonelinessComfortState(isLoading: true)) {
    loadData();
  }

  final LonelinessComfortRepository _repository;
  final SafetyPlanRepository? _safetyPlanRepository;

  /// Loads contacts, experiments, and dismissal preferences.
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final customContacts = await _repository.getCustomContacts();
      final List<ReachOutContact> combinedContacts = [];

      // 1. Fetch Safety Plan contacts if available
      if (_safetyPlanRepository != null) {
        final planResult = await _safetyPlanRepository!.getActivePlan();
        if (planResult is Ok<SafetyPlan, Exception>) {
          final plan = planResult.value;
          final spContacts = plan.contacts.map((c) => ReachOutContact.fromSafetyPlanContact(c));
          combinedContacts.addAll(spContacts);
        }
      }

      // 2. Append custom loneliness contacts
      combinedContacts.addAll(customContacts);

      // 3. Load experiments
      final experiments = await _repository.getExperiments();
      final summary = SocialExperimentSummary.fromExperiments(experiments);

      // 4. Check for newest incomplete experiment
      SocialPredictionExperiment? pendingExp;
      for (final exp in experiments.reversed) {
        if (!exp.isCompleted) {
          pendingExp = exp;
          break;
        }
      }

      final isDismissed = await _repository.isPsychoeducationDismissed();

      state = state.copyWith(
        isLoading: false,
        contacts: combinedContacts,
        experiments: experiments,
        activePendingExperiment: pendingExp,
        summary: summary,
        isPsychoeducationDismissed: isDismissed,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load loneliness comfort data: $e',
      );
    }
  }

  /// Selects one of the pre-written research templates.
  void selectTemplate(int index) {
    if (index >= 0 && index < kDefaultReachOutTemplates.length) {
      state = state.copyWith(
        selectedTemplateIndex: index,
        customMessageText: kDefaultReachOutTemplates[index],
      );
    }
  }

  /// Updates custom message draft.
  void setCustomMessage(String text) {
    state = state.copyWith(
      selectedTemplateIndex: -1,
      customMessageText: text,
    );
  }

  /// Dismisses the Kumar & Epley psychoeducation callout.
  Future<void> dismissPsychoeducation() async {
    await _repository.setPsychoeducationDismissed(true);
    state = state.copyWith(isPsychoeducationDismissed: true);
  }

  /// Adds a custom contact for loneliness reaching out.
  Future<void> addCustomContact({
    required String name,
    String? phoneNumber,
    String relationship = '',
  }) async {
    final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final newContact = ReachOutContact(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      phoneNumber: phoneNumber?.trim(),
      relationship: relationship.trim(),
      isSafetyPlanContact: false,
      displayOrder: state.contacts.length,
      createdAtUnix: nowUnix,
    );

    await _repository.saveCustomContact(newContact);
    final updatedContacts = [...state.contacts, newContact];
    state = state.copyWith(contacts: updatedContacts);
  }

  /// Deletes a custom contact by ID.
  Future<void> deleteCustomContact(String id) async {
    await _repository.deleteCustomContact(id);
    final updatedContacts = state.contacts.where((c) => c.id != id).toList();
    state = state.copyWith(contacts: updatedContacts);
  }

  /// Logs a prediction and initiates a new "Guess vs. Reality" experiment before sending SMS.
  Future<SocialPredictionExperiment> startPredictionExperiment({
    required ReachOutContact contact,
    required SocialOutcome predictedOutcome,
    required String message,
  }) async {
    final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final experiment = SocialPredictionExperiment(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      contactId: contact.id,
      contactName: contact.name,
      predictedOutcome: predictedOutcome,
      predictedAtUnix: nowUnix,
      messageSnippet: message.length > 80 ? '${message.substring(0, 77)}...' : message,
    );

    await _repository.saveExperiment(experiment);
    final updatedExperiments = [...state.experiments, experiment];
    final updatedSummary = SocialExperimentSummary.fromExperiments(updatedExperiments);

    state = state.copyWith(
      experiments: updatedExperiments,
      activePendingExperiment: experiment,
      summary: updatedSummary,
      clearFeedbackMessage: true,
    );

    return experiment;
  }

  /// Records what actually happened for a pending experiment.
  Future<void> recordExperimentOutcome({
    required String experimentId,
    required SocialOutcome actualOutcome,
  }) async {
    await _repository.updateExperimentOutcome(experimentId, actualOutcome);

    final updatedExperiments = state.experiments.map((e) {
      if (e.id == experimentId) {
        return e.copyWith(
          actualOutcome: actualOutcome,
          completedAtUnix: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        );
      }
      return e;
    }).toList();

    final updatedSummary = SocialExperimentSummary.fromExperiments(updatedExperiments);

    state = state.copyWith(
      experiments: updatedExperiments,
      clearPendingExperiment: state.activePendingExperiment?.id == experimentId,
      summary: updatedSummary,
      lastFeedbackMessage: actualOutcome.validationFeedback,
    );
  }

  /// Helper to build an offline `sms:` Intent URI.
  static Uri buildSmsUri({required String phoneNumber, required String message}) {
    final trimmedPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    return Uri(
      scheme: 'sms',
      path: trimmedPhone,
      queryParameters: message.isNotEmpty ? {'body': message} : null,
    );
  }

  /// Launches native SMS application with pre-populated message.
  Future<bool> launchSms({
    required String phoneNumber,
    required String message,
    Future<bool> Function(Uri)? urlLauncherOverride,
  }) async {
    final uri = buildSmsUri(phoneNumber: phoneNumber, message: message);
    try {
      if (urlLauncherOverride != null) {
        return await urlLauncherOverride(uri);
      }
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Clears the feedback message banner.
  void clearFeedback() {
    state = state.copyWith(clearFeedbackMessage: true);
  }
}
