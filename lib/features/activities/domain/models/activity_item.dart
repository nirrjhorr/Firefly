import 'activity_category.dart';
import 'regulation_group.dart';

/// The method or UI experience type used to deliver the regulation activity.
enum GuidanceType {
  interactivePainter,
  stepSequence,
  timerWithAudio,
  promptCards,
  interactiveMap,
  freeform;

  static GuidanceType fromString(String value) {
    return GuidanceType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => GuidanceType.stepSequence,
    );
  }
}

/// The empirical evidentiary foundation grade supporting this activity.
enum EvidenceLevel {
  verified,
  moderate,
  clinicalConsensus,
  preliminary;

  static EvidenceLevel fromString(String value) {
    return EvidenceLevel.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => EvidenceLevel.clinicalConsensus,
    );
  }
}

/// Canonical self-regulation activity entity in Firefly v2.
class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.energyRequired,
    required this.targetStates,
    required this.guidanceType,
    required this.evidenceLevel,
    required this.route,
    this.durationMinutes,
    this.instructions = const [],
    this.isCustom = false,
    this.isFavorite = false,
  })  : assert(energyRequired >= 1 && energyRequired <= 5, 'energyRequired must be between 1 and 5'),
        assert(durationMinutes == null || durationMinutes > 0, 'durationMinutes must be positive when set');

  final String id;
  final String title;
  final String description;
  final ActivityCategory category;
  final int energyRequired; // 1 (lowest) to 5 (highest)
  final Set<String> targetStates; // e.g. 'anxious', 'panicked', 'racingThoughts', 'lowEnergy', 'overwhelmed'
  final GuidanceType guidanceType;
  final EvidenceLevel evidenceLevel;
  final String route;
  final int? durationMinutes;
  final List<String> instructions;
  final bool isCustom;
  final bool isFavorite;

  RegulationGroup get regulationGroup => category.regulationGroup;

  ActivityItem copyWith({
    String? id,
    String? title,
    String? description,
    ActivityCategory? category,
    int? energyRequired,
    Set<String>? targetStates,
    GuidanceType? guidanceType,
    EvidenceLevel? evidenceLevel,
    String? route,
    int? durationMinutes,
    List<String>? instructions,
    bool? isCustom,
    bool? isFavorite,
  }) {
    return ActivityItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      energyRequired: energyRequired ?? this.energyRequired,
      targetStates: targetStates ?? this.targetStates,
      guidanceType: guidanceType ?? this.guidanceType,
      evidenceLevel: evidenceLevel ?? this.evidenceLevel,
      route: route ?? this.route,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      instructions: instructions ?? this.instructions,
      isCustom: isCustom ?? this.isCustom,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'energyRequired': energyRequired,
      'targetStates': targetStates.toList(),
      'guidanceType': guidanceType.name,
      'evidenceLevel': evidenceLevel.name,
      'route': route,
      'durationMinutes': durationMinutes,
      'instructions': instructions,
      'isCustom': isCustom,
      'isFavorite': isFavorite,
    };
  }

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: ActivityCategory.fromString(json['category'] as String),
      energyRequired: (json['energyRequired'] as num).toInt(),
      targetStates: (json['targetStates'] as List<dynamic>?)
              ?.map((e) => e.toString().toLowerCase())
              .toSet() ??
          const {},
      guidanceType: GuidanceType.fromString(json['guidanceType'] as String? ?? 'stepSequence'),
      evidenceLevel: EvidenceLevel.fromString(json['evidenceLevel'] as String? ?? 'clinicalConsensus'),
      route: json['route'] as String? ?? '/home',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isCustom: json['isCustom'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
