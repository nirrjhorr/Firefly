import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app.firefly/core/contracts/audio_player_port.dart';
import 'package:app.firefly/core/contracts/haptics_port.dart';
import 'package:app.firefly/core/theme/app_theme.dart';
import 'package:app.firefly/features/breathing_grounding/presentation/controllers/hardware_providers.dart';
import 'package:app.firefly/features/breathing_grounding/presentation/screens/breathing_grounding_screen.dart';
import 'package:app.firefly/features/breathing_grounding/presentation/widgets/cyclic_sigh_bloom_visualizer.dart';
import 'package:app.firefly/features/breathing_grounding/presentation/widgets/grounding_prompt_card.dart';
import 'package:app.firefly/features/breathing_grounding/presentation/widgets/soundscape_selector_sheet.dart';
import 'package:app.firefly/shared/widgets/sos_overlay_button.dart';

class MockAudioPlayerPort extends Mock implements AudioPlayerPort {}

class MockHapticsPort extends Mock implements HapticsPort {}

void main() {
  group('BreathingGroundingScreen', () {
    late MockAudioPlayerPort mockAudioPlayer;
    late MockHapticsPort mockHaptics;

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
    });

    Widget createScreen({
      String? initialMode,
      bool showSosOverlay = true,
    }) {
      return ProviderScope(
        overrides: [
          audioPlayerPortProvider.overrideWithValue(mockAudioPlayer),
          hapticsPortProvider.overrideWithValue(mockHaptics),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: BreathingGroundingScreen(
            initialMode: initialMode,
            showSosOverlay: showSosOverlay,
          ),
        ),
      );
    }

    testWidgets('Renders cyclic sighing flow by default when initialMode is null',
        (tester) async {
      await tester.pumpWidget(createScreen());

      expect(find.text('Breathe'), findsOneWidget);
      expect(find.text('4s Inhale · 8s Exhale'), findsOneWidget);
      expect(find.byType(CyclicSighBloomVisualizer), findsOneWidget);
      expect(find.text('Begin Breathing'), findsOneWidget);
      expect(find.text('End Session'), findsOneWidget);
      expect(find.byType(SosOverlayButton), findsOneWidget);
    });

    testWidgets(
        'Renders 5-4-3-2-1 grounding flow when initialMode is "grounding"',
        (tester) async {
      await tester.pumpWidget(createScreen(initialMode: 'grounding'));

      expect(find.byType(GroundingPromptCard), findsOneWidget);
      expect(find.text('STEP 1 OF 5'), findsOneWidget);
      expect(find.text('5 Things you can see'), findsOneWidget);
    });

    testWidgets('Switching mode tabs toggles between Breathing and Grounding',
        (tester) async {
      await tester.pumpWidget(createScreen());

      // Initially breathing
      expect(find.byType(CyclicSighBloomVisualizer), findsOneWidget);
      expect(find.byType(GroundingPromptCard), findsNothing);

      // Tap on '5-4-3-2-1' mode tab
      await tester.tap(find.text('5-4-3-2-1'));
      await tester.pumpAndSettle();

      expect(find.byType(GroundingPromptCard), findsOneWidget);
      expect(find.byType(CyclicSighBloomVisualizer), findsNothing);

      // Tap on 'Breathing' mode tab
      await tester.tap(find.text('Breathing'));
      await tester.pumpAndSettle();

      expect(find.byType(CyclicSighBloomVisualizer), findsOneWidget);
      expect(find.byType(GroundingPromptCard), findsNothing);
    });

    testWidgets('Tapping Begin Breathing starts session and changes button to Pause',
        (tester) async {
      await tester.pumpWidget(createScreen());

      await tester.tap(find.byKey(const Key('breathing_play_pause_button')));
      await tester.pump();

      expect(find.text('Pause'), findsOneWidget);
      verify(() => mockHaptics.phaseTransitionInhale()).called(1);
      verify(() => mockAudioPlayer.play()).called(1);
    });

    testWidgets('Tapping soundscape button opens soundscape selector sheet',
        (tester) async {
      await tester.pumpWidget(createScreen());

      final soundscapeBtn =
          find.byKey(const Key('breathing_soundscape_button'));
      expect(soundscapeBtn, findsOneWidget);

      await tester.tap(soundscapeBtn);
      await tester.pumpAndSettle();

      expect(find.byType(SoundscapeSelectorSheet), findsOneWidget);
      expect(find.text('Ambient Soundscape'), findsOneWidget);
      expect(find.text('Cyclic Ambience'), findsOneWidget);
      expect(find.text('Gentle Rain'), findsOneWidget);
      expect(find.text('Grounding Chimes'), findsOneWidget);
      expect(find.text('Mute / Silence'), findsOneWidget);

      // Tap Gentle Rain
      await tester.tap(find.text('Gentle Rain'));
      await tester.pumpAndSettle();

      expect(find.byType(SoundscapeSelectorSheet), findsNothing);
    });

    testWidgets('Ending session calls stop on audio and resets session',
        (tester) async {
      await tester.pumpWidget(createScreen());

      await tester.tap(find.byKey(const Key('breathing_play_pause_button')));
      await tester.pump();

      await tester.tap(find.byKey(const Key('breathing_end_session_button')));
      await tester.pump();

      verify(() => mockAudioPlayer.stop()).called(greaterThanOrEqualTo(1));
    });
  });
}
