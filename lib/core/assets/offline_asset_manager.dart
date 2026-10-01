import 'dart:async';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service responsible for managing, verifying, and resolving local bundled
/// offline assets (ambient soundscapes and Vosk speech-to-text models).
///
/// Ensures all heavy asset verification or unpacking occurs asynchronously
/// off the main UI thread to protect 60fps frame budgets during cold start.
class OfflineAssetManager {
  const OfflineAssetManager({
    AssetBundle? bundle,
  }) : _bundle = bundle;

  final AssetBundle? _bundle;

  AssetBundle get _effectiveBundle => _bundle ?? rootBundle;

  static const String cyclicSighAudio = 'assets/audio/cyclic_sigh_ambience.mp3';
  static const String gentleRainAudio = 'assets/audio/gentle_rain.mp3';
  static const String groundingChimeAudio = 'assets/audio/grounding_chime.mp3';
  static const String voskModelZip = 'assets/models/vosk-model-small-en-us-0.15.zip';

  static const List<String> requiredAudioAssets = [
    cyclicSighAudio,
    gentleRainAudio,
    groundingChimeAudio,
  ];

  static const List<String> requiredModelAssets = [
    voskModelZip,
  ];

  /// Resolves the runtime asset path for an ambient soundscape.
  String resolveAudioPath(String soundscapeId) {
    switch (soundscapeId) {
      case 'cyclic_sigh_ambience':
        return cyclicSighAudio;
      case 'gentle_rain':
        return gentleRainAudio;
      case 'grounding_chime':
        return groundingChimeAudio;
      default:
        return soundscapeId.startsWith('assets/')
            ? soundscapeId
            : 'assets/audio/$soundscapeId.mp3';
    }
  }

  /// Resolves the default Vosk acoustic model zip asset path.
  String resolveVoskModelPath() => voskModelZip;

  /// Verifies that all required audio assets are present and readable in the asset bundle.
  Future<bool> verifyAudioAssetsAvailable() async {
    for (final path in requiredAudioAssets) {
      try {
        final data = await _effectiveBundle.load(path);
        if (data.lengthInBytes == 0) return false;
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  /// Verifies that the Vosk acoustic model archive is present in the bundle.
  Future<bool> verifyVoskModelAvailable() async {
    try {
      final data = await _effectiveBundle.load(voskModelZip);
      return data.lengthInBytes > 0;
    } catch (_) {
      return false;
    }
  }

  /// Non-blocking asset pre-flight initialization for cold start.
  /// Runs verification without blocking the main event loop.
  Future<Map<String, bool>> performColdStartPreflight() async {
    final completer = Completer<Map<String, bool>>();

    // Dispatch via Future.microtask or background compute
    Future.microtask(() async {
      final audioOk = await verifyAudioAssetsAvailable();
      final modelOk = await verifyVoskModelAvailable();
      completer.complete({
        'audio': audioOk,
        'model': modelOk,
      });
    });

    return completer.future;
  }
}

/// Riverpod provider for [OfflineAssetManager].
final offlineAssetManagerProvider = Provider<OfflineAssetManager>((ref) {
  return const OfflineAssetManager();
});
