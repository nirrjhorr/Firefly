import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Unified domain exception for cryptographic failures in Journal operations.
class JournalCryptoException implements Exception {
  const JournalCryptoException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => cause != null
      ? 'JournalCryptoException: $message (Cause: $cause)'
      : 'JournalCryptoException: $message';
}

/// Service providing application-layer AES-256-GCM double encryption,
/// HKDF subkey derivation, memory zeroing, and cryptographic erasure.
class JournalCryptoService {
  JournalCryptoService({
    Hkdf? hkdf,
    AesGcm? aesGcm,
  })  : _hkdf = hkdf ?? Hkdf(hmac: Hmac.sha256(), outputLength: 32),
        _aesGcm = aesGcm ?? AesGcm.with256bits();

  final Hkdf _hkdf;
  final AesGcm _aesGcm;

  /// Default HKDF domain separation context for Journal content encryption.
  static const String defaultContext = 'firefly-journal-content-v1';

  /// Standard 96-bit (12-byte) nonce length for AES-GCM.
  static const int nonceLength = 12;

  /// Standard 128-bit (16-byte) MAC authentication tag length for AES-GCM.
  static const int macLength = 16;

  /// Minimum encrypted payload length in bytes ([12 bytes nonce] + [16 bytes MAC]).
  static const int minPayloadLength = nonceLength + macLength;

  /// Derives a dedicated 256-bit [SecretKey] from a master database key using HKDF-HMAC-SHA256.
  ///
  /// [masterKey] can be a base64 string or plaintext passphrase.
  /// [context] provides domain separation (defaults to [defaultContext]).
  /// [salt] is an optional salt; defaults to empty bytes.
  Future<SecretKey> deriveSubkey({
    required String masterKey,
    String context = defaultContext,
    List<int>? salt,
  }) async {
    final masterKeyBytes = _decodeKey(masterKey);
    try {
      final masterSecretKey = SecretKey(masterKeyBytes);
      final derivedKey = await _hkdf.deriveKey(
        secretKey: masterSecretKey,
        nonce: salt ?? const <int>[],
        info: utf8.encode(context),
      );
      return derivedKey;
    } finally {
      zeroMemory(masterKeyBytes);
    }
  }

  /// Encrypts raw [plaintextBytes] using AES-256-GCM with a subkey derived from [masterKey].
  ///
  /// Returns combined binary payload: `[12 bytes nonce] || [ciphertext] || [16 bytes MAC]`.
  Future<Uint8List> encryptBytes({
    required List<int> plaintextBytes,
    required String masterKey,
    String context = defaultContext,
    List<int>? customNonce,
    List<int> aad = const [],
  }) async {
    if (customNonce != null && customNonce.length != nonceLength) {
      throw ArgumentError(
        'Custom nonce length (${customNonce.length}) must be exactly $nonceLength bytes.',
      );
    }

    final subkey = await deriveSubkey(masterKey: masterKey, context: context);
    try {
      final nonce = customNonce ?? _generateSecureNonce(nonceLength);
      final secretBox = await _aesGcm.encrypt(
        plaintextBytes,
        secretKey: subkey,
        nonce: nonce,
        aad: aad,
      );

      final cipherText = secretBox.cipherText;
      final macBytes = secretBox.mac.bytes;

      // Pack into [12 bytes nonce] || [ciphertext] || [16 bytes MAC]
      final payloadBytes = Uint8List(nonce.length + cipherText.length + macBytes.length);
      payloadBytes.setRange(0, nonce.length, nonce);
      payloadBytes.setRange(nonce.length, nonce.length + cipherText.length, cipherText);
      payloadBytes.setRange(nonce.length + cipherText.length, payloadBytes.length, macBytes);

      return payloadBytes;
    } finally {
      _safelyDestroyKey(subkey);
    }
  }

  /// Decrypts combined binary [payloadBytes] using AES-256-GCM.
  ///
  /// Returns decrypted bytes.
  Future<Uint8List> decryptBytes({
    required Uint8List payloadBytes,
    required String masterKey,
    String context = defaultContext,
    List<int> aad = const [],
  }) async {
    if (payloadBytes.length < minPayloadLength) {
      throw JournalCryptoException(
        'Encrypted payload length (${payloadBytes.length}) is below minimum ($minPayloadLength bytes).',
      );
    }

    final nonce = payloadBytes.sublist(0, nonceLength);
    final macBytes = payloadBytes.sublist(payloadBytes.length - macLength);
    final cipherText = payloadBytes.sublist(nonceLength, payloadBytes.length - macLength);

    final subkey = await deriveSubkey(masterKey: masterKey, context: context);
    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(macBytes),
    );

