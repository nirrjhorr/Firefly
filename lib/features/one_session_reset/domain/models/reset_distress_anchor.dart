/// Evidence-based acute distress categories to name the user's initial state
/// during the One-Session Reset protocol.
enum ResetDistressAnchor {
  racingThoughts,
  physicalTension,
  heavyInertia,
  sensoryOverwhelm,
  lonelinessDread,
  generalDistress;

  String get label {
    switch (this) {
      case ResetDistressAnchor.racingThoughts:
        return 'Racing Thoughts & Fog';
      case ResetDistressAnchor.physicalTension:
        return 'Chest Tightness & Restlessness';
      case ResetDistressAnchor.heavyInertia:
        return 'Depressive Inertia & Numbness';
      case ResetDistressAnchor.sensoryOverwhelm:
        return 'Sensory Overload & Noise';
      case ResetDistressAnchor.lonelinessDread:
        return 'Nighttime Isolation & Longing';
      case ResetDistressAnchor.generalDistress:
        return 'General Acute Tension';
    }
  }

  String get subtitle {
    switch (this) {
      case ResetDistressAnchor.racingThoughts:
        return 'Thoughts spinning faster than you can sort them.';
      case ResetDistressAnchor.physicalTension:
        return 'Shallow breathing, clenched muscles, or physical agitation.';
      case ResetDistressAnchor.heavyInertia:
        return 'Moving feels like wading through deep water.';
      case ResetDistressAnchor.sensoryOverwhelm:
        return 'Too much input, sound, or emotional pressure.';
      case ResetDistressAnchor.lonelinessDread:
        return 'A quiet ache or disconnection late at night.';
      case ResetDistressAnchor.generalDistress:
        return 'Hard to name, but something feels unsettled.';
    }
  }

  String get suggestedTechniqueName {
    switch (this) {
      case ResetDistressAnchor.racingThoughts:
        return 'Cyclic Sighing Breath';
      case ResetDistressAnchor.physicalTension:
        return 'Progressive Tension Release';
      case ResetDistressAnchor.heavyInertia:
        return 'Sensory 3-2-1 Grounding';
      case ResetDistressAnchor.sensoryOverwhelm:
        return 'Quiet Visual Settling';
      case ResetDistressAnchor.lonelinessDread:
        return 'Gentle Self-Compassion Breath';
      case ResetDistressAnchor.generalDistress:
        return 'Resonance Paced Breathing';
    }
  }

  String get iconKey {
    switch (this) {
      case ResetDistressAnchor.racingThoughts:
        return 'brain.head.profile';
      case ResetDistressAnchor.physicalTension:
        return 'wind';
      case ResetDistressAnchor.heavyInertia:
        return 'figure.walk';
      case ResetDistressAnchor.sensoryOverwhelm:
        return 'hand.point.up.left';
      case ResetDistressAnchor.lonelinessDread:
        return 'heart';
      case ResetDistressAnchor.generalDistress:
        return 'sparkles';
    }
  }
}
