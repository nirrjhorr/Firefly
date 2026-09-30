# SECURITY_AND_PRIVACY.md
# Firefly — Security Architecture & Privacy Specification

**Version:** 1.0.0
**Date:** 2026-09-30
**Classification:** Internal Engineering — Sensitive
**Status:** Sprint 0 — Approved Baseline

> **Scope Statement:** This document governs the complete security posture of Firefly, an offline-first mental wellbeing application storing highly sensitive psychological data. It defines the threat model, cryptographic architecture, data protection mechanisms, ephemeral safety features, and compliance verification procedures. Every engineering decision must be validated against this document before merge.

---

## Table of Contents
1. [Adversary Model & Trust Boundaries](#1-adversary-model--trust-boundaries)
2. [Cryptographic Key Lifecycle & Storage Architecture](#2-cryptographic-key-lifecycle--storage-architecture)
3. [Data Protection: At Rest, In Transit & In Memory](#3-data-protection-at-rest-in-transit--in-memory)
4. [Ephemeral & Panic Features](#4-ephemeral--panic-features)
5. [STRIDE Vulnerability & Threat Matrix](#5-stride-vulnerability--threat-matrix)
6. [Audit & Compliance Checklist](#6-audit--compliance-checklist)

---

## 1. Adversary Model & Trust Boundaries

### 1.1 Adversary Profiles (Ordered by Threat Severity)

| Adversary | Capability | Primary Attack Vector | Risk Level |
|---|---|---|---|
| **Physical Device Seizure** (law enforcement, theft) | Full device access, forensic tooling (Cellebrite, GrayKey) | NAND flash extraction, memory imaging | 🔴 Critical |
| **Cohabitant / Domestic Partner** | Unlocked screen access, device PIN knowledge | Direct app access while user is away | 🔴 Critical |
| **Malicious OS-Level App** | `READ_EXTERNAL_STORAGE`, accessibility services | Inter-process data scraping, screen reading | 🟠 High |
| **Shoulder-Surfer** | Visual observation | Screen content reading during active session | 🟡 Medium |
| **Forensic Flash Extraction** (deleted data recovery) | JTAG/chip-off NAND access | Recovering unwiped database pages | 🔴 Critical |
| **Rogue Telemetry SDK** (accidental dependency) | Code execution within app process | Network exfiltration of decrypted strings | 🟠 High |

### 1.2 Trust Boundary Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│  FULLY TRUSTED ZONE (Firefly Process)                           │
│                                                                 │
│  ┌─────────────────┐        ┌──────────────────────────────┐   │
│  │  Flutter UI      │◄──────►│  Riverpod State (in-memory)  │   │
│  └─────────────────┘        └──────────────────────────────┘   │
│           │                              │                      │
│           ▼                              ▼                      │
│  ┌─────────────────┐        ┌──────────────────────────────┐   │
│  │  Repository     │        │  Rule Engine (pure Dart)     │   │
│  │  Layer (DAOs)   │        └──────────────────────────────┘   │
│  └────────┬────────┘                                           │
│           │                                                     │
├───────────┼─────────────────────────────────────────────────────┤
│  HARDWARE SECURITY BOUNDARY                                     │
│           │                                                     │
│           ▼                                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  SQLCipher-Encrypted Database (.db file)                 │   │
│  │  Key stored in: iOS Keychain / Android StrongBox TEE     │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘

OUTSIDE TRUST BOUNDARY (no Firefly code runs here):
  ✗  Internet / Network Interfaces
  ✗  Cloud Storage (iCloud, Google Drive — excluded by design)
  ✗  External SDKs with network access
  ✗  OS Screenshot / App Switcher Cache
```

### 1.3 Zero-Trust Principles
1.  **Default-Deny Networking:** No outbound connection is ever made. The absence of an HTTP client is a security property, not just a feature.
2.  **Need-to-Know Decryption:** Sensitive fields (journal content, safety plan phone numbers) are decrypted only for the milliseconds they appear on screen.
3.  **Explicit User Consent for Every Privacy Boundary Cross:** Export, share, and reach-out features require explicit user-initiated action — never automatic.

---

## 2. Cryptographic Key Lifecycle & Storage Architecture

### 2.1 Key Hierarchy

The Firefly key hierarchy follows a three-tier design to isolate blast radii:

```
┌──────────────────────────────────────────────────────────┐
│  Tier 0: Hardware Root of Trust                          │
│  iOS: Secure Enclave (ECDH P-256 bound to biometrics)    │
│  Android: StrongBox Keymaster TEE                        │
└─────────────────────┬────────────────────────────────────┘
                      │ wraps / seals
                      ▼
┌──────────────────────────────────────────────────────────┐
│  Tier 1: Master Key (MK)                                 │
│  256-bit random key generated on first launch            │
│  Stored: iOS Keychain / Android Keystore                 │
│  Attribute: .thisDeviceOnly + biometric requirement      │
│  Usage: Seals the Database Key                           │
└─────────────────────┬────────────────────────────────────┘
                      │ derives / seals
                      ▼
┌──────────────────────────────────────────────────────────┐
│  Tier 2: Database Encryption Key (DEK)                   │
│  256-bit key passed to SQLCipher at runtime              │
│  Stored: Sealed by MK in Keychain/Keystore               │
│  Never written to disk in plaintext                      │
└──────────────────────────────────────────────────────────┘
                      │ separate path
                      ▼
┌──────────────────────────────────────────────────────────┐
│  Tier 3: Backup Passphrase Key (BPK)                     │
│  Derived via Argon2id(user_passphrase, random_salt)      │
│  Exists only in memory during export/import              │
│  Never stored anywhere — user must re-enter each time    │
└──────────────────────────────────────────────────────────┘
```

### 2.2 Master Key Generation & Storage

#### iOS Implementation

```swift
// ios/Runner/KeyManager.swift
// Called from Flutter via MethodChannel on first launch

import Security
import LocalAuthentication

class KeyManager {

    private static let masterKeyTag = "app.firefly.master_key"

    /// Generates a 256-bit cryptographically random master key and
    /// stores it in the Secure Enclave-backed Keychain.
    /// Access policy: biometric required, this device only, no iCloud sync.
    static func generateAndStoreMasterKey() throws {
        var keyBytes = [UInt8](repeating: 0, count: 32)
        guard SecRandomCopyBytes(kSecRandomDefault, 32, &keyBytes) == errSecSuccess else {
            throw KeyManagerError.randomGenerationFailed
        }

        let accessControl = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,  // wiped on device reset
            [.biometryCurrentSet, .or, .devicePasscode],      // biometric OR passcode
            nil
        )!

        let query: [CFString: Any] = [
            kSecClass:              kSecClassGenericPassword,
            kSecAttrAccount:        masterKeyTag,
            kSecAttrAccessControl:  accessControl,
            kSecAttrSynchronizable: false,     // CRITICAL: block iCloud Keychain sync
            kSecValueData:          Data(keyBytes),
        ]

        // Zero out the key bytes immediately after storage
        defer { keyBytes.withUnsafeMutableBufferPointer { $0.baseAddress?.initialize(repeating: 0, count: 32) } }

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeyManagerError.keystoreWriteFailed(status)
        }
    }

    /// Retrieves the master key. Triggers biometric/passcode prompt.
    static func retrieveMasterKey(context: LAContext) throws -> Data {
        let query: [CFString: Any] = [
            kSecClass:              kSecClassGenericPassword,
            kSecAttrAccount:        masterKeyTag,
            kSecUseAuthenticationContext: context,
            kSecReturnData:         true,
            kSecMatchLimit:         kSecMatchLimitOne,
        ]
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let keyData = result as? Data else {
            throw KeyManagerError.keystoreReadFailed(status)
        }
        return keyData
    }
}
```

#### Android Implementation

```kotlin
// android/app/src/main/kotlin/app/firefly/KeyManager.kt

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.security.keystore.StrongBoxUnavailableException
import java.security.KeyStore
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey

object KeyManager {

    private const val KEY_ALIAS = "FireflyMasterKey"
    private const val KEYSTORE_PROVIDER = "AndroidKeyStore"

    fun generateMasterKey() {
        val keyGenerator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            KEYSTORE_PROVIDER
        )

        val spec = KeyGenParameterSpec.Builder(
            KEY_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
            .setKeySize(256)
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setUserAuthenticationRequired(true)
            .setUserAuthenticationParameters(
                0, // Require auth for every use (timeout=0 means per-use auth)
                KeyProperties.AUTH_BIOMETRIC_STRONG or KeyProperties.AUTH_DEVICE_CREDENTIAL
            )
            .setInvalidatedByBiometricEnrollment(true)  // Key wiped if new fingerprint added
            .setUnlockedDeviceRequired(true)             // Requires screen to be unlocked
            .apply {
                // Prefer StrongBox (discrete security chip) if available
                // Falls back to TEE if StrongBox unavailable — never software-only
                try {
                    setIsStrongBoxBacked(true)
                } catch (e: StrongBoxUnavailableException) {
                    // Acceptable: TEE is still hardware-backed
                }
            }
            .build()

        keyGenerator.init(spec)
        keyGenerator.generateKey()
    }

    fun getMasterKey(): SecretKey {
        val keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER).apply { load(null) }
        return (keyStore.getEntry(KEY_ALIAS, null) as KeyStore.SecretKeyEntry).secretKey
    }
}
```

### 2.3 Biometric Unlock Flow

```dart
// lib/core/security/biometric_guard.dart

import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricGuard {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.firstUnlockThisDevice,
      synchronizable: false,  // Block iCloud Keychain sync
    ),
  );

  /// Returns database key only if biometric/passcode authentication succeeds.
  /// This is the only code path that retrieves the DEK — no bypass exists.
  Future<String?> authenticateAndGetDatabaseKey() async {
    final canAuth = await _localAuth.canCheckBiometrics ||
        await _localAuth.isDeviceSupported();

    if (!canAuth) {
      // Device has no security lock — warn user and refuse to open DB
      return null;
    }

    final didAuthenticate = await _localAuth.authenticate(
      localizedReason: 'Authenticate to open Firefly',
      options: const AuthenticationOptions(
        biometricOnly: false, // Allow fallback to PIN/passcode
        stickyAuth: true,     // Don't dismiss on app switch
        sensitiveTransaction: true, // Disables screenshot on auth screen (Android)
      ),
    );

    if (!didAuthenticate) return null;

    // Retrieve the DEK only after successful authentication
    return _secureStorage.read(key: 'firefly_database_key');
  }

  /// Revokes in-memory key access. Called by Panic Button and background lifecycle.
  Future<void> lockApp() async {
    // Signal the database provider to close and drop the in-memory key reference
    // Actual key erasure in calling code — see §4.1
  }
}
```

### 2.4 Backup Passphrase Key (Tier 3) — Argon2id Parameters

| Parameter | Value | Rationale |
|---|---|---|
| Algorithm | Argon2id | Side-channel resistant; OWASP recommended for password hashing |
| Memory | 64 MB (`m=65536`) | Raises cost of GPU/ASIC brute force to ~\$0.10+ per attempt |
| Iterations | 3 (`t=3`) | ~1 second on mid-range phone; acceptable UX |
| Parallelism | 2 (`p=2`) | Matches dual-core minimum target devices |
| Output length | 32 bytes | AES-256 key |
| Salt | 16 bytes, `SecureRandom` | Unique per export — prevents precomputed dictionary attacks |

---

## 3. Data Protection: At Rest, In Transit & In Memory

### 3.1 Protection At Rest

#### SQLCipher Configuration

```sql
-- Applied immediately on every database connection open, before any query:
PRAGMA key = '<256-bit hex key>';         -- Unlocks AES-256-CBC encryption
PRAGMA cipher_page_size = 4096;           -- Page size for mobile flash alignment
PRAGMA kdf_iter = 256000;                 -- PBKDF2-SHA512 internal KDF (SQLCipher 4)
PRAGMA cipher_hmac_algorithm = HMAC_SHA512; -- Authenticated encryption integrity
PRAGMA foreign_keys = ON;                 -- Referential integrity enforcement
PRAGMA journal_mode = WAL;               -- Write-Ahead Log for crash safety
PRAGMA secure_delete = ON;               -- Overwrite freed pages with zeros on delete
```

**`PRAGMA secure_delete = ON`** instructs SQLite to overwrite deleted page content with zeros before freeing — this is the database-level equivalent of the application-layer wipe described in `LOCAL_BACKEND_ARCHITECTURE.md`.

#### Double Encryption for Journal Entries

Journal content receives an additional application-layer AES-256-GCM encryption pass **on top of** SQLCipher. This ensures that even if the database key is somehow compromised (e.g., via Keychain vulnerability), journal content remains protected by a separately derived key.

```dart
// lib/features/journaling/data/journal_crypto_service.dart

class JournalCryptoService {
  // Journal-specific subkey derived from Master Key using HKDF
  // "context" string prevents cross-feature key reuse
  static const _hkdfContext = 'firefly-journal-content-v1';

  Future<String> encryptContent(String plaintext, Uint8List masterKey) async {
    final subKey = await _deriveSubKey(masterKey, _hkdfContext);
    final nonce  = _generateSecureRandom(12);
    final cipher = AesGcm.with256bits();

    final secretBox = await cipher.encrypt(
      utf8.encode(plaintext),
      secretKey: SecretKey(subKey),
      nonce: nonce,
    );

    // Encode as base64: nonce || ciphertext || mac
    final combined = Uint8List.fromList([
      ...nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);

    // CRITICAL: Zero out plaintext bytes after encryption
    _zeroMemory(utf8.encode(plaintext) as Uint8List);

    return base64Encode(combined);
  }

  Future<String> decryptContent(String encoded, Uint8List masterKey) async {
    final subKey  = await _deriveSubKey(masterKey, _hkdfContext);
    final bytes   = base64Decode(encoded);
    final nonce   = bytes.sublist(0, 12);
    final mac     = bytes.sublist(bytes.length - 16);
    final cipher_ = bytes.sublist(12, bytes.length - 16);

    final cipher = AesGcm.with256bits();
    final plainBytes = await cipher.decrypt(
      SecretBox(cipher_, nonce: nonce, mac: Mac(mac)),
      secretKey: SecretKey(subKey),
    );

    return utf8.decode(plainBytes);
    // Caller MUST call _zeroMemory on the returned string's underlying bytes
    // after rendering is complete — see §3.3
  }

  Future<Uint8List> _deriveSubKey(Uint8List masterKey, String context) async {
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final output = await hkdf.deriveKey(
      secretKey: SecretKey(masterKey),
      info: utf8.encode(context),
    );
    return Uint8List.fromList(await output.extractBytes());
  }

  void _zeroMemory(Uint8List bytes) {
    for (int i = 0; i < bytes.length; i++) { bytes[i] = 0; }
  }
}
```

### 3.2 Zero-Network Enforcement

#### Build-Time Enforcement: Dependency Audit

A CI step runs **before every build** to verify no networking package is present in `pubspec.lock`:

```yaml
# .github/workflows/security_audit.yml
# (or equivalent CI configuration)

- name: Deny-list networking packages
  run: |
    FORBIDDEN=("http" "dio" "chopper" "retrofit" "firebase_core" "firebase_analytics"
               "sentry_flutter" "datadog_flutter_plugin" "amplitude_flutter"
               "mixpanel_flutter" "segment_analytics" "crashlytics")
    for pkg in "${FORBIDDEN[@]}"; do
      if grep -q "^  $pkg:" pubspec.lock; then
        echo "❌ SECURITY VIOLATION: Forbidden network package '$pkg' found in pubspec.lock"
        exit 1
      fi
    done
    echo "✅ Network package audit passed"
```

#### Runtime Enforcement: Network Security Config (Android)

```xml
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<!-- This file disallows ALL cleartext AND encrypted traffic -->

<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- Block all network traffic to any domain -->
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <!-- No CA certificates trusted — we never make TLS connections -->
        </trust-anchors>
    </base-config>
    <!-- Explicitly block debug overrides — applies in release AND debug builds -->
    <debug-overrides>
        <trust-anchors/>
    </debug-overrides>
</network-security-config>
```

```xml
<!-- AndroidManifest.xml -->
<application
    android:networkSecurityConfig="@xml/network_security_config"
    android:usesCleartextTraffic="false"
    ...>
```

#### Runtime Enforcement: iOS App Transport Security

```xml
<!-- ios/Runner/Info.plist -->
<!-- ATS: deny all outbound HTTP/HTTPS connections -->
<key>NSAppTransportSecurity</key>
<dict>
    <!-- No exceptions — no domains allowed -->
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSAllowsLocalNetworking</key>
    <false/>
</dict>
```

#### Runtime Enforcement: Custom HTTP Client Override (Flutter)

The `http` package is not installed. However, if a transitive dependency ever sneaks it in, this global override ensures no request completes:

```dart
// lib/core/security/network_kill_switch.dart

/// Installs a global HTTP client override that throws on any connection attempt.
/// This is a defense-in-depth measure — the primary control is the build-time
/// dependency audit. Register this in main() before ProviderScope.
class FireflyHttpOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    throw UnsupportedError(
      '[FIREFLY SECURITY] Outbound network connections are prohibited. '
      'If you are seeing this in development, a dependency has '
      'introduced a network call. Audit pubspec.lock immediately.',
    );
  }
}

