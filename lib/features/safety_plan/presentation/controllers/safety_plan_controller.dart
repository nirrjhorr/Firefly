import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/result.dart';
import '../../data/repositories/safety_plan_repository_impl.dart';
import '../../data/services/crisis_support_storage_service.dart';
import '../../domain/models/crisis_support_config.dart';
import '../../domain/models/safety_plan.dart';
import '../../domain/models/safety_plan_contact.dart';
import '../../domain/models/safety_plan_step.dart';
import '../../domain/models/safety_plan_warning.dart';
import '../../domain/repositories/safety_plan_repository.dart';

final safetyPlanRepositoryProvider = Provider<SafetyPlanRepository>((ref) {
  return SafetyPlanRepositoryImpl();
});

class SafetyPlanState {
  const SafetyPlanState({
    required this.isLoading,
    this.plan,
    this.crisisConfig,
    this.errorMessage,
  });

  final bool isLoading;
  final SafetyPlan? plan;
  final CrisisSupportConfig? crisisConfig;
  final String? errorMessage;

  SafetyPlanState copyWith({
    bool? isLoading,
    SafetyPlan? plan,
    CrisisSupportConfig? crisisConfig,
    String? errorMessage,
  }) {
    return SafetyPlanState(
      isLoading: isLoading ?? this.isLoading,
      plan: plan ?? this.plan,
      crisisConfig: crisisConfig ?? this.crisisConfig,
      errorMessage: errorMessage,
    );
  }
}

class SafetyPlanController extends StateNotifier<SafetyPlanState> {
  SafetyPlanController(
    this._repository, {
    CrisisSupportStorageService? storageService,
  })  : _storageService = storageService ?? CrisisSupportStorageService(),
        super(const SafetyPlanState(isLoading: true)) {
    loadPlan();
  }

  final SafetyPlanRepository _repository;
  final CrisisSupportStorageService _storageService;

  Future<void> loadPlan() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final crisisConfig = await _storageService.loadConfig();
    final result = await _repository.getActivePlan();
    switch (result) {
      case Ok(value: final plan):
        state = state.copyWith(
          isLoading: false,
          plan: plan,
          crisisConfig: crisisConfig,
        );
      case Err(error: final err):
        state = state.copyWith(
          isLoading: false,
          crisisConfig: crisisConfig,
          errorMessage: err.toString(),
        );
    }
  }

  Future<void> updateCrisisConfig(CrisisSupportConfig config) async {
    await _storageService.saveConfig(config);
    state = state.copyWith(crisisConfig: config);
  }

  Future<void> useDefaultCrisisHelplines() async {
    await updateCrisisConfig(CrisisSupportConfig.defaultHelplines);
  }

  Future<void> clearCrisisConfig() async {
    await _storageService.clearConfig();
    state = state.copyWith(
      crisisConfig: const CrisisSupportConfig(),
    );
  }

  Future<void> updateStepContent(int stepNumber, String content) async {
    final currentPlan = state.plan;
    if (currentPlan == null) return;

    final targetStep = currentPlan.steps.firstWhere(
      (s) => s.stepNumber == stepNumber,
      orElse: () => SafetyPlanStep(
        id: 'step-$stepNumber',
        planId: currentPlan.id,
        stepNumber: stepNumber,
        stepTitle: 'Step $stepNumber',
        stepContent: content,
        stepType: SafetyPlanStepType.internalCoping,
      ),
    );

    final updatedStep = targetStep.copyWith(stepContent: content);
    final result = await _repository.updateStep(updatedStep);
    if (result is Ok) {
      final updatedSteps = currentPlan.steps.map((s) {
        return s.stepNumber == stepNumber ? updatedStep : s;
      }).toList();
      state = state.copyWith(
        plan: currentPlan.copyWith(steps: updatedSteps),
      );
    }
  }

  Future<void> addContact({
    required String name,
    String? phone,
    required String relationship,
    bool isProfessional = false,
  }) async {
    final currentPlan = state.plan;
    if (currentPlan == null) return;

    final newContact = SafetyPlanContact(
      id: 'contact-${DateTime.now().millisecondsSinceEpoch}',
      planId: currentPlan.id,
      name: name,
      phoneNumber: phone,
      relationship: relationship,
      displayOrder: currentPlan.contacts.length,
      isProfessional: isProfessional,
    );

    final result = await _repository.addContact(newContact);
    if (result is Ok) {
      state = state.copyWith(
        plan: currentPlan.copyWith(
          contacts: [...currentPlan.contacts, newContact],
        ),
      );
    }
  }

  Future<void> removeContact(String id) async {
    final currentPlan = state.plan;
    if (currentPlan == null) return;

    final result = await _repository.deleteContact(id);
    if (result is Ok) {
      state = state.copyWith(
        plan: currentPlan.copyWith(
          contacts: currentPlan.contacts.where((c) => c.id != id).toList(),
        ),
      );
    }
  }

  Future<void> addWarningSign(String warningText) async {
    final currentPlan = state.plan;
    if (currentPlan == null) return;

    final newWarning = SafetyPlanWarning(
      id: 'warn-${DateTime.now().millisecondsSinceEpoch}',
      planId: currentPlan.id,
      warningText: warningText,
      displayOrder: currentPlan.warnings.length,
    );

    final result = await _repository.addWarning(newWarning);
    if (result is Ok) {
      state = state.copyWith(
        plan: currentPlan.copyWith(
          warnings: [...currentPlan.warnings, newWarning],
        ),
      );
    }
  }

  Future<void> removeWarningSign(String id) async {
    final currentPlan = state.plan;
    if (currentPlan == null) return;

    final result = await _repository.deleteWarning(id);
    if (result is Ok) {
      state = state.copyWith(
        plan: currentPlan.copyWith(
          warnings: currentPlan.warnings.where((w) => w.id != id).toList(),
        ),
      );
    }
  }

  Future<void> recordReview() async {
    final currentPlan = state.plan;
    if (currentPlan == null) return;

    final result = await _repository.updateReviewTimestamp(currentPlan.id);
    if (result is Ok) {
      state = state.copyWith(
        plan: currentPlan.copyWith(
          lastReviewedAtUnix: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        ),
      );
    }
  }
}

final safetyPlanControllerProvider =
    StateNotifierProvider<SafetyPlanController, SafetyPlanState>((ref) {
  final repository = ref.watch(safetyPlanRepositoryProvider);
  final storageService = ref.watch(crisisSupportStorageServiceProvider);
  return SafetyPlanController(repository, storageService: storageService);
});
