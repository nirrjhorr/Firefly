/// Expected or experienced social reaction outcome in the "Guess vs. Reality" experiment.
///
/// Grounded in Kumar & Epley 2023 ("The Surprise of Reaching Out", JPSP 124(4)).
enum SocialOutcome {
  warm,
  neutral,
  wontRespond;

  String get label {
    switch (this) {
      case SocialOutcome.warm:
        return 'Warmly & appreciative';
      case SocialOutcome.neutral:
        return 'Neutral or brief';
      case SocialOutcome.wontRespond:
        return "Didn't respond / distant";
    }
  }

  String get shortLabel {
    switch (this) {
      case SocialOutcome.warm:
        return 'Warm';
      case SocialOutcome.neutral:
        return 'Neutral';
      case SocialOutcome.wontRespond:
        return 'Distant / No reply';
    }
  }

  int get positivityRank {
    switch (this) {
      case SocialOutcome.warm:
        return 2;
      case SocialOutcome.neutral:
        return 1;
      case SocialOutcome.wontRespond:
        return 0;
    }
  }

  /// Gentle, non-judgmental clinical validation feedback when user reports this outcome.
  String get validationFeedback {
    switch (this) {
      case SocialOutcome.warm:
        return "Notice how much warmer it was than the awkwardness you feared. Your presence mattered.";
      case SocialOutcome.neutral:
        return "A simple exchange still grounds us in human connection. You took a gentle, brave step.";
      case SocialOutcome.wontRespond:
        return "That's hard. It doesn't mean reaching out was wrong — it just didn't land today.";
    }
  }
}

/// A single behavioral experiment record pairing an initial pre-send prediction
/// with the real-world post-send outcome.
class SocialPredictionExperiment {
  const SocialPredictionExperiment({
    required this.id,
    required this.contactId,
    required this.contactName,
    required this.predictedOutcome,
    required this.predictedAtUnix,
    this.actualOutcome,
    this.completedAtUnix,
    this.messageSnippet,
  });

  final String id;
  final String contactId;
  final String contactName;
  final SocialOutcome predictedOutcome;
  final int predictedAtUnix;
  final SocialOutcome? actualOutcome;
  final int? completedAtUnix;
  final String? messageSnippet;

  bool get isCompleted => actualOutcome != null;

  /// Whether the real outcome met or exceeded the initial prediction.
  bool get wasOutcomeEqualOrWarmer {
    if (actualOutcome == null) return false;
    return actualOutcome!.positivityRank >= predictedOutcome.positivityRank;
  }

  SocialPredictionExperiment copyWith({
    String? id,
    String? contactId,
    String? contactName,
    SocialOutcome? predictedOutcome,
    int? predictedAtUnix,
    SocialOutcome? actualOutcome,
    int? completedAtUnix,
    String? messageSnippet,
  }) {
    return SocialPredictionExperiment(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      contactName: contactName ?? this.contactName,
      predictedOutcome: predictedOutcome ?? this.predictedOutcome,
      predictedAtUnix: predictedAtUnix ?? this.predictedAtUnix,
      actualOutcome: actualOutcome ?? this.actualOutcome,
      completedAtUnix: completedAtUnix ?? this.completedAtUnix,
      messageSnippet: messageSnippet ?? this.messageSnippet,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contactId': contactId,
      'contactName': contactName,
      'predictedOutcome': predictedOutcome.name,
      'predictedAtUnix': predictedAtUnix,
      'actualOutcome': actualOutcome?.name,
      'completedAtUnix': completedAtUnix,
      'messageSnippet': messageSnippet,
    };
  }