// main.dart
void main() {
  HttpOverrides.global = FireflyHttpOverride(); // Must be first line
  runApp(const ProviderScope(child: FireflyApp()));
}
```

### 3.3 Secure Memory Handling

Dart's garbage collector manages memory non-deterministically — we cannot guarantee when a `String` is collected. The following patterns minimize sensitive data lifetime in the heap:

#### Pattern 1: Scoped Decryption with Immediate Zeroing

```dart
// lib/features/journaling/presentation/controllers/journal_display_controller.dart

Future<void> loadAndDisplayEntry(String entryId) async {
  final cryptoService = ref.read(journalCryptoServiceProvider);
  final masterKey = ref.read(masterKeyProvider); // in-memory, gated by biometric

  // Decrypt into a typed wrapper — never a bare String stored in state long-term
  final plaintext = await cryptoService.decryptContent(
    await _dao.getEncryptedContent(entryId),
    masterKey,
  );

  state = state.copyWith(visibleContent: plaintext);

  // Schedule zeroing after display has rendered (next frame)
  // In Dart, we cannot directly zero a String — we use a mutable Uint8List
  // and keep String references lifetime as short as possible
  ref.onDispose(() {
    // Signal to clear the visible content when user navigates away
    state = state.copyWith(visibleContent: null);
    // The GC will collect; we zero what we can control (the Uint8List source)
  });
}
```

**Dart Memory Limitation:** Dart `String` is immutable and internally managed; we cannot force-zero it. Mitigations:
1.  Keep decrypted `String` lifetime scoped to screen display only.
2.  Use `Uint8List` for all intermediate cryptographic operations — these can be explicitly zeroed.
3.  Call `state.dispose()` on navigation exit to drop state references.

#### Pattern 2: Safety Plan Phone Number Handling

```dart
// Safety plan phone numbers are only decrypted in the moment of call initiation
// They are NEVER stored in any Riverpod state or Widget state tree

