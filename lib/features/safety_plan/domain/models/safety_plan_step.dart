import 'package:flutter/foundation.dart';

enum SafetyPlanStepType {
  warningSigns,
  internalCoping,
  distractionContact,
  supportContact,
  professionalContact,
  environmentSafety;

  static SafetyPlanStepType fromString(String value) {
    return SafetyPlanStepType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SafetyPlanStepType.internalCoping,
    );
  }
}

@immutable
class SafetyPlanStep {
  const SafetyPlanStep({
    required this.id,
    required this.planId,
    required this.stepNumber,
    required this.stepTitle,
    required this.stepContent,
    required this.stepType,
  });

  final String id;
  final String planId;
  final int stepNumber;
  final String stepTitle;
  final String stepContent;
  final SafetyPlanStepType stepType;

  SafetyPlanStep copyWith({
    String? id,
    String? planId,
    int? stepNumber,
    String? stepTitle,
    String? stepContent,
    SafetyPlanStepType? stepType,
  }) {
    return SafetyPlanStep(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      stepNumber: stepNumber ?? this.stepNumber,
      stepTitle: stepTitle ?? this.stepTitle,
      stepContent: stepContent ?? this.stepContent,
      stepType: stepType ?? this.stepType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SafetyPlanStep &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          planId == other.planId &&
          stepNumber == other.stepNumber &&
          stepTitle == other.stepTitle &&
          stepContent == other.stepContent &&
          stepType == other.stepType;

  @override
  int get hashCode =>
      id.hashCode ^
      planId.hashCode ^
      stepNumber.hashCode ^
      stepTitle.hashCode ^
      stepContent.hashCode ^
      stepType.hashCode;
}
