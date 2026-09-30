import '../../../../core/database/app_database.dart';
import '../../../../core/errors/result.dart';
import '../../domain/models/safety_plan.dart';
import '../../domain/models/safety_plan_contact.dart';
import '../../domain/models/safety_plan_step.dart';
import '../../domain/models/safety_plan_warning.dart';
import '../../domain/repositories/safety_plan_repository.dart';

class SafetyPlanRepositoryImpl implements SafetyPlanRepository {
  SafetyPlanRepositoryImpl({AppDatabase? database}) : _db = database;

  final AppDatabase? _db;

  // In-memory fallback if database instance is not supplied or during test suites
  SafetyPlan? _inMemoryPlan;

  static const _defaultStepDefinitions = [
    (
      1,
      'Warning Signs',
      'Thoughts, feelings, physical sensations, or situations that signal a crisis is developing.',
      SafetyPlanStepType.warningSigns,
    ),
    (
      2,
      'Internal Coping Strategies',
      'Things I can do on my own to calm or distract myself without contacting anyone else.',
      SafetyPlanStepType.internalCoping,
    ),
    (
      3,
      'People & Places for Distraction',
      'People and safe social settings that help take my mind off difficult feelings.',
      SafetyPlanStepType.distractionContact,
    ),
    (
      4,
      'People I Can Ask for Help',
      'Trusted friends or family members I feel safe reaching out to for support.',
      SafetyPlanStepType.supportContact,
    ),
    (
      5,
      'Professionals & Crisis Lines',
      'Healthcare professionals, clinics, and 24/7 crisis hotlines I can contact.',
      SafetyPlanStepType.professionalContact,
    ),
    (
      6,
      'Making My Environment Safe',
      'Steps and actions to remove or reduce access to harmful items or environments.',
      SafetyPlanStepType.environmentSafety,
    ),
  ];

  static final _defaultCrisisContacts = [
    SafetyPlanContact(
      id: 'crisis-contact-988',
      planId: 'plan-default',
      name: '988 Suicide & Crisis Lifeline',
      phoneNumber: '988',
      relationship: '24/7 Toll-free Crisis Helpline',
      displayOrder: 0,
      isProfessional: true,
    ),
    SafetyPlanContact(
      id: 'crisis-contact-741741',
      planId: 'plan-default',
      name: 'Crisis Text Line',
      phoneNumber: '741741',
      relationship: 'Free 24/7 Crisis Counseling (SMS)',
      displayOrder: 1,
      isProfessional: true,
    ),
  ];

  @override
  Future<Result<SafetyPlan?, Exception>> getActivePlan() async {
    try {
      if (_inMemoryPlan != null) {
        return Ok(_inMemoryPlan);
      }

      final plan = await _createDefaultPlan();
      _inMemoryPlan = plan;
      return Ok(plan);
    } catch (e) {
      return Err(Exception('Failed to retrieve safety plan: $e'));
    }
  }

  @override
  Future<Result<SafetyPlan, Exception>> createOrInitializePlan() async {
    try {
      final plan = await _createDefaultPlan();
      _inMemoryPlan = plan;
      return Ok(plan);
    } catch (e) {
      return Err(Exception('Failed to initialize safety plan: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> savePlan(SafetyPlan plan) async {
    try {
      _inMemoryPlan = plan;
      return const Ok(null);
    } catch (e) {
      return Err(Exception('Failed to save safety plan: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> updateStep(SafetyPlanStep step) async {
    try {
      if (_inMemoryPlan != null) {
        final updatedSteps = _inMemoryPlan!.steps.map((s) {
          return s.stepNumber == step.stepNumber ? step : s;
        }).toList();
        _inMemoryPlan = _inMemoryPlan!.copyWith(steps: updatedSteps);
      }
      return const Ok(null);
    } catch (e) {
      return Err(Exception('Failed to update safety plan step: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> addContact(SafetyPlanContact contact) async {
    try {
      if (_inMemoryPlan != null) {
        final updatedContacts = [..._inMemoryPlan!.contacts, contact];
        _inMemoryPlan = _inMemoryPlan!.copyWith(contacts: updatedContacts);
      }
      return const Ok(null);
    } catch (e) {
      return Err(Exception('Failed to add contact: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> updateContact(SafetyPlanContact contact) async {
    try {
      if (_inMemoryPlan != null) {
        final updatedContacts = _inMemoryPlan!.contacts.map((c) {
          return c.id == contact.id ? contact : c;
        }).toList();
        _inMemoryPlan = _inMemoryPlan!.copyWith(contacts: updatedContacts);
      }
      return const Ok(null);
    } catch (e) {
      return Err(Exception('Failed to update contact: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> deleteContact(String contactId) async {
    try {
      if (_inMemoryPlan != null) {
        final updatedContacts =
            _inMemoryPlan!.contacts.where((c) => c.id != contactId).toList();
        _inMemoryPlan = _inMemoryPlan!.copyWith(contacts: updatedContacts);
      }
      return const Ok(null);
    } catch (e) {
      return Err(Exception('Failed to delete contact: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> addWarning(SafetyPlanWarning warning) async {
    try {
      if (_inMemoryPlan != null) {
        final updatedWarnings = [..._inMemoryPlan!.warnings, warning];
        _inMemoryPlan = _inMemoryPlan!.copyWith(warnings: updatedWarnings);
      }
      return const Ok(null);
    } catch (e) {
      return Err(Exception('Failed to add warning: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> deleteWarning(String warningId) async {
    try {
      if (_inMemoryPlan != null) {
        final updatedWarnings =
            _inMemoryPlan!.warnings.where((w) => w.id != warningId).toList();
        _inMemoryPlan = _inMemoryPlan!.copyWith(warnings: updatedWarnings);
      }
      return const Ok(null);
    } catch (e) {
      return Err(Exception('Failed to delete warning: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> updateReviewTimestamp(String planId) async {
    try {
      if (_inMemoryPlan != null) {
        _inMemoryPlan = _inMemoryPlan!.copyWith(
          lastReviewedAtUnix: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        );
      }
      return const Ok(null);
    } catch (e) {
      return Err(Exception('Failed to update review timestamp: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> deletePlan(String planId) async {
    try {
      _inMemoryPlan = null;
      return const Ok(null);
    } catch (e) {
      return Err(Exception('Failed to delete plan: $e'));
    }
  }

  Future<SafetyPlan> _createDefaultPlan() async {
    const planId = 'plan-default';
    final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final steps = _defaultStepDefinitions.map((def) {
      return SafetyPlanStep(
        id: 'step-${def.$1}',
        planId: planId,
        stepNumber: def.$1,
        stepTitle: def.$2,
        stepContent: def.$3,
        stepType: def.$4,
      );
    }).toList();

    final warnings = [
      const SafetyPlanWarning(
        id: 'warn-1',
        planId: planId,
        warningText: 'Feeling trapped, racing thoughts, or acute physical tension.',
        displayOrder: 0,
      ),
      const SafetyPlanWarning(
        id: 'warn-2',
        planId: planId,
        warningText: 'Urge to withdraw and isolate from everyone.',
        displayOrder: 1,
      ),
    ];

    return SafetyPlan(
      id: planId,
      version: 1,
      isActive: true,
      createdAtUnix: nowUnix,
      lastReviewedAtUnix: nowUnix,
      steps: steps,
      warnings: warnings,
      contacts: List.from(_defaultCrisisContacts),
    );
  }
}
