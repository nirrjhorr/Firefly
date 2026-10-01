import 'dart:async';

/// Abstract port defining hardware/engine-agnostic speech-to-text recognition
/// capabilities for confidential offline journaling and voice dictation.
abstract class VoiceRecognitionPort {
  /// Stream of real-time partial speech recognition hypotheses as words are spoken.
  Stream<String> transcribePartial();

  /// Retrieves the committed, accumulated final transcription upon pause or stop.
  Future<String> transcribeFinal();

  /// Starts microphone capture and local offline speech recognition.
  Future<void> startListening();

  /// Stops audio capture and finalizes the transcription buffer.
  Future<void> stopListening();

  /// Whether speech recognition is currently active and listening to the microphone.
  bool get isListening;

  /// Stream of error messages if hardware or recognition encounters failure.
  Stream<String> get onError;

  /// Disposes background isolates, audio pipelines, and stream controllers.
  Future<void> dispose();
}