  factory SocialPredictionExperiment.fromJson(Map<String, dynamic> json) {
    return SocialPredictionExperiment(
      id: json['id'] as String,
      contactId: json['contactId'] as String,
      contactName: json['contactName'] as String,
      predictedOutcome: SocialOutcome.values.byName(json['predictedOutcome'] as String),
      predictedAtUnix: json['predictedAtUnix'] as int,
      actualOutcome: json['actualOutcome'] != null
          ? SocialOutcome.values.byName(json['actualOutcome'] as String)
          : null,
      completedAtUnix: json['completedAtUnix'] as int?,
      messageSnippet: json['messageSnippet'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialPredictionExperiment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          contactId == other.contactId &&
          contactName == other.contactName &&
          predictedOutcome == other.predictedOutcome &&
          predictedAtUnix == other.predictedAtUnix &&
          actualOutcome == other.actualOutcome &&
          completedAtUnix == other.completedAtUnix &&
          messageSnippet == other.messageSnippet;

  @override
  int get hashCode =>
      id.hashCode ^
      contactId.hashCode ^
      contactName.hashCode ^
      predictedOutcome.hashCode ^
      predictedAtUnix.hashCode ^
      actualOutcome.hashCode ^
      completedAtUnix.hashCode ^
      messageSnippet.hashCode;
}

/// Aggregate summary of "Guess vs. Reality" experiments.
///
/// Disassembles social avoidance distortions through empirical evidence.
class SocialExperimentSummary {
  const SocialExperimentSummary({
    this.totalExperiments = 0,
    this.completedCount = 0,
    this.predictedWarmCount = 0,
    this.predictedNeutralCount = 0,
    this.predictedWontRespondCount = 0,
    this.actualWarmCount = 0,
    this.actualNeutralCount = 0,
    this.actualWontRespondCount = 0,
    this.actualWarmerOrEqualCount = 0,
  });

  final int totalExperiments;
  final int completedCount;
  final int predictedWarmCount;
  final int predictedNeutralCount;
  final int predictedWontRespondCount;
  final int actualWarmCount;
  final int actualNeutralCount;
  final int actualWontRespondCount;
  final int actualWarmerOrEqualCount;

  /// Whether enough behavioral evidence (≥ 3 completed experiments) has been logged
  /// to unlock the gentle cognitive reframing card.
  bool get shouldShowInsight => completedCount >= 3;

  /// Percentage of completed attempts where reality was warmer or equal to prediction.
  int get warmerOrEqualPercentage {
    if (completedCount == 0) return 0;
    return ((actualWarmerOrEqualCount / completedCount) * 100).round();
  }

  String get insightHeadline => "Your predictions vs. what happened";

  String get insightBody {
    final warmOrNeutral = actualWarmCount + actualNeutralCount;
    return "Across $completedCount times you reached out, $warmOrNeutral responses were warm or neutral. "
        "Research shows people appreciate being contacted far more than our anxious thoughts predict.";
  }

  factory SocialExperimentSummary.fromExperiments(List<SocialPredictionExperiment> experiments) {
    int total = experiments.length;
    int completed = 0;
    int pWarm = 0;
    int pNeutral = 0;
    int pWont = 0;
    int aWarm = 0;
    int aNeutral = 0;
    int aWont = 0;
    int warmerOrEqual = 0;

    for (final exp in experiments) {
      switch (exp.predictedOutcome) {
        case SocialOutcome.warm:
          pWarm++;
          break;
        case SocialOutcome.neutral:
          pNeutral++;
          break;
        case SocialOutcome.wontRespond:
          pWont++;
          break;
      }

      if (exp.isCompleted) {
        completed++;
        switch (exp.actualOutcome!) {
          case SocialOutcome.warm:
            aWarm++;
            break;
          case SocialOutcome.neutral:
            aNeutral++;
            break;
          case SocialOutcome.wontRespond:
            aWont++;
            break;
        }
        if (exp.wasOutcomeEqualOrWarmer) {
          warmerOrEqual++;
        }
      }
    }

    return SocialExperimentSummary(
      totalExperiments: total,
      completedCount: completed,
      predictedWarmCount: pWarm,
      predictedNeutralCount: pNeutral,
      predictedWontRespondCount: pWont,
      actualWarmCount: aWarm,
      actualNeutralCount: aNeutral,
      actualWontRespondCount: aWont,
      actualWarmerOrEqualCount: warmerOrEqual,
    );
  }
}
