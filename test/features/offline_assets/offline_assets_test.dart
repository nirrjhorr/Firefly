import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firefly/core/assets/offline_asset_manager.dart';
import 'package:firefly/core/security/network_kill_switch.dart';

class FakeAssetBundle extends CachingAssetBundle {
  final Map<String, ByteData> _assets = {};

  void addAsset(String path, List<int> bytes) {
    _assets[path] = ByteData.view(Uint8List.fromList(bytes).buffer);
  }

  @override
  Future<ByteData> load(String key) async {
    final asset = _assets[key];
    if (asset != null) return asset;
    throw FlutterError('Unable to load asset: $key');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Enforce Zero Network Policy
    FireflyHttpOverride.install();
  });

  group('OfflineAssetManager - Path Resolution', () {
    const manager = OfflineAssetManager();

    test('resolves known audio soundscape IDs to bundled asset paths', () {
      expect(
        manager.resolveAudioPath('cyclic_sigh_ambience'),
        'assets/audio/cyclic_sigh_ambience.mp3',
      );
      expect(
        manager.resolveAudioPath('gentle_rain'),
        'assets/audio/gentle_rain.mp3',
      );
      expect(
        manager.resolveAudioPath('grounding_chime'),
        'assets/audio/grounding_chime.mp3',
      );
    });

    test('resolves fallback custom audio filenames safely', () {
      expect(
        manager.resolveAudioPath('waves'),
        'assets/audio/waves.mp3',
      );
      expect(
        manager.resolveAudioPath('assets/audio/custom.mp3'),
        'assets/audio/custom.mp3',
      );
    });

    test('resolves default Vosk model archive path', () {
      expect(
        manager.resolveVoskModelPath(),
        'assets/models/vosk-model-small-en-us-0.15.zip',
      );
    });
  });

  group('OfflineAssetManager - Asset Availability & Verification', () {
    test('returns false when bundle has missing assets', () async {
      final fakeBundle = FakeAssetBundle();
      final manager = OfflineAssetManager(bundle: fakeBundle);

      final audioAvailable = await manager.verifyAudioAssetsAvailable();
      final modelAvailable = await manager.verifyVoskModelAvailable();

      expect(audioAvailable, isFalse);
      expect(modelAvailable, isFalse);
    });

    test('returns true when required audio assets and Vosk model are present in bundle', () async {
      final fakeBundle = FakeAssetBundle();
      fakeBundle.addAsset(
        OfflineAssetManager.cyclicSighAudio,
        [0xFF, 0xFB, 0x90, 0x64],
      );
      fakeBundle.addAsset(
        OfflineAssetManager.gentleRainAudio,
        [0xFF, 0xFB, 0x90, 0x64],
      );
      fakeBundle.addAsset(
        OfflineAssetManager.groundingChimeAudio,
        [0xFF, 0xFB, 0x90, 0x64],
      );
      fakeBundle.addAsset(
        OfflineAssetManager.voskModelZip,
        [0x50, 0x4B, 0x03, 0x04], // ZIP magic header
      );

      final manager = OfflineAssetManager(bundle: fakeBundle);

      expect(await manager.verifyAudioAssetsAvailable(), isTrue);
      expect(await manager.verifyVoskModelAvailable(), isTrue);
    });
  });

  group('OfflineAssetManager - Cold Start Preflight & Non-Blocking Execution', () {
    test('cold start preflight executes asynchronously without blocking', () async {
      final fakeBundle = FakeAssetBundle();
      fakeBundle.addAsset(OfflineAssetManager.cyclicSighAudio, [1, 2, 3]);
      fakeBundle.addAsset(OfflineAssetManager.gentleRainAudio, [1, 2, 3]);
      fakeBundle.addAsset(OfflineAssetManager.groundingChimeAudio, [1, 2, 3]);
      fakeBundle.addAsset(OfflineAssetManager.voskModelZip, [1, 2, 3]);

      final manager = OfflineAssetManager(bundle: fakeBundle);

      final stopwatch = Stopwatch()..start();
      final preflightFuture = manager.performColdStartPreflight();

      // UI thread should not be blocked: future should yield execution
      expect(stopwatch.elapsedMilliseconds, lessThan(50));

      final result = await preflightFuture;
      expect(result['audio'], isTrue);
      expect(result['model'], isTrue);
    });
  });
}
