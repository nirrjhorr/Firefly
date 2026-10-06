import 'reach_out_contact.dart';
import 'social_prediction_experiment.dart';

/// Pre-written, research-grounded message templates (Kumar & Epley 2023).
const List<String> kDefaultReachOutTemplates = [
  "Hey — I've been thinking of you. How are you doing?",
  "Hi — just wanted to check in. Can we talk?",
  "I'm having a hard time and thought of you. Would you be up for a call?",
  "Thinking of you today and so grateful for you. No need to reply at all, just wanted you to know.",
  "Would you be up for sitting together in quiet for a bit? No need to talk, just parallel presence.",
  "Would you want to do a simple puzzle or play a low-key cooperative game together sometime?",
  "Could you just be around while I make tea or do a small task? Having someone nearby helps.",
];

/// Immutable UI and domain state for the Loneliness Comfort & "Guess vs. Reality" engine.
class LonelinessComfortState {
  const LonelinessComfortState({
    this.contacts = const [],
    this.experiments = const [],
    this.activePendingExperiment,
    this.summary = const SocialExperimentSummary(),
    this.isPsychoeducationDismissed = false,
    this.selectedTemplateIndex = 0,
    this.customMessageText = '',
    this.isLoading = false,
    this.errorMessage,
    this.lastFeedbackMessage,
  });

  final List<ReachOutContact> contacts;
  final List<SocialPredictionExperiment> experiments;
  final SocialPredictionExperiment? activePendingExperiment;
  final SocialExperimentSummary summary;
  final bool isPsychoeducationDismissed;
  final int selectedTemplateIndex;
  final String customMessageText;
  final bool isLoading;
  final String? errorMessage;
  final String? lastFeedbackMessage;

  bool get hasPendingOutcome => activePendingExperiment != null;
  bool get hasContacts => contacts.isNotEmpty;

  /// Current message text based on template selection or custom input.
  String get activeMessage {
    if (selectedTemplateIndex >= 0 && selectedTemplateIndex < kDefaultReachOutTemplates.length) {
      return kDefaultReachOutTemplates[selectedTemplateIndex];
    }
    return customMessageText;
  }

  /// Builds a compliant offline SMS URI intent.
  static Uri buildSmsUri({required String phoneNumber, required String message}) {
    final sanitizedPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    return Uri(
      scheme: 'sms',
      path: sanitizedPhone,
      queryParameters: message.isNotEmpty ? {'body': message} : null,
    );
  }

  LonelinessComfortState copyWith({
    List<ReachOutContact>? contacts,
    List<SocialPredictionExperiment>? experiments,
    SocialPredictionExperiment? activePendingExperiment,
    bool clearPendingExperiment = false,
    SocialExperimentSummary? summary,
    bool? isPsychoeducationDismissed,
    int? selectedTemplateIndex,
    String? customMessageText,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? lastFeedbackMessage,
    bool clearFeedbackMessage = false,
  }) {
    return LonelinessComfortState(
      contacts: contacts ?? this.contacts,
      experiments: experiments ?? this.experiments,
      activePendingExperiment: clearPendingExperiment
          ? null
          : (activePendingExperiment ?? this.activePendingExperiment),
      summary: summary ?? this.summary,
      isPsychoeducationDismissed:
          isPsychoeducationDismissed ?? this.isPsychoeducationDismissed,
      selectedTemplateIndex:
          selectedTemplateIndex ?? this.selectedTemplateIndex,
      customMessageText: customMessageText ?? this.customMessageText,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      lastFeedbackMessage: clearFeedbackMessage
          ? null
          : (lastFeedbackMessage ?? this.lastFeedbackMessage),
    );
  }
}
