import 'package:flutter/foundation.dart';

/// Categories for behavioural activation micro-actions.
enum TinyStepCategory {
  sensory,
  physical,
  environment,
  nourishment;

  String get displayName {
    switch (this) {
      case TinyStepCategory.sensory:
        return 'Sensory';
      case TinyStepCategory.physical:
        return 'Physical';
      case TinyStepCategory.environment:
        return 'Environment';
      case TinyStepCategory.nourishment:
        return 'Nourishment';
    }
  }

  static TinyStepCategory fromString(String value) {
    return TinyStepCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TinyStepCategory.physical,
    );
  }
}

/// A 2-minute-or-less evidence-based behavioural activation task.
@immutable
class TinyStep {
  const TinyStep({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.minEnergyLevel,
    required this.maxEnergyLevel,
    required this.durationMinutes,
  })  : assert(minEnergyLevel >= 1 && minEnergyLevel <= 5, 'minEnergyLevel must be between 1 and 5'),
        assert(maxEnergyLevel >= 1 && maxEnergyLevel <= 5, 'maxEnergyLevel must be between 1 and 5'),
        assert(minEnergyLevel <= maxEnergyLevel, 'minEnergyLevel cannot exceed maxEnergyLevel'),
        assert(durationMinutes > 0 && durationMinutes <= 2, 'durationMinutes must be 1 or 2');

  final String id;
  final String title;
  final String description;
  final TinyStepCategory category;
  final int minEnergyLevel;
  final int maxEnergyLevel;
  final int durationMinutes;

  /// Returns true if this step is suitable for the given energy level (1-5).
  bool matchesEnergy(int energy) {
    return energy >= minEnergyLevel && energy <= maxEnergyLevel;
  }

  TinyStep copyWith({
    String? id,
    String? title,
    String? description,
    TinyStepCategory? category,
    int? minEnergyLevel,
    int? maxEnergyLevel,
    int? durationMinutes,
  }) {
    return TinyStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      minEnergyLevel: minEnergyLevel ?? this.minEnergyLevel,
      maxEnergyLevel: maxEnergyLevel ?? this.maxEnergyLevel,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'minEnergyLevel': minEnergyLevel,
      'maxEnergyLevel': maxEnergyLevel,
      'durationMinutes': durationMinutes,
    };
  }

  factory TinyStep.fromJson(Map<String, dynamic> json) {
    return TinyStep(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: TinyStepCategory.fromString(json['category'] as String? ?? 'physical'),
      minEnergyLevel: json['minEnergyLevel'] as int? ?? 1,
      maxEnergyLevel: json['maxEnergyLevel'] as int? ?? 5,
      durationMinutes: json['durationMinutes'] as int? ?? 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TinyStep &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          category == other.category &&
          minEnergyLevel == other.minEnergyLevel &&
          maxEnergyLevel == other.maxEnergyLevel &&
          durationMinutes == other.durationMinutes;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      category.hashCode ^
      minEnergyLevel.hashCode ^
      maxEnergyLevel.hashCode ^
      durationMinutes.hashCode;

  @override
  String toString() =>
      'TinyStep(id: $id, title: $title, category: ${category.name}, duration: ${durationMinutes}m)';
}
