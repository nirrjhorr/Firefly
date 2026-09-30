import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../errors/result.dart';
import 'key_manager.dart';

part 'biometric_guard.g.dart';

class BiometricGuard {
  final LocalAuthentication _localAuth;
  final KeyManager _keyManager;
  
  // In-memory reference that we drop when locked
  String? _unlockedKey;

  BiometricGuard(this._localAuth, this._keyManager);

  /// Authenticates the user and returns the DB key if successful.
  Future<Result<String, Failure>> authenticateAndGetDatabaseKey() async {
    if (_unlockedKey != null) {
      return Ok(_unlockedKey!);
    }

    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics && !isDeviceSupported) {
        // Device lacks passcode/biometrics. We warn, but may have to proceed or block.
        // PRD says: Refuse DB open if device has no passcode set (warn user).
        return const Err(BiometricFailure('Device has no passcode set. Firefly requires a secure lock screen.'));
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Unlock Firefly to access your private data.',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow passcode fallback
        ),
      );

      if (authenticated) {
        _unlockedKey = await _keyManager.getOrGenerateDatabaseKey();
        return Ok(_unlockedKey!);
      } else {
        return const Err(BiometricFailure('Authentication failed.'));
      }
    } on PlatformException catch (e) {
      return Err(BiometricFailure('Authentication error: ${e.message}'));
    }
  }

  /// Drops the in-memory key reference, locking the app.
  void lockApp() {
    _unlockedKey = null;
  }
}

class BiometricFailure extends Failure {
  const BiometricFailure(super.message);
}

@riverpod
LocalAuthentication localAuth(LocalAuthRef ref) {
  return LocalAuthentication();
}

@riverpod
BiometricGuard biometricGuard(BiometricGuardRef ref) {
  return BiometricGuard(
    ref.watch(localAuthProvider),
    ref.watch(keyManagerProvider),
  );
}