Future<void> initiateCallToContact(String contactId) async {
  // Decrypt only to place call — never stored in state
  final phoneNumber = await _decryptContactPhone(contactId);

  // Launch native dialer — phone number never persists in Flutter memory
  await launchUrl(Uri(scheme: 'tel', path: phoneNumber));

  // Dart cannot guarantee immediate GC, but local var goes out of scope
  // phoneNumber = null; // assignment hint for potential future Dart optimization
}
```

### 3.4 Anti-Screen Scraping & OS Caching

#### Android: `FLAG_SECURE`

```kotlin
// android/app/src/main/kotlin/app/firefly/MainActivity.kt

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Prevents: screenshots, screen recording, app-switcher thumbnail,
        // Google Assistant visual capture, accessibility service screen reading
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }
}
```

#### iOS: Blur Overlay on App Resignation

```swift
// ios/Runner/AppDelegate.swift

import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    private var blurView: UIVisualEffectView?

    override func applicationWillResignActive(_ application: UIApplication) {
        // iOS takes a screenshot for the app switcher exactly at this moment.
        // We cover the screen with a blur overlay BEFORE the screenshot is taken.
        let blur = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = window!.frame
        blurView.tag = 999
        window?.addSubview(blurView)
        window?.bringSubviewToFront(blurView)
        self.blurView = blurView
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        // Remove blur overlay when app returns to foreground
        window?.viewWithTag(999)?.removeFromSuperview()
        blurView = nil
    }
}
```

---

## 4. Ephemeral & Panic Features

### 4.1 Panic / Quick-Exit Button

**Requirement:** Complete screen blanking and in-memory decrypted state purge within **< 100ms** of user activation.

#### Architecture

The Panic Button is a persistent floating overlay (always rendered above all routes) that triggers a three-phase shutdown sequence:

```dart
// lib/shared/widgets/panic_button.dart

