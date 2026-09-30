import 'package:flutter/foundation.dart';

@immutable
class SafetyPlanWarning {
  const SafetyPlanWarning({
    required this.id,
    required this.planId,
    required this.warningText,
    this.displayOrder = 0,
  });

  final String id;
  final String planId;
  final String warningText;
  final int displayOrder;

  SafetyPlanWarning copyWith({
    String? id,
    String? planId,
    String? warningText,
    int? displayOrder,
  }) {
    return SafetyPlanWarning(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      warningText: warningText ?? this.warningText,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SafetyPlanWarning &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          planId == other.planId &&
          warningText == other.warningText &&
          displayOrder == other.displayOrder;

  @override
  int get hashCode =>
      id.hashCode ^ planId.hashCode ^ warningText.hashCode ^ displayOrder.hashCode;
}