    try {
      final decryptedList = await _aesGcm.decrypt(
        secretBox,
        secretKey: subkey,
        aad: aad,
      );
      final resultBytes = Uint8List.fromList(decryptedList);
      zeroMemory(decryptedList);
      return resultBytes;
    } on SecretBoxAuthenticationError catch (e) {
      throw JournalCryptoException('Decryption authentication failed: tampered payload or invalid key.', e);
    } catch (e) {
      if (e is JournalCryptoException) rethrow;
      throw JournalCryptoException('Decryption failed: $e', e);
    } finally {
      _safelyDestroyKey(subkey);
    }
  }

  /// Encrypts [plaintext] using AES-256-GCM with a subkey derived from [masterKey].
  ///
  /// Payload format: `[12 bytes nonce] || [ciphertext] || [16 bytes MAC tag]`.
  /// Returns a Base64-encoded payload string.
  /// Plaintext bytes in memory are securely zeroed out immediately after encryption.
  Future<String> encrypt({
    required String plaintext,
    required String masterKey,
    String context = defaultContext,
    List<int>? customNonce,
    List<int> aad = const [],
  }) async {
    final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));
    try {
      final payloadBytes = await encryptBytes(
        plaintextBytes: plaintextBytes,
        masterKey: masterKey,
        context: context,
        customNonce: customNonce,
        aad: aad,
      );
      return base64Encode(payloadBytes);
    } finally {
      zeroMemory(plaintextBytes);
    }
  }

  /// Decrypts [encryptedPayloadBase64] using AES-256-GCM with a subkey derived from [masterKey].
  ///
  /// Expects payload format: `[12 bytes nonce] || [ciphertext] || [16 bytes MAC tag]`.
  /// Throws [JournalCryptoException] if MAC verification fails, payload is corrupted, or key is mismatched.
  /// Decrypted bytes in memory are zeroed out after string conversion.
  Future<String> decrypt({
    required String encryptedPayloadBase64,
    required String masterKey,
    String context = defaultContext,
    List<int> aad = const [],
  }) async {
    Uint8List payloadBytes;
    try {
      payloadBytes = base64Decode(encryptedPayloadBase64);
    } on FormatException catch (e) {
      throw JournalCryptoException('Invalid base64 payload format.', e);
    }

    Uint8List? clearTextBytes;
    try {
      clearTextBytes = await decryptBytes(
        payloadBytes: payloadBytes,
        masterKey: masterKey,
        context: context,
        aad: aad,
      );
      return utf8.decode(clearTextBytes);
    } finally {
      if (clearTextBytes != null) {
        zeroMemory(clearTextBytes);
      }
    }
  }

  /// Cryptographically overwrites all bytes in [buffer] with zeroes.
  ///
  /// Prevents memory leaks and forensic flash/RAM recovery of sensitive content.
  void zeroMemory(List<int> buffer) {
    for (int i = 0; i < buffer.length; i++) {
      buffer[i] = 0;
    }
  }

  /// Overwrites [buffer] with zeroes for cryptographic erasure of database row data or flash buffers.
  void cryptoErase(Uint8List buffer) {
    zeroMemory(buffer);
  }

  /// Generates a rotated subkey context string for versioned subkey rotation.
  static String rotateContext({
    String baseContext = 'firefly-journal-content',
    required int version,
  }) {
    return '$baseContext-v$version';
  }

  /// Safely destroys secret key data in memory if supported.
  void _safelyDestroyKey(SecretKey key) {
    if (key is SecretKeyData) {
      key.destroy();
    }
  }

  /// Securely decodes the master key string into a byte array.
  Uint8List _decodeKey(String key) {
    try {
      final decoded = base64Decode(key);
      if (decoded.length >= 16) {
        return Uint8List.fromList(decoded);
      }
    } catch (_) {}
    return Uint8List.fromList(utf8.encode(key));
  }

  /// Generates a cryptographically secure random nonce.
  List<int> _generateSecureNonce([int length = nonceLength]) {
    final random = Random.secure();
    final nonce = Uint8List(length);
    for (int i = 0; i < length; i++) {
      nonce[i] = random.nextInt(256);
    }
    return nonce;
  }
}

/// Riverpod provider for [JournalCryptoService].
final journalCryptoServiceProvider = Provider<JournalCryptoService>((ref) {
  return JournalCryptoService();
});
