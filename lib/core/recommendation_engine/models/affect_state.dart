import 'package:flutter/foundation.dart';

@immutable
class AffectState {
  const AffectState({
    required this.moodCategory,
    required this.energyLevel,
    required this.anxietyLevel,
    required this.lonelinessLevel,
    this.affectLabels = const [],
  })  : assert(energyLevel >= 1 && energyLevel <= 5, 'energyLevel must be 1-5'),
        assert(anxietyLevel >= 1 && anxietyLevel <= 5, 'anxietyLevel must be 1-5'),
        assert(lonelinessLevel >= 1 && lonelinessLevel <= 5, 'lonelinessLevel must be 1-5');

  final String moodCategory;
  final int energyLevel; // 1-5
  final int anxietyLevel; // 1-5
  final int lonelinessLevel; // 1-5
  final List<String> affectLabels;

  AffectState copyWith({
    String? moodCategory,
    int? energyLevel,
    int? anxietyLevel,
    int? lonelinessLevel,
    List<String>? affectLabels,
  }) {
    return AffectState(
      moodCategory: moodCategory ?? this.moodCategory,
      energyLevel: energyLevel ?? this.energyLevel,
      anxietyLevel: anxietyLevel ?? this.anxietyLevel,
      lonelinessLevel: lonelinessLevel ?? this.lonelinessLevel,
      affectLabels: affectLabels ?? this.affectLabels,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AffectState &&
          runtimeType == other.runtimeType &&
          moodCategory == other.moodCategory &&
          energyLevel == other.energyLevel &&
          anxietyLevel == other.anxietyLevel &&
          lonelinessLevel == other.lonelinessLevel;

  @override
  int get hashCode =>
      moodCategory.hashCode ^
      energyLevel.hashCode ^
      anxietyLevel.hashCode ^
      lonelinessLevel.hashCode;
}
