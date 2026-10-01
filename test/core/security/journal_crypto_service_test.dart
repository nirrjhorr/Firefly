import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firefly/core/security/journal_crypto_service.dart';

void main() {
  group('JournalCryptoService (Application-Layer AES-256-GCM Double Encryption)', () {
    late JournalCryptoService cryptoService;
    const testMasterKey = 'dGhpcy1pcy1hLXNlY3VyZS0yNTYtYml0LW1hc3Rlci1rZXk='; // 32 bytes base64
    const altMasterKey = 'YW5vdGhlci1zZWN1cmUtMjU2LWJpdC1tYXN0ZXIta2V5LTI=';

    setUp(() {
      cryptoService = JournalCryptoService();
    });

    test('Round-trip encryption and decryption restores exact plaintext', () async {
      const plaintext = 'I feel overwhelming grief today, but I am writing this to breathe.';

      final encryptedBase64 = await cryptoService.encrypt(
        plaintext: plaintext,
        masterKey: testMasterKey,
      );

      expect(encryptedBase64, isNotEmpty);
      expect(encryptedBase64, isNot(equals(plaintext)));

      final decrypted = await cryptoService.decrypt(
        encryptedPayloadBase64: encryptedBase64,
        masterKey: testMasterKey,
      );

      expect(decrypted, equals(plaintext));
    });

    test('Round-trip encryption handles multi-line unsent letters, Unicode, and emojis', () async {
      const complexText = '''
Dear Mom,
There are words I never had the courage to say out loud:
"I forgive you, and I also need to forgive myself." 🕊️🌿
日本語のテキストもテストします。
Everything is quiet now.
''';

      final encryptedBase64 = await cryptoService.encrypt(
        plaintext: complexText,
        masterKey: testMasterKey,
      );

      final decrypted = await cryptoService.decrypt(
        encryptedPayloadBase64: encryptedBase64,
        masterKey: testMasterKey,
      );

      expect(decrypted, equals(complexText));
    });

    test('Round-trip encryption supports empty string input', () async {
      const emptyText = '';

      final encryptedBase64 = await cryptoService.encrypt(
        plaintext: emptyText,
        masterKey: testMasterKey,
      );

      final decrypted = await cryptoService.decrypt(
        encryptedPayloadBase64: encryptedBase64,
        masterKey: testMasterKey,
      );

      expect(decrypted, equals(emptyText));
    });

    test('Round-trip raw bytes encryption and decryption (encryptBytes / decryptBytes)', () async {
      final rawAudioBytes = Uint8List.fromList([0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0]);

      final payloadBytes = await cryptoService.encryptBytes(
        plaintextBytes: rawAudioBytes,
        masterKey: testMasterKey,
      );

      expect(payloadBytes.length, greaterThanOrEqualTo(JournalCryptoService.minPayloadLength));

      final decryptedBytes = await cryptoService.decryptBytes(
        payloadBytes: payloadBytes,
        masterKey: testMasterKey,
      );

      expect(decryptedBytes, equals(rawAudioBytes));
    });

    test('Consecutive encryptions of identical plaintext produce distinct ciphertexts (unique nonces)', () async {
      const text = 'Same emotional state recorded twice.';

      final encrypted1 = await cryptoService.encrypt(
        plaintext: text,
        masterKey: testMasterKey,
      );
      final encrypted2 = await cryptoService.encrypt(
        plaintext: text,
        masterKey: testMasterKey,
      );

      expect(encrypted1, isNot(equals(encrypted2)));

      final dec1 = await cryptoService.decrypt(encryptedPayloadBase64: encrypted1, masterKey: testMasterKey);
      final dec2 = await cryptoService.decrypt(encryptedPayloadBase64: encrypted2, masterKey: testMasterKey);

      expect(dec1, equals(text));
      expect(dec2, equals(text));
    });

    test('Custom nonce validation enforces exact 12-byte length', () async {
      final invalidNonce = Uint8List(8); // Invalid: 8 bytes instead of 12

      expect(
        () async => await cryptoService.encrypt(
          plaintext: 'Test',
          masterKey: testMasterKey,
          customNonce: invalidNonce,
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('must be exactly 12 bytes'),
        )),
      );

      final validNonce = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
      final encrypted = await cryptoService.encrypt(
        plaintext: 'Valid nonce test',
        masterKey: testMasterKey,
        customNonce: validNonce,
      );
      final decrypted = await cryptoService.decrypt(
        encryptedPayloadBase64: encrypted,
        masterKey: testMasterKey,
      );
      expect(decrypted, equals('Valid nonce test'));
    });

    test('Decryption fails and throws JournalCryptoException when ciphertext is tampered with', () async {
      const plaintext = 'Unsent letter containing private thoughts.';
      final encryptedBase64 = await cryptoService.encrypt(
        plaintext: plaintext,
        masterKey: testMasterKey,
      );

      final rawBytes = base64Decode(encryptedBase64);
      // Alter byte in the ciphertext body (after 12-byte nonce, before 16-byte MAC)
      final tamperedIndex = JournalCryptoService.nonceLength + 1;
      rawBytes[tamperedIndex] ^= 0xFF;

      final tamperedBase64 = base64Encode(rawBytes);

      expect(
        () async => await cryptoService.decrypt(
          encryptedPayloadBase64: tamperedBase64,
          masterKey: testMasterKey,
        ),
        throwsA(isA<JournalCryptoException>()),
      );
    });

    test('Decryption fails and throws JournalCryptoException when MAC authentication tag is tampered with', () async {
      const plaintext = 'Sensitive letter content.';
      final encryptedBase64 = await cryptoService.encrypt(
        plaintext: plaintext,
        masterKey: testMasterKey,
      );

      final rawBytes = base64Decode(encryptedBase64);
      // Alter byte in the 16-byte MAC tag at the end
      rawBytes[rawBytes.length - 1] ^= 0x55;

      final tamperedBase64 = base64Encode(rawBytes);

      expect(
        () async => await cryptoService.decrypt(
          encryptedPayloadBase64: tamperedBase64,
          masterKey: testMasterKey,
        ),
        throwsA(isA<JournalCryptoException>()),
      );
    });

    test('Decryption fails and throws JournalCryptoException when nonce is altered', () async {
      const plaintext = 'Testing nonce tampering resistance.';
      final encryptedBase64 = await cryptoService.encrypt(
        plaintext: plaintext,
        masterKey: testMasterKey,
      );

      final rawBytes = base64Decode(encryptedBase64);
      // Alter the first byte of the 12-byte nonce
      rawBytes[0] ^= 0xAA;

      final tamperedBase64 = base64Encode(rawBytes);

      expect(
        () async => await cryptoService.decrypt(
          encryptedPayloadBase64: tamperedBase64,
          masterKey: testMasterKey,
        ),
        throwsA(isA<JournalCryptoException>()),
      );
    });

    test('Decryption fails with a mismatched master key throwing JournalCryptoException', () async {
      const plaintext = 'Encrypted with Key A, attempting decryption with Key B.';
      final encryptedBase64 = await cryptoService.encrypt(
        plaintext: plaintext,
        masterKey: testMasterKey,
      );

      expect(
        () async => await cryptoService.decrypt(
          encryptedPayloadBase64: encryptedBase64,
          masterKey: altMasterKey,
        ),
        throwsA(isA<JournalCryptoException>()),
      );
    });

    test('Decryption throws JournalCryptoException when base64 is malformed or payload is too short', () async {
      // Malformed base64
      expect(
        () async => await cryptoService.decrypt(
          encryptedPayloadBase64: 'Not-Valid-Base64!@#',
          masterKey: testMasterKey,
        ),
        throwsA(isA<JournalCryptoException>().having(
          (e) => e.message,
          'message',
          contains('Invalid base64'),
        )),
      );

      // Minimum is 12 (nonce) + 16 (MAC) = 28 bytes
      final tooShortBytes = Uint8List(20);
      final tooShortBase64 = base64Encode(tooShortBytes);

      expect(
        () async => await cryptoService.decrypt(
          encryptedPayloadBase64: tooShortBase64,
          masterKey: testMasterKey,
        ),
        throwsA(isA<JournalCryptoException>().having(
          (e) => e.message,
          'message',
          contains('below minimum'),
        )),
      );
    });

    test('Authenticated Additional Data (AAD) binds encryption to record metadata', () async {
      const entryId = 'journal-entry-uuid-1234';
      final aadBytes = utf8.encode(entryId);

      final encrypted = await cryptoService.encrypt(
        plaintext: 'Bound to entryId',
        masterKey: testMasterKey,
        aad: aadBytes,
      );

      // Decrypting with correct AAD succeeds
      final decrypted = await cryptoService.decrypt(
        encryptedPayloadBase64: encrypted,
        masterKey: testMasterKey,
        aad: aadBytes,
      );
      expect(decrypted, equals('Bound to entryId'));

      // Decrypting with swapped/mismatched AAD fails
      final wrongAadBytes = utf8.encode('journal-entry-uuid-9999');
      expect(
        () async => await cryptoService.decrypt(
          encryptedPayloadBase64: encrypted,
          masterKey: testMasterKey,
          aad: wrongAadBytes,
        ),
        throwsA(isA<JournalCryptoException>()),
      );
    });

    test('HKDF subkey derivation provides domain separation across different contexts and salts', () async {
      final subkeyV1 = await cryptoService.deriveSubkey(
        masterKey: testMasterKey,
        context: 'firefly-journal-content-v1',
      );
      final subkeyV2 = await cryptoService.deriveSubkey(
        masterKey: testMasterKey,
        context: 'firefly-journal-content-v2',
      );
      final subkeySalted = await cryptoService.deriveSubkey(
        masterKey: testMasterKey,
        context: 'firefly-journal-content-v1',
        salt: [1, 2, 3, 4, 5, 6, 7, 8],
      );

      final bytesV1 = await subkeyV1.extractBytes();
      final bytesV2 = await subkeyV2.extractBytes();
      final bytesSalted = await subkeySalted.extractBytes();

      expect(bytesV1.length, equals(32)); // 256 bits
      expect(bytesV2.length, equals(32));
      expect(bytesSalted.length, equals(32));
      expect(bytesV1, isNot(equals(bytesV2)));
      expect(bytesV1, isNot(equals(bytesSalted)));

      // Content encrypted with v1 fails decryption when attempted with v2
      final encryptedV1 = await cryptoService.encrypt(
        plaintext: 'Versioned payload test.',
        masterKey: testMasterKey,
        context: 'firefly-journal-content-v1',
      );

      expect(
        () async => await cryptoService.decrypt(
          encryptedPayloadBase64: encryptedV1,
          masterKey: testMasterKey,
          context: 'firefly-journal-content-v2',
        ),
        throwsA(isA<JournalCryptoException>()),
      );
    });

    test('rotateContext helper formats versioned domain strings', () {
      final v1 = JournalCryptoService.rotateContext(version: 1);
      final v2 = JournalCryptoService.rotateContext(version: 2);
      final custom = JournalCryptoService.rotateContext(baseContext: 'custom-subsystem', version: 3);

      expect(v1, equals('firefly-journal-content-v1'));
      expect(v2, equals('firefly-journal-content-v2'));
      expect(custom, equals('custom-subsystem-v3'));
    });

    test('zeroMemory and cryptoErase overwrite byte buffers with zeroes', () {
      final buffer = Uint8List.fromList([1, 2, 3, 4, 5, 255, 128, 64]);
      expect(buffer.any((byte) => byte != 0), isTrue);

      cryptoService.zeroMemory(buffer);
      expect(buffer.every((byte) => byte == 0), isTrue);

      final eraseBuffer = Uint8List.fromList([42, 99, 101]);
      cryptoService.cryptoErase(eraseBuffer);
      expect(eraseBuffer.every((byte) => byte == 0), isTrue);
    });

    test('Riverpod provider instantiates JournalCryptoService', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(journalCryptoServiceProvider);
      expect(service, isA<JournalCryptoService>());
    });
  });
}