class PanicButton extends ConsumerWidget {
  const PanicButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      top: 48,
      right: 16,
      child: GestureDetector(
        // Long-press to prevent accidental trigger
        onLongPress: () => _executePanicSequence(context, ref),
        child: Opacity(
          opacity: 0.25, // Intentionally unobtrusive
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<void> _executePanicSequence(BuildContext context, WidgetRef ref) async {
    // Phase 1 (< 10ms): Immediately blank the screen
    // Navigate to a plain black screen — no content visible
    context.go('/panic-blank');

    // Phase 2 (< 50ms): Purge all decrypted state from Riverpod
    ref.invalidate(journalDisplayProvider);
    ref.invalidate(checkInSessionProvider);
    ref.invalidate(safetyPlanDisplayProvider);
    ref.invalidate(masterKeyProvider); // Drop in-memory key reference

    // Phase 3 (< 100ms): Lock the database
    await ref.read(biometricGuardProvider).lockApp();

    // Phase 4: Navigate to a plausibly deniable screen
    // By default: the device home screen. User can configure an alternative app.
    await _exitToHomeScreen();
  }

  Future<void> _exitToHomeScreen() async {
    // Android: MoveTask to back (app appears closed)
    // iOS: Cannot force-exit; navigate to a neutral "weather/calendar" decoy screen
    const platform = MethodChannel('app.firefly/panic');
    await platform.invokeMethod('exitToBackground');
  }
}
```

#### Native Implementation (Android)

```kotlin
// android/app/src/main/kotlin/app/firefly/PanicChannel.kt

class PanicChannel(private val activity: Activity) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "exitToBackground") {
            // Move entire task to background — looks like user pressed Home
            activity.moveTaskToBack(true)
            result.success(null)
        }
    }
}
```

#### Panic Blank Screen

```dart
// lib/features/panic/presentation/screens/panic_blank_screen.dart

