import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firefly/features/breathing_grounding/domain/models/breathing_session_state.dart';
import 'package:firefly/features/breathing_grounding/presentation/widgets/cyclic_sigh_bloom_painter.dart';
import 'package:firefly/features/breathing_grounding/presentation/widgets/cyclic_sigh_bloom_visualizer.dart';

void main() {
  group('CyclicSighBloomPainter', () {
    test('Calculates correct radius bounds during inhale and exhale', () {
      final inhaleStart = CyclicSighBloomPainter(
        progress: 0.0,
        phase: BreathingPhase.inhale,
      );
      expect(inhaleStart.computeRadius(), closeTo(50.0, 0.1));

      final inhalePeak = CyclicSighBloomPainter(
        progress: 1.0,
        phase: BreathingPhase.inhale,
      );
      expect(inhalePeak.computeRadius(), closeTo(120.0, 0.1));

      final exhaleStart = CyclicSighBloomPainter(
        progress: 0.0,
        phase: BreathingPhase.exhale,
      );
      expect(exhaleStart.computeRadius(), closeTo(120.0, 0.1));

      final exhaleEnd = CyclicSighBloomPainter(
        progress: 1.0,
        phase: BreathingPhase.exhale,
      );
      expect(exhaleEnd.computeRadius(), closeTo(50.0, 0.1));
    });

    test('Reduced motion collapses radius to static 85.0dp', () {
      final reducedAtStart = CyclicSighBloomPainter(
        progress: 0.0,
        phase: BreathingPhase.inhale,
        reducedMotion: true,
      );
      expect(reducedAtStart.computeRadius(), equals(85.0));

      final reducedAtPeak = CyclicSighBloomPainter(
        progress: 1.0,
        phase: BreathingPhase.inhale,
        reducedMotion: true,
      );
      expect(reducedAtPeak.computeRadius(), equals(85.0));
    });

    test('Color transition shifts toward inhale sage and exhale dusk', () {
      const sage = Color(0xFF4A7862);
      const dusk = Color(0xFF3B5B6C);

      final inhalePeak = CyclicSighBloomPainter(
        progress: 1.0,
        phase: BreathingPhase.inhale,
        inhaleColor: sage,
        exhaleColor: dusk,
      );
      expect(inhalePeak.computeActiveColor().value, equals(sage.value));

      final exhaleEnd = CyclicSighBloomPainter(
        progress: 1.0,
        phase: BreathingPhase.exhale,
        inhaleColor: sage,
        exhaleColor: dusk,
      );
      expect(exhaleEnd.computeActiveColor().value, equals(dusk.value));
    });

    test('shouldRepaint returns false when properties are identical', () {
      final painter1 = CyclicSighBloomPainter(
        progress: 0.5,
        phase: BreathingPhase.inhale,
      );
      final painter2 = CyclicSighBloomPainter(
        progress: 0.5,
        phase: BreathingPhase.inhale,
      );

      expect(painter1.shouldRepaint(painter2), isFalse);
    });

    test('shouldRepaint returns true when progress or phase changes', () {
      final painter1 = CyclicSighBloomPainter(
        progress: 0.5,
        phase: BreathingPhase.inhale,
      );
      final painter2 = CyclicSighBloomPainter(
        progress: 0.6,
        phase: BreathingPhase.inhale,
      );
      final painter3 = CyclicSighBloomPainter(
        progress: 0.5,
        phase: BreathingPhase.exhale,
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
      expect(painter1.shouldRepaint(painter3), isTrue);
    });
  });

  group('CyclicSighBloomVisualizer Widget', () {
    testWidgets('Renders bloom visualizer with centered child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CyclicSighBloomVisualizer(
                progress: 0.5,
                phase: BreathingPhase.inhale,
                size: 300,
                child: Text('Inhale'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CyclicSighBloomVisualizer), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('Inhale'), findsOneWidget);
    });

    testWidgets('Respects system MediaQuery disableAnimations setting', (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: CyclicSighBloomVisualizer(
                  progress: 0.8,
                  phase: BreathingPhase.inhale,
                ),
              ),
            ),
          ),
        ),
      );

      final visualizerFinder = find.byType(CyclicSighBloomVisualizer);
      expect(visualizerFinder, findsOneWidget);

      final customPaint = tester.widget<CustomPaint>(
        find.descendant(of: visualizerFinder, matching: find.byType(CustomPaint)),
      );
      final painter = customPaint.painter as CyclicSighBloomPainter;
      expect(painter.reducedMotion, isTrue);
      expect(painter.computeRadius(), equals(85.0));
    });
  });
}
