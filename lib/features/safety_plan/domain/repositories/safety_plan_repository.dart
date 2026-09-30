import '../../../../core/errors/result.dart';
import '../models/safety_plan.dart';
import '../models/safety_plan_contact.dart';
import '../models/safety_plan_step.dart';
import '../models/safety_plan_warning.dart';

abstract class SafetyPlanRepository {
  Future<Result<SafetyPlan?, Exception>> getActivePlan();
  Future<Result<SafetyPlan, Exception>> createOrInitializePlan();
  Future<Result<void, Exception>> savePlan(SafetyPlan plan);
  Future<Result<void, Exception>> updateStep(SafetyPlanStep step);
  Future<Result<void, Exception>> addContact(SafetyPlanContact contact);
  Future<Result<void, Exception>> updateContact(SafetyPlanContact contact);
  Future<Result<void, Exception>> deleteContact(String contactId);
  Future<Result<void, Exception>> addWarning(SafetyPlanWarning warning);
  Future<Result<void, Exception>> deleteWarning(String warningId);
  Future<Result<void, Exception>> updateReviewTimestamp(String planId);
  Future<Result<void, Exception>> deletePlan(String planId);
}