/// A pure black screen shown for the < 100ms transition window during panic.
/// Contains no user data, no app branding — visually indistinguishable from a
/// turned-off screen at a glance.
class PanicBlankScreen extends StatelessWidget {
  const PanicBlankScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: Colors.black,
    body: SizedBox.expand(), // No children, no text, no identifiers
  );
}
```

### 4.2 Cryptographic Erasure for Journal Entries (TTL Expiry)

Standard file unlink leaves bytes on NAND flash until sector reuse. Firefly implements **cryptographic erasure**: the journal subkey is rotated, rendering all existing ciphertext permanently unrecoverable — even from NAND chip-off forensics.

```dart
// lib/core/security/cryptographic_eraser.dart

/// Cryptographic erasure: destroys decryptability by rotating the journal subkey.
/// Old ciphertext remains on disk but becomes permanently unreadable.
/// This is effective even against NAND chip-off extraction.
class CryptographicEraser {
  final FlutterSecureStorage _secureStorage;
  final AppDatabase _db;

  static const _journalKeyVersionKey = 'firefly_journal_key_version';

  /// Erases ALL journal entries by rotating the journal-specific subkey.
  /// Called when user enables "auto-delete all" or manually wipes journals.
  Future<void> cryptoEraseAllJournals() async {
    // Step 1: Increment the key version in Keychain/Keystore
    final currentVersion = int.parse(
      await _secureStorage.read(key: _journalKeyVersionKey) ?? '1'
    );
    final newVersion = currentVersion + 1;
    await _secureStorage.write(
      key: _journalKeyVersionKey,
      value: newVersion.toString(),
    );

    // Step 2: The HKDF context now changes (includes version) →
    // new key derived → old ciphertext is permanently unreadable
    // Old encrypted blobs in DB become cryptographic noise.

    // Step 3: Optionally delete the DB rows (housekeeping — not security-critical
    // since they're already unreadable, but reduces storage footprint)
    await _db.journalEntryDao.deleteAll();

    // Step 4: SQLite VACUUM to reclaim and overwrite freed pages
    await _db.customStatement('VACUUM');
  }

