import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:local_auth/local_auth.dart';
import 'package:app.firefly/core/security/biometric_guard.dart';
import 'package:app.firefly/core/security/key_manager.dart';
import 'package:app.firefly/core/security/network_kill_switch.dart';
import 'package:app.firefly/core/security/panic_cryptographic_service.dart';

class MockLocalAuthentication extends Mock implements LocalAuthentication {}
class MockKeyManager extends Mock implements KeyManager {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Install zero-network policy
    FireflyHttpOverride.install();
  });

  group('PanicCryptographicService - Signing & Zero Memory', () {
    late PanicCryptographicService service;

    setUp(() {
      service = PanicCryptographicService();
    });

    test('generates valid signed panic payload with HMAC signature', () async {
      final payload = await service.generateSignedPanicPayload(
        incidentNonce: 'test-incident-12345',
      );

      expect(payload.incidentId, 'test-incident-12345');
      expect(payload.isDecryptionKeyPurged, isTrue);
      expect(payload.deviceNonceHex.length, 24); // 12 bytes hex
      expect(payload.signatureHex.length, 64); // 32 bytes SHA256 hex
      expect(payload.timestampMs, greaterThan(0));

      final json = payload.toJson();
      expect(json['incidentId'], 'test-incident-12345');
      expect(json['isDecryptionKeyPurged'], isTrue);
    });

    test('generates unique cryptographic signatures for distinct nonces', () async {
      final payload1 = await service.generateSignedPanicPayload(incidentNonce: 'nonce-1');
      final payload2 = await service.generateSignedPanicPayload(incidentNonce: 'nonce-2');

      expect(payload1.signatureHex, isNot(equals(payload2.signatureHex)));
      expect(payload1.deviceNonceHex, isNot(equals(payload2.deviceNonceHex)));
    });
  });

  group('NFR Latency Benchmarking (< 100ms SLA)', () {
    late PanicCryptographicService service;
    late MockLocalAuthentication mockAuth;
    late MockKeyManager mockKeyManager;
    late BiometricGuard biometricGuard;

    setUp(() {
      service = PanicCryptographicService();
      mockAuth = MockLocalAuthentication();
      mockKeyManager = MockKeyManager();
      biometricGuard = BiometricGuard(mockAuth, mockKeyManager);
    });

    test('pipeline executes well within < 100ms SLA target', () async {
      int invalidatedCount = 0;
      final invalidators = [
        () => invalidatedCount++,
        () => invalidatedCount++,
        () => invalidatedCount++,
        () => invalidatedCount++,
      ];

      final latencyMs = await service.profileAndExecutePanicPipeline(
        biometricGuard: biometricGuard,
        providerInvalidators: invalidators,
      );

      expect(latencyMs, lessThan(100), reason: 'Panic purge latency must meet < 100ms SLA');
      expect(invalidatedCount, 4);
    });

    test('multiple consecutive panic purges maintain < 100ms SLA consistency', () async {
      final latencies = <int>[];
      for (int i = 0; i < 10; i++) {
        final latency = await service.profileAndExecutePanicPipeline(
          biometricGuard: biometricGuard,
          providerInvalidators: [() {}],
        );
        latencies.add(latency);
      }

      final maxLatency = latencies.reduce((a, b) => a > b ? a : b);
      final avgLatency = latencies.reduce((a, b) => a + b) / latencies.length;

      expect(maxLatency, lessThan(100));
      expect(avgLatency, lessThan(50));
    });
  });

  group('Zero Network Policy Hardening Audit', () {
    test('strictly catches and blocks outbound HTTP requests with SecurityException', () async {
      final client = HttpClient();
      expect(
        () => client.getUrl(Uri.parse('https://api.firefly-analytics.com/telemetry')),
        throwsA(isA<SecurityException>()),
      );
    });

    test('strictly catches and blocks raw socket egress', () async {
      expect(
        () => Socket.connect('8.8.8.8', 53),
        throwsA(isA<SecurityException>()),
      );
    });
  });
}
