/// The 5 evidence-based nature observation modes for grounding attention.
enum NatureObservationMode {
  skyGazing,
  treeCanopy,
  lightAndShadow,
  outdoorGrounding,
  weatherNotice;

  String get title {
    switch (this) {
      case NatureObservationMode.skyGazing:
        return 'Sky & Clouds';
      case NatureObservationMode.treeCanopy:
        return 'Trees & Leaves';
      case NatureObservationMode.lightAndShadow:
        return 'Light & Shadows';
      case NatureObservationMode.outdoorGrounding:
        return 'Earth & Elements';
      case NatureObservationMode.weatherNotice:
        return 'Weather & Air';
    }
  }

  String get description {
    switch (this) {
      case NatureObservationMode.skyGazing:
        return 'Broaden your visual field, watch cloud movement, and notice sky gradients.';
      case NatureObservationMode.treeCanopy:
        return 'Observe branch fractals, leaf rustling, and organic green textures.';
      case NatureObservationMode.lightAndShadow:
        return 'Notice angles of sunlight, shadows on walls, and subtle illumination.';
      case NatureObservationMode.outdoorGrounding:
        return 'Sense air on skin, solid ground underfoot, and natural textures.';
      case NatureObservationMode.weatherNotice:
        return 'Listen to rain rhythms, feel breeze velocity, and observe the atmosphere.';
    }
  }

  String get indoorAlternative {
    switch (this) {
      case NatureObservationMode.skyGazing:
        return 'Look through any window toward the highest open sky or ceiling.';
      case NatureObservationMode.treeCanopy:
        return 'Observe any houseplant, flower, or view of trees from a window.';
      case NatureObservationMode.lightAndShadow:
        return 'Look at sunlight falling across a floor, table, or wall in your room.';
      case NatureObservationMode.outdoorGrounding:
        return 'Feel the solid floor beneath your feet or touch a wooden or stone surface.';
      case NatureObservationMode.weatherNotice:
        return 'Listen to exterior sounds from a window or feel ambient air current.';
    }
  }

  String get iconKey {
    switch (this) {
      case NatureObservationMode.skyGazing:
        return 'cloud.sun';
      case NatureObservationMode.treeCanopy:
        return 'leaf';
      case NatureObservationMode.lightAndShadow:
        return 'sun.max';
      case NatureObservationMode.outdoorGrounding:
        return 'figure.walk';
      case NatureObservationMode.weatherNotice:
        return 'wind';
    }
  }

  static NatureObservationMode fromString(String value) {
    final lower = value.toLowerCase();
    for (final mode in NatureObservationMode.values) {
      if (mode.name.toLowerCase() == lower) {
        return mode;
      }
    }
    return NatureObservationMode.skyGazing;
  }
}
