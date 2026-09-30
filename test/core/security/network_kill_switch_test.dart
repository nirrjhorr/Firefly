import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:app.firefly/core/security/network_kill_switch.dart';

void main() {
  group('NetworkKillSwitch (Zero-Network Policy)', () {
    test('Throws UnsupportedError on any attempt to instantiate HttpClient', () {
      final override = FireflyHttpOverride();

      expect(
        () => override.createHttpClient(null),
        throwsA(isA<UnsupportedError>().having(
          (e) => e.message,
          'message',
          contains('NETWORK_KILL_SWITCH_ACTIVE'),
        )),
      );
    });

    test('HttpOverrides.global enforces blocking of network connections', () {
      HttpOverrides.global = FireflyHttpOverride();

      expect(
        () => HttpClient(),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