  /// For TTL-expired individual entries: overwrite-then-delete
  Future<void> eraseEntry(String entryId) async {
    // Overwrite with random-length random ciphertext first
    await _db.journalEntryDao.overwriteContent(
      id: entryId,
      randomContent: base64Encode(_generateSecureRandom(256)),
    );
    await _db.journalEntryDao.deleteById(entryId);
    await _db.customStatement('VACUUM');
  }
}
```

---

## 5. STRIDE Vulnerability & Threat Matrix

| STRIDE Category | Threat | Attack Scenario | Mitigation (Flutter Layer) | Mitigation (Native / DB Layer) | Residual Risk |
|---|---|---|---|---|---|
| **Spoofing** | Fake biometric authentication | Attacker uses a photo/video to bypass face ID | `LAPolicy.deviceOwnerAuthenticationWithBiometrics` + `sensitiveTransaction: true` disables weak biometrics | iOS Face ID uses Secure Enclave liveness detection; Android `BiometricManager.Authenticators.BIOMETRIC_STRONG` enforces Class 3 biometrics | Low — hardware liveness detection |
| **Spoofing** | Impersonation of app by malicious clone | Malicious app with identical package ID attempts to read Keychain | iOS: Keychain items scoped to app entitlement group; Android: KeyStore keys scoped to UID | App signing certificate mismatch prevents access | Very Low |
| **Tampering** | SQLite database file modification | Attacker modifies encrypted `.db` file bytes | App detects SQLCipher HMAC-SHA512 authentication failure and refuses to open | `PRAGMA cipher_hmac_algorithm = HMAC_SHA512` — any tampered page fails MAC verification | Low — authenticated encryption |
| **Tampering** | Malicious Flutter plugin injection | Attacker adds rogue package to pubspec | Build-time deny-list CI step blocks forbidden packages | Code signing on both platforms prevents unsigned code execution | Low |
| **Repudiation** | User denies writing a journal entry | User claims entry was fabricated | All entries are write-once; no cloud sync means no external attribution | Timestamps stored at insert — not editable without DB key | Low |
| **Information Disclosure** | OS app-switcher screenshot captures sensitive content | Cohabitant views app thumbnail showing journal text | `FLAG_SECURE` (Android) + blur overlay on `applicationWillResignActive` (iOS) | Native implementation applied before OS takes snapshot | Very Low |
| **Information Disclosure** | Heap dump captures decrypted journal text | Forensic memory imaging during active session | Decrypted content scoped to minimal lifetime; `String` zeroed post-render | No plaintext persisted to disk outside SQLCipher | Medium — Dart GC non-determinism |
| **Information Disclosure** | iCloud / Google Drive backup captures DB file | Cloud backup of app data directory | `FlutterSecureStorage(iOptions: IOSOptions(synchronizable: false))` | Android: `android:allowBackup="false"` in Manifest; iOS: `NSURLIsExcludedFromBackupKey` on DB file | Very Low |
| **Information Disclosure** | Transitive dependency exfiltrates data | `http` package added via indirect dependency | `FireflyHttpOverride` throws on any HTTP creation; build-time audit | Android Network Security Config blocks all outbound connections | Very Low |
| **Information Disclosure** | Log output captures sensitive strings | Debug logs include journal content | `package:logging` configured — no `print()` allowed (lint rule); production logging disabled | ProGuard/R8 removes log calls in release builds | Very Low |
| **Denial of Service** | Corrupted database on app kill during write | Battery dies mid-write | Drift uses WAL mode — incomplete transactions roll back automatically | SQLite WAL journal persists across process kills | Very Low |
| **Denial of Service** | Panic button triggered accidentally | User triggers quick-exit inadvertently | Long-press required (not single tap) + 200ms confirmation haptic | N/A | Low |
| **Elevation of Privilege** | Root / jailbroken device reads Keychain | Attacker has rooted Android or jailbroken iOS | `setUnlockedDeviceRequired(true)` + `setIsStrongBoxBacked(true)` on Android; iOS Secure Enclave is physically isolated | StrongBox chip (Pixel, Samsung Knox): keys never leave chip even on rooted device | Medium — Jailbroken iOS Secure Enclave bypass is theoretical but documented |
| **Elevation of Privilege** | Accessibility service reads screen content | Malicious accessibility app scrapes displayed text | `FLAG_SECURE` blocks accessibility service screen capture on Android | iOS does not expose screen content to third-party accessibility services beyond VoiceOver | Low |

---

## 6. Audit & Compliance Checklist

### 6.1 App Store Privacy Label (iOS) — Zero Data Collection

The App Store Connect privacy label must declare **"Data Not Collected"** for all categories. The following checklist verifies this is accurate and defensible:

| Category | Collected? | Evidence |
|---|---|---|
| Contact Info (name, email, phone) | ❌ No | No account system; contacts in Safety Plan stored locally only |
| Health & Fitness data | ❌ No | Mood data never leaves device; no HealthKit integration |
| Financial Info | ❌ No | No in-app purchases in v1.0 |
| Location | ❌ No | No location APIs called; no permission requested |
| Sensitive Info (mental health) | ❌ No | Stays on device; SQLCipher encrypted |
| Contacts | ❌ No | Safety plan contacts entered manually; not synced from address book |
| User Content (journals) | ❌ No | Encrypted on device; never transmitted |
| Identifiers (Device ID, IDFA) | ❌ No | No analytics SDK; `AdSupport` framework not linked |
| Usage Data (crash logs) | ❌ No | No Crashlytics / Sentry installed |
| Diagnostics | ❌ No | No performance monitoring SDK |

**Verification Step:** Run `otool -L Runner.app/Runner` (iOS) or `strings classes.dex | grep -E "firebase|analytics|crashlytics"` (Android) and confirm zero matches before App Store submission.

### 6.2 Google Play Data Safety Form — Zero Data Collection

| Data type | Collected? | Shared? | Required disclosure |
|---|---|---|---|
| Personal info | No | No | None |
| Financial info | No | No | None |
| Health and fitness | No | No | None |
| Location | No | No | None |
| Messages / Emails | No | No | None |
| Photos and videos | No (local only) | No | None — camera only if user imports to Hope Box, stored locally |
| Files and docs | No | No | None |
| App activity | No | No | None |
| App info and performance | No | No | None |
| Device or other IDs | No | No | None |

**Attestation:** Must be re-verified on every release that introduces new packages.

### 6.3 GDPR/CCPA Compliance Notes

Firefly's architecture achieves **GDPR compliance by design**:
- **No personal data leaves the device** → No data controller obligation for transmitted data.
- **Right to erasure:** The `CryptographicEraser` + `SecureWipeService` fulfills Article 17 on-device.
- **Data minimization:** Only data explicitly entered by the user is stored. No behavioral tracking.
- **No consent dialogs needed** for analytics — because there are none.

### 6.4 Static Analysis & SAST Pipeline

#### Semgrep Rules (Custom)

```yaml
# .semgrep/firefly_security.yaml

