import 'activity_affinity.dart';

/// Aggregated, non-judgmental personal regulation profile computed on-device.
/// Reflects what activities have proven most calming across various states.
class PersonalRegulationProfile {
  const PersonalRegulationProfile({
    required this.affinities,
    required this.topPracticesByState,
    required this.overallTopPractices,
    required this.totalMomentsOfCare,
    required this.calmingSessionCount,
    required this.calmingRate,
    required this.lastUpdated,
  });

  final List<ActivityAffinity> affinities;
  final Map<String, List<ActivityAffinity>> topPracticesByState;
  final List<ActivityAffinity> overallTopPractices;
  final int totalMomentsOfCare;
  final int calmingSessionCount;
  final double calmingRate;
  final DateTime lastUpdated;

  bool get isEmpty => totalMomentsOfCare == 0;

  static PersonalRegulationProfile empty() {
    return PersonalRegulationProfile(
      affinities: const [],
      topPracticesByState: const {},
      overallTopPractices: const [],
      totalMomentsOfCare: 0,
      calmingSessionCount: 0,
      calmingRate: 0.0,
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'affinities': affinities.map((a) => a.toJson()).toList(),
      'topPracticesByState': topPracticesByState.map(
        (key, value) => MapEntry(key, value.map((a) => a.toJson()).toList()),
      ),
      'overallTopPractices': overallTopPractices.map((a) => a.toJson()).toList(),
      'totalMomentsOfCare': totalMomentsOfCare,
      'calmingSessionCount': calmingSessionCount,
      'calmingRate': calmingRate,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory PersonalRegulationProfile.fromJson(Map<String, dynamic> json) {
    final rawAffinities = (json['affinities'] as List<dynamic>? ?? [])
        .map((e) => ActivityAffinity.fromJson(e as Map<String, dynamic>))
        .toList();

    final rawTopByState = (json['topPracticesByState'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(
              k,
              (v as List<dynamic>)
                  .map((e) => ActivityAffinity.fromJson(e as Map<String, dynamic>))
                  .toList(),
            ));

    final rawOverall = (json['overallTopPractices'] as List<dynamic>? ?? [])
        .map((e) => ActivityAffinity.fromJson(e as Map<String, dynamic>))
        .toList();

    return PersonalRegulationProfile(
      affinities: rawAffinities,
      topPracticesByState: rawTopByState,
      overallTopPractices: rawOverall,
      totalMomentsOfCare: (json['totalMomentsOfCare'] as num?)?.toInt() ?? 0,
      calmingSessionCount: (json['calmingSessionCount'] as num?)?.toInt() ?? 0,
      calmingRate: (json['calmingRate'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }
}
