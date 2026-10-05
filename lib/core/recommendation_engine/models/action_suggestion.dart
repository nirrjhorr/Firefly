import 'package:flutter/foundation.dart';

enum ActionType {
  breathing,
  tinySteps,
  lonelinessComfort,
  grounding,
  journaling,
  hopeBox,
  soundscape;

  static ActionType fromString(String value) {
    return ActionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ActionType.breathing,
    );
  }
}

@immutable
class ActionSuggestion {
  const ActionSuggestion({
    required this.actionType,
    required this.title,
    required this.body,
    required this.route,
    required this.durationMinutes,
    this.alternativeSuggestions = const [],
  });

  final ActionType actionType;
  final String title;
  final String body;
  final String route;
  final int durationMinutes;
  final List<ActionSuggestion> alternativeSuggestions;

  Map<String, dynamic> toJson() {
    return {
      'actionType': actionType.name,
      'title': title,
      'body': body,
      'route': route,
      'durationMinutes': durationMinutes,
    };
  }

  factory ActionSuggestion.fromJson(Map<String, dynamic> json) {
    return ActionSuggestion(
      actionType: ActionType.fromString(json['actionType'] as String? ?? 'breathing'),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      route: json['route'] as String? ?? '/home',
      durationMinutes: json['durationMinutes'] as int? ?? 2,
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
          durationMinutes == other.durationMinutes;

  @override
  int get hashCode =>
      actionType.hashCode ^
      title.hashCode ^
      route.hashCode ^
      durationMinutes.hashCode;
}
