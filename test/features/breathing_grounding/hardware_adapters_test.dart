import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firefly/core/contracts/audio_player_port.dart';
import 'package:firefly/core/contracts/haptics_port.dart';
import 'package:firefly/features/breathing_grounding/data/adapters/flutter_haptics_adapter.dart';
import 'package:firefly/features/breathing_grounding/data/adapters/just_audio_player_adapter.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  group('FlutterHapticsAdapter', () {
    test('implements HapticsPort', () {
      final adapter = FlutterHapticsAdapter();
      expect(adapter, isA<HapticsPort>());
    });

    test('phaseTransitionInhale triggers double light impact', () async {
      int impactCount = 0;
      final adapter = FlutterHapticsAdapter(
        lightImpact: () async {
          impactCount++;
        },
      );

      await adapter.phaseTransitionInhale();
      expect(impactCount, equals(2));
    });

    test('phaseTransitionExhale triggers single light impact', () async {
      int impactCount = 0;
      final adapter = FlutterHapticsAdapter(
        lightImpact: () async {
          impactCount++;
        },
      );

      await adapter.phaseTransitionExhale();
      expect(impactCount, equals(1));
    });

    test('groundingConfirm triggers selection click', () async {
      int clickCount = 0;
      final adapter = FlutterHapticsAdapter(
        selectionClick: () async {
          clickCount++;
        },
      );

      await adapter.groundingConfirm();
      expect(clickCount, equals(1));
    });

    test('recovers silently from exceptions without throwing', () async {
      final adapter = FlutterHapticsAdapter(
        lightImpact: () async {
          throw Exception('Hardware vibration motor unavailable');
        },
        selectionClick: () async {
          throw Exception('Haptic feedback rejected');
        },
      );

      await expectLater(adapter.phaseTransitionInhale(), completes);
      await expectLater(adapter.phaseTransitionExhale(), completes);
      await expectLater(adapter.groundingConfirm(), completes);
    });
  });

  group('JustAudioPlayerAdapter', () {
    late MockAudioPlayer mockPlayer;
    late JustAudioPlayerAdapter adapter;

    setUp(() {
      mockPlayer = MockAudioPlayer();
      when(() => mockPlayer.playing).thenReturn(false);
      when(() => mockPlayer.setAsset(any()))
          .thenAnswer((_) async => const Duration(seconds: 60));
      when(() => mockPlayer.setLoopMode(any())).thenAnswer((_) async {});
      when(() => mockPlayer.play()).thenAnswer((_) async {});
      when(() => mockPlayer.pause()).thenAnswer((_) async {});
      when(() => mockPlayer.stop()).thenAnswer((_) async {});
      when(() => mockPlayer.setVolume(any())).thenAnswer((_) async {});
      when(() => mockPlayer.dispose()).thenAnswer((_) async {});

      adapter = JustAudioPlayerAdapter(player: mockPlayer);
    });

    test('implements AudioPlayerPort', () {
      expect(adapter, isA<AudioPlayerPort>());
    });

    test('loadLoopingAsset configures asset and looping mode', () async {
      await adapter.loadLoopingAsset('assets/audio/cyclic_sigh_ambience.mp3');
      verify(() => mockPlayer.setAsset('assets/audio/cyclic_sigh_ambience.mp3'))
          .called(1);
      verify(() => mockPlayer.setLoopMode(LoopMode.one)).called(1);
    });

    test('play, pause, and stop delegate to player', () async {
      await adapter.play();
      verify(() => mockPlayer.play()).called(1);

      await adapter.pause();
      verify(() => mockPlayer.pause()).called(1);

      await adapter.stop();
      verify(() => mockPlayer.stop()).called(1);
    });

    test('setVolume updates volume and delegates clamped value to player',
        () async {
      await adapter.setVolume(0.7);
      expect(adapter.volume, equals(0.7));
      verify(() => mockPlayer.setVolume(0.7)).called(1);

      await adapter.setVolume(1.5);
      expect(adapter.volume, equals(1.0));
      verify(() => mockPlayer.setVolume(1.0)).called(1);
    });

    test('fadeIn ramps volume smoothly to target', () async {
      await adapter.setVolume(0.0);
      await adapter.fadeIn(
          duration: const Duration(milliseconds: 50), targetVolume: 1.0);
      expect(adapter.volume, equals(1.0));
      verify(() => mockPlayer.setVolume(any())).called(greaterThan(1));
    });

    test('fadeOut ramps volume down and pauses', () async {
      await adapter.setVolume(1.0);
      await adapter.fadeOut(duration: const Duration(milliseconds: 50));
      expect(adapter.volume, equals(0.0));
      verify(() => mockPlayer.pause()).called(1);
    });

    test('silent failure on audio errors during loading or playback', () async {
      when(() => mockPlayer.setAsset(any()))
          .thenThrow(Exception('Asset file not found'));
      when(() => mockPlayer.play())
          .thenThrow(Exception('Audio session decode error'));

      await expectLater(
          adapter.loadLoopingAsset('assets/audio/missing.mp3'), completes);
      await expectLater(adapter.play(), completes);
    });

    test('dispose safely closes player resources', () async {
      await adapter.dispose();
      verify(() => mockPlayer.dispose()).called(1);

      // Subsequent calls after dispose are no-ops
      await adapter.play();
      verifyNever(() => mockPlayer.play());
    });
  });
}
