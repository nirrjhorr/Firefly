enum ActionType {
  breathing,
  tinySteps,
  lonelinessComfort,
  grounding,
  journaling,
  hopeBox,
  soundscape,
  focus,
  compassion,
  reset,
  movement,
  pmr,
  flowPuzzle,
  labyrinth,
  sleepWindDown;

  static ActionType fromString(String value) {
    return ActionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ActionType.breathing,
    );
  }
}

class ActionSuggestion {
  const ActionSuggestion({
    required this.actionType,
    required this.title,
    required this.body,
    required this.route,
    required this.durationMinutes,
    this.alternativeSuggestions = const [],
    this.personalizedReason,
    this.affinityScore,
  });

  final ActionType actionType;
  final String title;
  final String body;
  final String route;
  final int durationMinutes;
  final List<ActionSuggestion> alternativeSuggestions;

  /// Optional personal reason grounded in past EMA rating shifts.
  final String? personalizedReason;

  /// Normalized personal affinity score in [-1.0, 1.0].
  final double? affinityScore;

  bool get isPersonalized => personalizedReason != null && (affinityScore ?? 0) > 0.15;

  ActionSuggestion copyWith({
    ActionType? actionType,
    String? title,
    String? body,
    String? route,
    int? durationMinutes,
    List<ActionSuggestion>? alternativeSuggestions,
    String? personalizedReason,
    double? affinityScore,
  }) {
    return ActionSuggestion(
      actionType: actionType ?? this.actionType,
      title: title ?? this.title,
      body: body ?? this.body,
      route: route ?? this.route,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      alternativeSuggestions: alternativeSuggestions ?? this.alternativeSuggestions,
      personalizedReason: personalizedReason ?? this.personalizedReason,
      affinityScore: affinityScore ?? this.affinityScore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actionType': actionType.name,
      'title': title,
      'body': body,
      'route': route,
      'durationMinutes': durationMinutes,
      if (personalizedReason != null) 'personalizedReason': personalizedReason,
      if (affinityScore != null) 'affinityScore': affinityScore,
    };
  }

  factory ActionSuggestion.fromJson(Map<String, dynamic> json) {
    return ActionSuggestion(
      actionType: ActionType.fromString(json['actionType'] as String? ?? 'breathing'),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      route: json['route'] as String? ?? '/home',
      durationMinutes: json['durationMinutes'] as int? ?? 2,
      personalizedReason: json['personalizedReason'] as String?,
      affinityScore: (json['affinityScore'] as num?)?.toDouble(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActionSuggestion &&
          runtimeType == other.runtimeType &&
          actionType == other.actionType &&
          title == other.title &&
          route == other.route &&
          durationMinutes == other.durationMinutes &&
          personalizedReason == other.personalizedReason &&
          affinityScore == other.affinityScore;

  @override
  int get hashCode =>
      actionType.hashCode ^
      title.hashCode ^
      route.hashCode ^
      durationMinutes.hashCode ^
      personalizedReason.hashCode ^
      affinityScore.hashCode;
}

