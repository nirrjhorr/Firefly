import 'package:flutter/foundation.dart';
import '../../../../core/recommendation_engine/models/action_suggestion.dart';

@immutable
class CheckInEntry {
  const CheckInEntry({
    required this.id,
    required this.moodCategory,
    required this.energyLevel,
    required this.anxietyLevel,
    required this.lonelinessLevel,
    this.affectLabels = const [],
    this.suggestedAction,
    required this.createdAtUnix,
    required this.updatedAtUnix,
  });

  final String id;
  final String moodCategory;
  final int energyLevel;
  final int anxietyLevel;
  final int lonelinessLevel;
  final List<String> affectLabels;
  final ActionSuggestion? suggestedAction;
  final int createdAtUnix;
  final int updatedAtUnix;

  CheckInEntry copyWith({
    String? id,
    String? moodCategory,
    int? energyLevel,
    int? anxietyLevel,
    int? lonelinessLevel,
    List<String>? affectLabels,
    ActionSuggestion? suggestedAction,
    int? createdAtUnix,
    int? updatedAtUnix,
  }) {
    return CheckInEntry(
      id: id ?? this.id,
      moodCategory: moodCategory ?? this.moodCategory,
      energyLevel: energyLevel ?? this.energyLevel,
      anxietyLevel: anxietyLevel ?? this.anxietyLevel,
      lonelinessLevel: lonelinessLevel ?? this.lonelinessLevel,
      affectLabels: affectLabels ?? this.affectLabels,
      suggestedAction: suggestedAction ?? this.suggestedAction,
      createdAtUnix: createdAtUnix ?? this.createdAtUnix,
      updatedAtUnix: updatedAtUnix ?? this.updatedAtUnix,
    );
  }
}
