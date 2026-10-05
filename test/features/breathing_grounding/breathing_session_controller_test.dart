import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firefly/core/contracts/audio_player_port.dart';
import 'package:firefly/core/contracts/haptics_port.dart';
import 'package:firefly/features/breathing_grounding/domain/models/breathing_session_state.dart';
import 'package:firefly/features/breathing_grounding/presentation/controllers/breathing_session_controller.dart';

class MockAudioPlayerPort extends Mock implements AudioPlayerPort {}

class MockHapticsPort extends Mock implements HapticsPort {}

void main() {
  group('BreathingSessionNotifier', () {
    late MockAudioPlayerPort mockAudioPlayer;
    late MockHapticsPort mockHaptics;
    late BreathingSessionNotifier notifier;

    setUp(() {
      mockAudioPlayer = MockAudioPlayerPort();
      mockHaptics = MockHapticsPort();

      when(() => mockAudioPlayer.loadLoopingAsset(any()))
          .thenAnswer((_) async {});
      when(() => mockAudioPlayer.fadeIn(
            duration: any(named: 'duration'),
            targetVolume: any(named: 'targetVolume'),
          )).thenAnswer((_) async {});
      when(() => mockAudioPlayer.fadeOut(
            duration: any(named: 'duration'),
          )).thenAnswer((_) async {});
      when(() => mockAudioPlayer.play()).thenAnswer((_) async {});
      when(() => mockAudioPlayer.pause()).thenAnswer((_) async {});
      when(() => mockAudioPlayer.stop()).thenAnswer((_) async {});
      when(() => mockAudioPlayer.dispose()).thenAnswer((_) async {});

      when(() => mockHaptics.phaseTransitionInhale())
          .thenAnswer((_) async {});
      when(() => mockHaptics.phaseTransitionExhale())
          .thenAnswer((_) async {});
      when(() => mockHaptics.groundingConfirm()).thenAnswer((_) async {});

      // Use shorter cadence for deterministic and fast unit testing
      notifier = BreathingSessionNotifier(
        audioPlayer: mockAudioPlayer,
        haptics: mockHaptics,
        inhaleDuration: const Duration(milliseconds: 100),
        exhaleDuration: const Duration(milliseconds: 200),
        tickerInterval: const Duration(milliseconds: 25),
        defaultSoundscape: RespirationSoundscapes.cyclicSighAmbience,
      );
    });

    tearDown(() {
      notifier.dispose();
    });

    test('Initial state is idle with 0 progress and inhale phase', () {
      expect(notifier.state.phase, equals(BreathingPhase.inhale));
      expect(notifier.state.phaseProgress, equals(0.0));
      expect(notifier.state.cycleCount, equals(0));
      expect(notifier.state.elapsedSeconds, equals(0));
      expect(notifier.state.isActive, isFalse);
      expect(notifier.state.soundscape,
          equals(RespirationSoundscapes.cyclicSighAmbience));
    });

    test('start() activates session, triggers initial inhale haptic and audio',
        () async {
      await notifier.start();

      expect(notifier.state.isActive, isTrue);
      verify(() => mockHaptics.phaseTransitionInhale()).called(1);
      verify(() => mockAudioPlayer.loadLoopingAsset(any())).called(1);
      verify(() => mockAudioPlayer.play()).called(1);
    });

    test('Ticks advance phase progress from inhale to exhale and increment cycles',
        () async {
      await notifier.start();

      // Wait 50ms (2 ticks out of 100ms inhale) -> progress ~0.5
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(notifier.state.phase, equals(BreathingPhase.inhale));
      expect(notifier.state.phaseProgress, greaterThan(0.2));

      // Wait until inhale completes and exhale begins (> 100ms)
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(notifier.state.phase, equals(BreathingPhase.exhale));
      verify(() => mockHaptics.phaseTransitionExhale()).called(1);

      // Wait until exhale completes (> 200ms) -> should cycle back to inhale and increment cycleCount
      await Future<void>.delayed(const Duration(milliseconds: 220));
      expect(notifier.state.phase, equals(BreathingPhase.inhale));
      expect(notifier.state.cycleCount, equals(1));
      verify(() => mockHaptics.phaseTransitionInhale()).called(2);
    });

    test('pause() and resume() manage ticker and audio smoothly without losing progress',
        () async {
      await notifier.start();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await notifier.pause();
      expect(notifier.state.isActive, isFalse);
      verify(() => mockAudioPlayer.fadeOut(duration: any(named: 'duration')))
          .called(1);

      final pausedProgress = notifier.state.phaseProgress;

      // Ensure ticker paused
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(notifier.state.phaseProgress, equals(pausedProgress));

      // Resume
      await notifier.resume();
      expect(notifier.state.isActive, isTrue);
      verify(() => mockAudioPlayer.fadeIn(duration: any(named: 'duration')))
          .called(2);
    });

    test('stop() resets all state parameters and halts audio', () async {
      await notifier.start();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await notifier.stop();

      expect(notifier.state.isActive, isFalse);
      expect(notifier.state.phase, equals(BreathingPhase.inhale));
      expect(notifier.state.phaseProgress, equals(0.0));
      expect(notifier.state.cycleCount, equals(0));
      verify(() => mockAudioPlayer.stop()).called(1);
    });

    test('Soundscape dynamic changes load new assets or mute cleanly', () async {
      await notifier.start();

      await notifier.setSoundscape(RespirationSoundscapes.gentleRain);
      expect(notifier.state.soundscape, equals(RespirationSoundscapes.gentleRain));
      verify(() => mockAudioPlayer.loadLoopingAsset(
          'assets/audio/gentle_rain.mp3')).called(1);

      await notifier.setSoundscape(null);
      expect(notifier.state.soundscape, isNull);
      verify(() => mockAudioPlayer.stop()).called(1);
    });

    test('Silent error resilience when audio or haptic throws', () async {
      when(() => mockAudioPlayer.play())
          .thenThrow(Exception('Audio stream rejected'));
      when(() => mockHaptics.phaseTransitionInhale())
          .thenThrow(Exception('Haptics failed'));

      // Should complete without throwing
      await expectLater(notifier.start(), completes);
      expect(notifier.state.isActive, isTrue);
    });

    test('setTechnique() switches active technique and resets phase to inhale', () {
      notifier.setTechnique(BreathingTechnique.boxBreathing);
      expect(notifier.state.technique, equals(BreathingTechnique.boxBreathing));
      expect(notifier.state.phase, equals(BreathingPhase.inhale));
      expect(notifier.state.phaseProgress, equals(0.0));

      notifier.setTechnique(BreathingTechnique.relax478);
      expect(notifier.state.technique, equals(BreathingTechnique.relax478));
      expect(notifier.state.phase, equals(BreathingPhase.inhale));
    });
  });
}
