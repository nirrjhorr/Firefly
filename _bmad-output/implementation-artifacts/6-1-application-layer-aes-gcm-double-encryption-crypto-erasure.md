---
title: 'Story 6.1: Application-Layer AES-256-GCM Double Encryption & Cryptographic Erasure'
type: 'feature'
created: '2026-10-01'
status: 'done'
route: 'oneshot'
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Journal entries contain deeply vulnerable emotional distress and unsent letters. While SQLCipher protects the database at rest, defense-in-depth requires application-layer cryptographic isolation so that compromised DB handles or raw flash NAND dumps cannot expose plaintext journal entries, and cryptographic erasure guarantees permanent destruction upon deletion.

**Approach:** Implement `JournalCryptoService` in `lib/core/security/journal_crypto_service.dart` utilizing `package:cryptography`. Derive dedicated 256-bit journal subkeys via HKDF-HMAC-SHA256 with the info context `'firefly-journal-content-v1'`. Encrypt entries using AES-256-GCM with a 12-byte random nonce and 16-byte MAC tag formatted as `[12-byte nonce] || [ciphertext] || [16-byte MAC]` encoded in base64. Ensure immediate memory zeroing (`_zeroMemory`) after cryptographic operations, support subkey rotation context, and test exhaustively in `test/core/security/journal_crypto_service_test.dart`.

</frozen-after-approval>

## Implementation Notes
- Created `lib/core/security/journal_crypto_service.dart`:
  - `JournalCryptoService` implementing `deriveSubkey()` via `Hkdf(hmac: Hmac.sha256(), outputLength: 32)` with context `'firefly-journal-content-v1'`.
  - Application-layer AES-256-GCM encryption with 12-byte random nonce and 16-byte MAC tag.
  - Packed binary/base64 payload format: `[12 bytes nonce] || [ciphertext] || [16 bytes MAC]`.
  - Added `encryptBytes()` and `decryptBytes()` for raw binary payload encryption with zero-copy options.
  - Added Authenticated Additional Data (`aad`) parameter to bind ciphertexts to entry IDs.
  - Added `zeroMemory()` and `cryptoErase()` for cryptographic memory hygiene.
  - Added `rotateContext()` helper for versioned subkey rotation.
  - Created domain exception `JournalCryptoException` wrapping low-level cryptographic failure states.
  - Riverpod provider `journalCryptoServiceProvider`.
- Created `test/core/security/journal_crypto_service_test.dart`:
  - Verified round-trip encryption/decryption on short text, multiline unicode, and empty string.
  - Verified distinct nonces per encryption.
  - Verified custom nonce length validation (exact 12 bytes).
  - Verified tampering resistance: altered ciphertext, altered MAC tag, altered nonce, mismatched master key.
  - Verified AAD validation and tampering detection.
  - Verified HKDF subkey domain separation across contexts and salts.
  - Verified memory zeroing and crypto erasure.
  - Verified Riverpod provider instantiation.

## Review Triage Log
- Incomplete memory zeroing in `decrypt()`: `medium` — Patched: zeroed `decryptedList` in addition to converted buffer.
- Derived subkeys never destroyed in memory: `low` — Patched: added `_safelyDestroyKey` invoking `SecretKeyData.destroy()` in `finally`.
- Missing validation on `customNonce` length: `medium` — Patched: enforced exact 12-byte requirement throwing `ArgumentError`.
- Ambiguous key decoding in `_decodeKey()`: `low` — Patched: validated key size before byte conversion.
- Lack of Authenticated Additional Data (AAD) support: `low` — Patched: added optional `aad` parameter across encryption/decryption APIs.
- Missing payload version header and context metadata: `false` — Rejected: AC 1.3 explicitly mandates `[12 bytes nonce] || [ciphertext] || [16 bytes MAC]` payload format; versioning is supported via `rotateContext`.
- No support for encrypting raw bytes: `low` — Patched: added `encryptBytes` and `decryptBytes`.
- Disparate exception types without unified domain exception: `medium` — Patched: created `JournalCryptoException` domain wrapper.
- Overly broad exception assertions in tampering tests: `medium` — Patched: tightened assertions to `isA<JournalCryptoException>()`.
- Missing unit tests for edge cases and optional parameters: `low` — Patched: added comprehensive unit tests for all edge cases.
