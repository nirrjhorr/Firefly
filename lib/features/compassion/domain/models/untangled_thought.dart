/// Immutable domain model representing a structured cognitive defusion and untangled thought.
class UntangledThought {
  const UntangledThought({
    required this.id,
    required this.createdAt,
    required this.triggerContext,
    required this.harshCriticVoice,
    required this.commonHumanityPerspective,
    required this.compassionateFriendReframe,
  });

  factory UntangledThought.create({
    required String triggerContext,
    required String harshCriticVoice,
    required String commonHumanityPerspective,
    required String compassionateFriendReframe,
  }) {
    return UntangledThought(
      id: 'thought_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      triggerContext: triggerContext,
      harshCriticVoice: harshCriticVoice,
      commonHumanityPerspective: commonHumanityPerspective,
      compassionateFriendReframe: compassionateFriendReframe,
    );
  }

  final String id;
  final DateTime createdAt;
  final String triggerContext;
  final String harshCriticVoice;
  final String commonHumanityPerspective;
  final String compassionateFriendReframe;

  UntangledThought copyWith({
    String? id,
    DateTime? createdAt,
    String? triggerContext,
    String? harshCriticVoice,
    String? commonHumanityPerspective,
    String? compassionateFriendReframe,
  }) {
    return UntangledThought(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      triggerContext: triggerContext ?? this.triggerContext,
      harshCriticVoice: harshCriticVoice ?? this.harshCriticVoice,
      commonHumanityPerspective:
          commonHumanityPerspective ?? this.commonHumanityPerspective,
      compassionateFriendReframe:
          compassionateFriendReframe ?? this.compassionateFriendReframe,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'triggerContext': triggerContext,
      'harshCriticVoice': harshCriticVoice,
      'commonHumanityPerspective': commonHumanityPerspective,
      'compassionateFriendReframe': compassionateFriendReframe,
    };
  }

  factory UntangledThought.fromJson(Map<String, dynamic> json) {
    return UntangledThought(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      triggerContext: json['triggerContext'] as String? ?? '',
      harshCriticVoice: json['harshCriticVoice'] as String? ?? '',
      commonHumanityPerspective:
          json['commonHumanityPerspective'] as String? ?? '',
      compassionateFriendReframe:
          json['compassionateFriendReframe'] as String? ?? '',
    );
  }
}
