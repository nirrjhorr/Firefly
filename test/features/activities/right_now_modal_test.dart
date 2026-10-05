import 'package:flutter_test/flutter_test.dart';
import 'package:firefly/core/routing/app_routes.dart';
import 'package:firefly/features/activities/presentation/widgets/right_now_modal.dart';

void main() {
  group('RightNowModal Anchors Specification Tests (FR-10)', () {
    test('contains exactly 12 acute distress anchors', () {
      expect(kRightNowAnchors.length, 12);
    });

    test('all 12 anchors have valid non-empty fields and routes', () {
      for (final anchor in kRightNowAnchors) {
        expect(anchor.id, isNotEmpty);
        expect(anchor.title, isNotEmpty);
        expect(anchor.subtitle, isNotEmpty);
        expect(anchor.iconKey, isNotEmpty);
        expect(anchor.route, isNotEmpty);
        expect(anchor.route.startsWith('/'), isTrue, reason: '${anchor.id} route must start with /');
      }
    });

    test('verifies specific critical distress mappings', () {
      final calmDown = kRightNowAnchors.firstWhere((a) => a.id == 'calm_down');
      expect(calmDown.title, 'I need to calm down');
      expect(calmDown.route, AppRoutes.breathe);

      final cantStopThinking = kRightNowAnchors.firstWhere((a) => a.id == 'cant_stop_thinking');
      expect(cantStopThinking.title, 'I cannot stop thinking');

      final overwhelmed = kRightNowAnchors.firstWhere((a) => a.id == 'overwhelmed');
      expect(overwhelmed.title, 'I feel overwhelmed');
      expect(overwhelmed.route, AppRoutes.breathe);

      final connect = kRightNowAnchors.firstWhere((a) => a.id == 'connect');
      expect(connect.title, 'I want to connect');
      expect(connect.route, AppRoutes.loneliness);

      final sleep = kRightNowAnchors.firstWhere((a) => a.id == 'want_to_sleep');
      expect(sleep.title, 'I want to sleep');
      expect(sleep.route, AppRoutes.soundscapes);

      final express = kRightNowAnchors.firstWhere((a) => a.id == 'express_feeling');
      expect(express.title, 'I want to express something');
      expect(express.route, AppRoutes.journal);
    });
  });
}
