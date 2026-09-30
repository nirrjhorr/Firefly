import 'package:flutter/foundation.dart';

@immutable
class SafetyPlanContact {
  const SafetyPlanContact({
    required this.id,
    required this.planId,
    required this.name,
    this.phoneNumber,
    required this.relationship,
    this.displayOrder = 0,
    this.isProfessional = false,
  });

  final String id;
  final String planId;
  final String name;
  final String? phoneNumber;
  final String relationship;
  final int displayOrder;
  final bool isProfessional;

  SafetyPlanContact copyWith({
    String? id,
    String? planId,
    String? name,
    String? phoneNumber,
    String? relationship,
    int? displayOrder,
    bool? isProfessional,
  }) {
    return SafetyPlanContact(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      displayOrder: displayOrder ?? this.displayOrder,
      isProfessional: isProfessional ?? this.isProfessional,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SafetyPlanContact &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          planId == other.planId &&
          name == other.name &&
          phoneNumber == other.phoneNumber &&
          relationship == other.relationship &&
          displayOrder == other.displayOrder &&
          isProfessional == other.isProfessional;

  @override
  int get hashCode =>
      id.hashCode ^
      planId.hashCode ^
      name.hashCode ^
      phoneNumber.hashCode ^
      relationship.hashCode ^
      displayOrder.hashCode ^
      isProfessional.hashCode;
}