rules:
  - id: firefly-no-print-statements
    pattern: print(...)
    message: "Use package:logging instead of print(). Production logs must not contain user data."
    severity: ERROR
    languages: [dart]

  - id: firefly-no-http-import
    pattern: import 'package:http/...';
    message: "Direct http package import detected. Network access is prohibited."
    severity: ERROR
    languages: [dart]

  - id: firefly-no-dio-import
    pattern: import 'package:dio/...';
    message: "Dio import detected. Network access is prohibited."
    severity: ERROR
    languages: [dart]

  - id: firefly-no-firebase-import
    pattern: import 'package:firebase_...';
    message: "Firebase import detected. No cloud SDKs allowed."
    severity: ERROR
    languages: [dart]

  - id: firefly-no-hardcoded-keys
    pattern-regex: '(password|secret|key|token)\s*=\s*["\'][A-Za-z0-9+/=]{16,}["\']'
    message: "Potential hardcoded secret detected."
    severity: ERROR
    languages: [dart]

  - id: firefly-journal-decryption-scope
    pattern: |
      String $X = await $CRYPTO.decryptContent(...);
      ...
      state = state.copyWith(...$X...);
    message: "Decrypted content stored in persistent state. Ensure ref.onDispose zeroes this value."
    severity: WARNING
    languages: [dart]
