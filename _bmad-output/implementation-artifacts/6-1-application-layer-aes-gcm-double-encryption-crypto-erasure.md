# Story 6.1: Application-Layer AES-256-GCM Double Encryption & Cryptographic Erasure

Status: ready-for-dev

## Story Description
As a privacy-conscious user recording deep emotional distress or unsent letters,
I want my journal entries protected by a second layer of AES-256-GCM encryption with cryptographic erasure,
So that even in forensic NAND extraction or database key compromise, my raw thoughts remain permanently unreadable.

## Acceptance Criteria
1. `JournalCryptoService` using `package:cryptography`:
   - Subkey derivation using `Hkdf(hmac: Hmac.sha256(), outputLength: 32)` with context `'firefly-journal-content-v1'`.
   - Application-layer encryption using `AesGcm.with256bits()` with a 12-byte secure random nonce and 16-byte MAC authentication tag.
   - Combined binary/base64 payload format: `[12 bytes nonce] || [ciphertext] || [16 bytes MAC]`.
   - Decryption verifies the MAC tag and authenticates the ciphertext, throwing on tampered data or mismatched key.
2. Sensitive memory management:
   - Zero out memory (`_zeroMemory` overwriting byte arrays with zeroes) immediately after encryption and decryption.
3. Cryptographic erasure:
   - Rotation of journal subkey version or overwriting ciphertext bytes with zeroes before deletion to prevent flash memory NAND recovery.
4. Unit tests:
   - Verifying encryption and decryption round-trip with correct plaintext.
   - Verifying decryption fails with tampered ciphertext or altered nonce/tag.
   - Verifying different HKDF contexts produce distinct subkeys.
   - Verifying memory zeroing clears byte buffers.
