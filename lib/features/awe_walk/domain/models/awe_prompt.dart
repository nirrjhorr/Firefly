/// Modality of observational awe cues.
enum AweModality {
  panoramic,
  visual,
  auditory,
  tactile,
  structural;

  String get displayName {
    switch (this) {
      case AweModality.panoramic:
        return 'Panoramic Gaze';
      case AweModality.visual:
        return 'Visual Wonder';
      case AweModality.auditory:
        return 'Sound Layering';
      case AweModality.tactile:
        return 'Tactile Presence';
      case AweModality.structural:
        return 'Natural Geometry';
    }
  }
}

/// Curated observational prompt for perspective shift during an Awe Walk
/// (operationalizing Sturm et al. 2020 protocol).
class AwePrompt {
  const AwePrompt({
    required this.id,
    required this.title,
    required this.instruction,
    required this.reflectionCue,
    required this.modality,
    this.suggestedSeconds = 90,
  });

  final String id;
  final String title;
  final String instruction;
  final String reflectionCue;
  final AweModality modality;
  final int suggestedSeconds;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'instruction': instruction,
        'reflectionCue': reflectionCue,
        'modality': modality.name,
        'suggestedSeconds': suggestedSeconds,
      };

  factory AwePrompt.fromJson(Map<String, dynamic> json) {
    return AwePrompt(
      id: json['id'] as String,
      title: json['title'] as String,
      instruction: json['instruction'] as String,
      reflectionCue: json['reflectionCue'] as String,
      modality: AweModality.values.firstWhere(
        (m) => m.name == json['modality'],
        orElse: () => AweModality.visual,
      ),
      suggestedSeconds: (json['suggestedSeconds'] as num?)?.toInt() ?? 90,
    );
  }

  /// Default evidence-based prompt suite from Sturm et al. 2020.
  static const List<AwePrompt> curatedPrompts = [
    AwePrompt(
      id: 'awe_panoramic_horizon',
      title: 'Panoramic Horizon',
      instruction:
          'Lift your chin and widen your peripheral vision. Look as far into the distance as possible, beyond your immediate path.',
      reflectionCue:
          'Notice how wide the world is beyond your immediate mental concerns.',
      modality: AweModality.panoramic,
      suggestedSeconds: 90,
    ),
    AwePrompt(
      id: 'awe_canopy_sky',
      title: 'Canopy & Sky Depth',
      instruction:
          'Gaze upward into tree branches, cloud textures, or atmospheric depth. Notice light filtering through layers of height.',
      reflectionCue:
          'These patterns and atmospheric cycles have been moving long before today.',
      modality: AweModality.visual,
      suggestedSeconds: 120,
    ),
    AwePrompt(
      id: 'awe_micro_wonder',
      title: 'Micro-Wonder & Geometry',
      instruction:
          'Slow your steps to pause. Zoom in on a single small natural marvel: moss clinging to stone, leaf veins, or weathered bark.',
      reflectionCue:
          'Even in tiny places, intricate order and life quietly flourish without hurry.',
      modality: AweModality.structural,
      suggestedSeconds: 90,
    ),
    AwePrompt(
      id: 'awe_acoustic_layers',
      title: 'Acoustic Openness',
      instruction:
          'Softly listen without looking. Distinguish at least two distinct sound layers: wind or rustling nearby, and a distant hum or echo far away.',
      reflectionCue:
          'You are immersed inside an acoustic tapestry wider than your thoughts.',
      modality: AweModality.auditory,
      suggestedSeconds: 90,
    ),
    AwePrompt(
      id: 'awe_small_self_comfort',
      title: 'The Small Self Comfort',
      instruction:
          'Feel the physical ground beneath your shoes. Acknowledge: I am small, and that is a relief. I do not have to carry everything.',
      reflectionCue:
          'Take one deep, expansive breath. Enjoy being a modest, living part of this immense world.',
      modality: AweModality.panoramic,
      suggestedSeconds: 120,
    ),
  ];
}
