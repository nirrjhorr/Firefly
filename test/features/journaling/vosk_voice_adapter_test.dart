import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app.firefly/core/contracts/voice_recognition_port.dart';
import 'package:app.firefly/features/journaling/data/adapters/vosk_voice_adapter.dart';

void main() {
  group('VoskVoiceAdapter & VoiceRecognitionPort Contract', () {
    test('Implements VoiceRecognitionPort interface with default constructor', () {
      final adapter = VoskVoiceAdapter();
      expect(adapter, isA<VoiceRecognitionPort>());
      expect(adapter.isListening, isFalse);
      adapter.dispose();
    });

    test('isListening reflects active state during startListening and stopListening', () async {
      final adapter = VoskVoiceAdapter();
      expect(adapter.isListening, isFalse);

      await adapter.startListening();
      // On desktop/test fallback, startListening activates listening cleanly
      expect(adapter.isListening, isTrue);

      await adapter.stopListening();
      expect(adapter.isListening, isFalse);

      await adapter.dispose();
    });

    test('transcribePartial streams speech hypotheses without duplicate word accumulation', () async {
      final partialStreamController = StreamController<String>.broadcast();
      final adapter = VoskVoiceAdapter.withHandlers(
        mockPartialStream: partialStreamController.stream,
      );

      final receivedPartials = <String>[];
      final subscription = adapter.transcribePartial().listen(receivedPartials.add);

      await adapter.startListening();

      // STT engines emit expanding phrases for partial hypotheses
      partialStreamController.add('I');
      partialStreamController.add('I am');
      partialStreamController.add('I am feeling');
      partialStreamController.add('I am feeling peaceful');

      await pumpEventQueue();

      expect(receivedPartials, equals([
        'I',
        'I am',
        'I am feeling',
        'I am feeling peaceful',
      ]));

      // transcribeFinal must return the clean accumulated hypothesis, NOT "I I am I am feeling..."
      final finalText = await adapter.transcribeFinal();
      expect(finalText, equals('I am feeling peaceful'));

      await adapter.stopListening();
      await subscription.cancel();
      await partialStreamController.close();
      await adapter.dispose();
    });

    test('Transcripts reset cleanly between successive listening sessions', () async {
      final partialStreamController = StreamController<String>.broadcast();
      final adapter = VoskVoiceAdapter.withHandlers(
        mockPartialStream: partialStreamController.stream,
      );

      // Session 1
      await adapter.startListening();
      partialStreamController.add('First thought');
      await pumpEventQueue();
      await adapter.stopListening();

      final session1Final = await adapter.transcribeFinal();
      expect(session1Final, equals('First thought'));

      // Session 2 should start empty
      await adapter.startListening();
      final beforeSpokenSession2 = await adapter.transcribeFinal();
      expect(beforeSpokenSession2, equals(''));

      partialStreamController.add('Second separate thought');
      await pumpEventQueue();
      await adapter.stopListening();

      final session2Final = await adapter.transcribeFinal();
      expect(session2Final, equals('Second separate thought'));

      await partialStreamController.close();
      await adapter.dispose();
    });

    test('Errors in speech recognition are piped to onError stream', () async {
      final partialStreamController = StreamController<String>.broadcast();
      final adapter = VoskVoiceAdapter.withHandlers(
        mockPartialStream: partialStreamController.stream,
      );

      final receivedErrors = <String>[];
      final errorSub = adapter.onError.listen(receivedErrors.add);

      await adapter.startListening();

      partialStreamController.addError('Microphone disconnected');
      await pumpEventQueue();

      expect(receivedErrors, contains('Microphone disconnected'));

      await adapter.stopListening();
      await errorSub.cancel();
      await partialStreamController.close();
      await adapter.dispose();
    });

    test('State safety: isListening resets to false if startup fails', () async {
      final adapter = VoskVoiceAdapter.withHandlers(
        onStartListening: () async {
          throw Exception('Microphone permission denied');
        },
      );

      expect(adapter.isListening, isFalse);
      await adapter.startListening();
      expect(adapter.isListening, isFalse);

      await adapter.dispose();
    });

    test('Custom start and stop callbacks are invoked during listening lifecycle', () async {
      int startCount = 0;
      int stopCount = 0;

      final adapter = VoskVoiceAdapter.withHandlers(
        onStartListening: () async => startCount++,
        onStopListening: () async => stopCount++,
      );

      await adapter.startListening();
      expect(startCount, equals(1));
      expect(stopCount, equals(0));

      await adapter.stopListening();
      expect(startCount, equals(1));
      expect(stopCount, equals(1));

      await adapter.dispose();
    });

    test('Idempotency: multiple startListening or stopListening calls are safe', () async {
      final adapter = VoskVoiceAdapter();

      await adapter.startListening();
      await adapter.startListening(); // duplicate call
      expect(adapter.isListening, isTrue);

      await adapter.stopListening();
      await adapter.stopListening(); // duplicate call
      expect(adapter.isListening, isFalse);

      await adapter.dispose();
      await adapter.dispose(); // duplicate dispose
    });

    test('Dispose cleans up resources and prevents new listening sessions', () async {
      final adapter = VoskVoiceAdapter();
      await adapter.startListening();
      expect(adapter.isListening, isTrue);

      await adapter.dispose();
      expect(adapter.isListening, isFalse);

      // Attempting to start listening after dispose should be a no-op
      await adapter.startListening();
      expect(adapter.isListening, isFalse);
    });

    test('Riverpod provider instantiates and auto-disposes adapter', () {
      final container = ProviderContainer();
      final port = container.read(voiceRecognitionPortProvider);
      expect(port, isA<VoiceRecognitionPort>());
      container.dispose();
    });
  });
}