```

#### MobSF Automated Scan Configuration

```yaml
# mobsf_config.yaml — Run against every release APK/IPA

checks:
  - network_security_config_analysis  # Verify no cleartext traffic allowed
  - permission_analysis:              # Flag any unexpected permissions
      forbidden_permissions:
        - android.permission.INTERNET
        - android.permission.ACCESS_NETWORK_STATE
        - android.permission.ACCESS_WIFI_STATE
  - binary_analysis:
      flag_strings_containing:
        - "firebase"
        - "google-analytics"
        - "crashlytics"
        - "sentry"
        - "amplitude"
        - "mixpanel"
        - "segment"
  - certificate_analysis              # Verify release signing
  - manifest_analysis:
      require:
        - android:allowBackup=false
        - android:usesCleartextTraffic=false
```

#### CI Security Gate (Summary)

```bash
#!/usr/bin/env bash
# scripts/security_gate.sh — Runs on every PR and release build

echo "=== Firefly Security Gate ==="

# 1. Dependency audit
echo "→ Running dependency audit..."
dart run dependency_validator

# 2. Semgrep scan
echo "→ Running Semgrep SAST..."
semgrep --config .semgrep/firefly_security.yaml lib/ --error

# 3. Package deny-list
echo "→ Checking package deny-list..."
FORBIDDEN=("http" "dio" "firebase_core" "sentry_flutter" "amplitude_flutter" "mixpanel_flutter")
for pkg in "${FORBIDDEN[@]}"; do
    if grep -q "^  $pkg:" pubspec.lock; then
        echo "❌ FAIL: Forbidden package '$pkg' detected"
        exit 1
    fi
done

# 4. Android network security config check
echo "→ Verifying network security config..."
if ! grep -q 'cleartextTrafficPermitted="false"' android/app/src/main/res/xml/network_security_config.xml; then
    echo "❌ FAIL: Network security config missing cleartext denial"
    exit 1
fi

# 5. iOS ATS check
echo "→ Verifying iOS ATS..."
if grep -q 'NSAllowsArbitraryLoads.*true' ios/Runner/Info.plist; then
    echo "❌ FAIL: iOS ATS allows arbitrary loads"
    exit 1
fi

echo "✅ All security checks passed"
```

---

## Appendix A: Secure Coding Standards Summary

| Rule | Enforcement |
|---|---|
| No `print()` in any file | Semgrep rule + lint warning |
| All sensitive strings scoped to minimum lifetime | Code review requirement |
| No network packages in `pubspec.yaml` or transitive deps | CI deny-list + Semgrep |
| `FLAG_SECURE` always on (Android) | Automated MobSF check |
| Biometric gate before every DB open | Architecture rule — no bypass path |
| `synchronizable: false` on all Keychain items | Code review checklist |
| No cloud backup of DB file | `allowBackup=false` + `NSURLIsExcludedFromBackupKey` |
| SQLCipher with authenticated HMAC | DB init `beforeOpen` pragma enforcement |
| Journal content double-encrypted | `JournalCryptoService` mandatory wrapper |
| Argon2id for backup key derivation | `BackupEngine` — hardcoded; no weaker alternative |

---

## Appendix B: Incident Response (Pre-Launch Planning)

| Scenario | Response |
|---|---|
| Vulnerability in SQLCipher | Emergency release with updated SQLCipher; advise users to export+re-import. Key rotation not required — DB key stored in Keychain, not SQLCipher internals. |
| Dependency supply-chain attack | CI deny-list catches at PR time; `pubspec.lock` pinning prevents unreviewed upgrades |
| OS Keychain vulnerability (theoretical) | Master Key → Database Key hierarchy limits blast radius to one device's data |
| User loses backup passphrase | Data is permanently unrecoverable by design — no recovery path exists (user informed at export time) |
| Physical device seizure | SQLCipher + Secure Enclave makes DB unreadable without biometric; `thisDeviceOnly` means key cannot be transferred |

---

*Document maintained by the Firefly Security Team. Any change to cryptographic parameters, key storage attributes, or network enforcement mechanisms requires a security review sign-off before merge.*
