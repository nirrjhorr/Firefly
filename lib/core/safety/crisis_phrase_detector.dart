/// Clinical categories of crisis language identified from evidence-based literature
/// (Stanley & Brown SPI protocols, WHO crisis intervention guidelines).
enum CrisisMatchCategory {
  suicidalIdeation,
  selfHarm,
  acuteHopelessness,
}

/// Immutable result of an on-device deterministic crisis phrase evaluation.
/// Zero telemetry invariant: this model is never logged, persisted, or transmitted.
class CrisisDetectionResult {
  const CrisisDetectionResult({
    required this.hasMatch,
    this.matchedCategory,
    this.matchedPhrase,
  });

  const CrisisDetectionResult.none()
      : hasMatch = false,
        matchedCategory = null,
        matchedPhrase = null;

  final bool hasMatch;
  final CrisisMatchCategory? matchedCategory;
  final String? matchedPhrase;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrisisDetectionResult &&
          runtimeType == other.runtimeType &&
          hasMatch == other.hasMatch &&
          matchedCategory == other.matchedCategory &&
          matchedPhrase == other.matchedPhrase;

  @override
  int get hashCode => Object.hash(hasMatch, matchedCategory, matchedPhrase);

  @override
  String toString() =>
      'CrisisDetectionResult(hasMatch: $hasMatch, category: $matchedCategory)';
}

/// Offline, deterministic crisis phrase matcher for text input in Firefly.
/// Adheres strictly to PRD Section 6.2 and Zero-Network Invariant.
///
/// Features:
/// 1. Zero cloud or LLM reliance — executes entirely on-device in < 1ms.
/// 2. False-positive filtering for common conversational idioms (e.g. "die of embarrassment").
/// 3. Normalizes punctuation, excessive whitespace, and case.
/// 4. Never writes to disk, log streams, or analytics.
class CrisisPhraseDetector {
  const CrisisPhraseDetector();

  // False positive exclusion phrases
  static const List<String> _idiomExceptions = [
    'die of embarrassment',
    'die of laughter',
    'dying of laughter',
    'dying of embarrassment',
    'to die for',
    'dead tired',
    'bored to death',
    'worried to death',
    'scared to death',
    'killing time',
  ];

  // Clinical patterns compiled for Suicidal Ideation
  static const List<String> _suicidalPatterns = [
    'want to die',
    'wanna die',
    'wish i were dead',
    'wish i was dead',
    'better off dead',
    'kill myself',
    'killing myself',
    'end my life',
    'ending my life',
    'take my own life',
    'taking my own life',
    'commit suicide',
    'want to end it',
    'wanna end it',
    'not wake up',
    'never wake up again',
    'no reason to live',
    'no point in living',
    "can't go on living",
    'cannot go on living',
    'ready to die',
  ];

  // Clinical patterns compiled for Self-Harm
  static const List<String> _selfHarmPatterns = [
    'cut myself',
    'cutting myself',
    'harm myself',
    'harming myself',
    'harmed myself',
    'hurt myself',
    'hurting myself',
    'burn myself',
    'burning myself',
    'burned myself',
    'self harm',
    'self-harm',
    'punish myself physically',
  ];

  // Clinical patterns compiled for Acute Hopelessness
  static const List<String> _hopelessnessPatterns = [
    'there is no way out',
    'no way out for me',
    'give up on everything',
    'give up on life',
    'giving up on life',
    'nobody would miss me',
    'everyone would be better without me',
    'world would be better without me',
  ];

  /// Evaluates the given [text] deterministically.
  /// Returns a [CrisisDetectionResult] indicating whether any clinical trigger was detected.
  CrisisDetectionResult checkText(String text) {
    if (text.trim().isEmpty) {
      return const CrisisDetectionResult.none();
    }

    final normalized = _normalizeText(text);

    // Check for idiom exceptions first to minimize false positives
    for (final idiom in _idiomExceptions) {
      if (normalized.contains(idiom)) {
        // If an idiom is found, verify whether the only "die/kill" match came from the idiom
        final sanitized = normalized.replaceAll(idiom, ' ');
        return _evaluateNormalized(sanitized);
      }
    }

    return _evaluateNormalized(normalized);
  }

  CrisisDetectionResult _evaluateNormalized(String text) {
    // 1. Check Suicidal Ideation patterns
    for (final pattern in _suicidalPatterns) {
      if (_matchesWordOrPhrase(text, pattern)) {
        return CrisisDetectionResult(
          hasMatch: true,
          matchedCategory: CrisisMatchCategory.suicidalIdeation,
          matchedPhrase: pattern,
        );
      }
    }

    // 2. Check Self-Harm patterns
    for (final pattern in _selfHarmPatterns) {
      if (_matchesWordOrPhrase(text, pattern)) {
        return CrisisDetectionResult(
          hasMatch: true,
          matchedCategory: CrisisMatchCategory.selfHarm,
          matchedPhrase: pattern,
        );
      }
    }

    // 3. Check Acute Hopelessness patterns
    for (final pattern in _hopelessnessPatterns) {
      if (_matchesWordOrPhrase(text, pattern)) {
        return CrisisDetectionResult(
          hasMatch: true,
          matchedCategory: CrisisMatchCategory.acuteHopelessness,
          matchedPhrase: pattern,
        );
      }
    }

    return const CrisisDetectionResult.none();
  }

  static String _normalizeText(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r"[^\w\s']|_"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _matchesWordOrPhrase(String text, String phrase) {
    // Word boundary check: ensure phrase is matched as discrete token sequence
    final regex = RegExp(r'(^|\s)' + RegExp.escape(phrase) + r'($|\s)');
    return regex.hasMatch(text);
  }
}
