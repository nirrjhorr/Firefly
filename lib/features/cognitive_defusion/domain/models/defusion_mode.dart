/// The three evidence-based cognitive defusion modes in Firefly.
enum DefusionMode {
  leavesOnStream,
  thoughtClouds,
  thoughtLabeling;

  String get displayName {
    switch (this) {
      case DefusionMode.leavesOnStream:
        return 'Leaves on a Stream';
      case DefusionMode.thoughtClouds:
        return 'Thought Cloud Dissolve';
      case DefusionMode.thoughtLabeling:
        return 'Thought Labelling';
    }
  }

  String get description {
    switch (this) {
      case DefusionMode.leavesOnStream:
        return 'Place thoughts on gentle leaves and watch them float down a quiet woodland stream.';
      case DefusionMode.thoughtClouds:
        return 'Type a heavy thought into a drifting cloud and watch it dissolve into twilight mist.';
      case DefusionMode.thoughtLabeling:
        return 'Create mindful psychological distance: "I notice I am having the thought that..."';
    }
  }

  String get iconKey {
    switch (this) {
      case DefusionMode.leavesOnStream:
        return 'leaf';
      case DefusionMode.thoughtClouds:
        return 'cloud';
      case DefusionMode.thoughtLabeling:
        return 'text.quote';
    }
  }

  static DefusionMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'leaves':
      case 'leavesonstream':
      case 'stream':
        return DefusionMode.leavesOnStream;
      case 'clouds':
      case 'thoughtclouds':
        return DefusionMode.thoughtClouds;
      case 'labeling':
      case 'labelling':
      case 'thoughtlabeling':
        return DefusionMode.thoughtLabeling;
      default:
        return DefusionMode.leavesOnStream;
    }
  }
}
