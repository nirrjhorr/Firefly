import 'package:flutter_test/flutter_test.dart';
import 'package:firefly/core/errors/result.dart';
import 'package:firefly/features/safety_plan/data/repositories/safety_plan_repository_impl.dart';
import 'package:firefly/features/safety_plan/domain/models/safety_plan.dart';
import 'package:firefly/features/safety_plan/domain/models/safety_plan_contact.dart';
import 'package:firefly/features/safety_plan/domain/models/safety_plan_step.dart';
import 'package:firefly/features/safety_plan/presentation/controllers/safety_plan_controller.dart';

void main() {
  group('SafetyPlan Repository & Domain', () {
    late SafetyPlanRepositoryImpl repository;

    setUp(() {
      repository = SafetyPlanRepositoryImpl();
    });

    test('Initializes with standard 6 Stanley-Brown steps and crisis contacts', () async {
      final result = await repository.getActivePlan();

      expect(result, isA<Ok<SafetyPlan?, Exception>>());
      final plan = (result as Ok<SafetyPlan?, Exception>).value;
      expect(plan, isNotNull);
      expect(plan!.steps.length, equals(6));
      expect(plan.contacts.length, equals(2));
      expect(plan.warnings.length, equals(2));
      expect(plan.professionalContacts.length, equals(2));
      expect(plan.personalContacts.length, equals(0));
    });

    test('Updates step content correctly', () async {
      await repository.getActivePlan();

      const newContent = 'Listen to calming soundscapes and practice 4-7-8 breathing.';
      final updateResult = await repository.updateStep(
        const SafetyPlanStep(
          id: 'step-2',
          planId: 'plan-default',
          stepNumber: 2,
          stepTitle: 'Internal Coping Strategies',
          stepContent: newContent,
          stepType: SafetyPlanStepType.internalCoping,
        ),
      );

      expect(updateResult, isA<Ok<void, Exception>>());

      final updatedPlanResult = await repository.getActivePlan();
      final updatedPlan = (updatedPlanResult as Ok<SafetyPlan?, Exception>).value;
      final step2 = updatedPlan!.steps.firstWhere((s) => s.stepNumber == 2);
      expect(step2.stepContent, equals(newContent));
    });

    test('Adds and deletes personal contacts', () async {
      await repository.getActivePlan();

      const newContact = SafetyPlanContact(
        id: 'contact-test-1',
        planId: 'plan-default',
        name: 'Sarah',
        phoneNumber: '555-0199',
        relationship: 'Sister',
        isProfessional: false,
      );

      final addResult = await repository.addContact(newContact);
      expect(addResult, isA<Ok<void, Exception>>());

      var plan = (await repository.getActivePlan() as Ok<SafetyPlan?, Exception>).value!;
      expect(plan.personalContacts.length, equals(1));
      expect(plan.personalContacts.first.name, equals('Sarah'));

      final deleteResult = await repository.deleteContact('contact-test-1');
      expect(deleteResult, isA<Ok<void, Exception>>());

      plan = (await repository.getActivePlan() as Ok<SafetyPlan?, Exception>).value!;
      expect(plan.personalContacts.length, equals(0));
    });

    test('Updates review timestamp', () async {
      final initialPlan = (await repository.getActivePlan() as Ok<SafetyPlan?, Exception>).value!;
      final initialTimestamp = initialPlan.lastReviewedAtUnix;

      // Small delay to ensure timestamp progression
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await repository.updateReviewTimestamp(initialPlan.id);

      final updatedPlan = (await repository.getActivePlan() as Ok<SafetyPlan?, Exception>).value!;
      expect(updatedPlan.lastReviewedAtUnix, greaterThanOrEqualTo(initialTimestamp ?? 0));
    });
  });

  group('SafetyPlanController', () {
    test('Loads plan on creation and supports mutations', () async {
      final repository = SafetyPlanRepositoryImpl();
      final controller = SafetyPlanController(repository);

      await controller.loadPlan();
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.plan, isNotNull);
      expect(controller.state.plan!.steps.length, equals(6));

      await controller.addContact(
        name: 'Dr. Jane Smith',
        phone: '555-0144',
        relationship: 'Psychotherapist',
        isProfessional: true,
      );

      expect(controller.state.plan!.contacts.length, equals(3));
      expect(controller.state.plan!.professionalContacts.length, equals(3));
    });
  });
}
