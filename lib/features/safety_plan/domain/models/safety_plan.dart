import 'package:flutter/foundation.dart';
import 'safety_plan_contact.dart';
import 'safety_plan_step.dart';
import 'safety_plan_warning.dart';

@immutable
class SafetyPlan {
  const SafetyPlan({
    required this.id,
    this.version = 1,
    this.isActive = true,
    required this.createdAtUnix,
    this.lastReviewedAtUnix,
    this.warnings = const [],
    this.steps = const [],
    this.contacts = const [],
  });

  final String id;
  final int version;
  final bool isActive;
  final int createdAtUnix;
  final int? lastReviewedAtUnix;
  final List<SafetyPlanWarning> warnings;
  final List<SafetyPlanStep> steps;
  final List<SafetyPlanContact> contacts;

  List<SafetyPlanContact> get personalContacts =>
      contacts.where((c) => !c.isProfessional).toList();

  List<SafetyPlanContact> get professionalContacts =>
      contacts.where((c) => c.isProfessional).toList();

  SafetyPlan copyWith({
    String? id,
    int? version,
    bool? isActive,
    int? createdAtUnix,
    int? lastReviewedAtUnix,
    List<SafetyPlanWarning>? warnings,
    List<SafetyPlanStep>? steps,
    List<SafetyPlanContact>? contacts,
  }) {
    return SafetyPlan(
      id: id ?? this.id,
      version: version ?? this.version,
      isActive: isActive ?? this.isActive,
      createdAtUnix: createdAtUnix ?? this.createdAtUnix,
      lastReviewedAtUnix: lastReviewedAtUnix ?? this.lastReviewedAtUnix,
      warnings: warnings ?? this.warnings,
      steps: steps ?? this.steps,
      contacts: contacts ?? this.contacts,
    );
  }
}
