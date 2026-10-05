import 'package:flutter_test/flutter_test.dart';
import 'package:firefly/features/soundscapes/domain/models/soundscape_track.dart';
import 'package:firefly/features/soundscapes/domain/models/soundscape_playlist.dart';

void main() {
  group('SoundscapeTrack Domain Model Tests', () {
    test('SoundscapeTrack fromJson and toJson serialization round-trip', () {
      final jsonMap = {
        'id': 'gentle_rain',
        'title': 'Gentle Rain',
        'category': 'nature',
        'subcategory': 'rain',
        'description': 'Continuous soft rainfall providing steady acoustic masking.',
        'durationSeconds': 149.87,
        'assetPath': 'assets/audio/gentle_rain.mp3',
        'fileSizeBytes': 3775087,
        'sha256': '967eab5ddc2b84808a05fea757460d51461e9dc56e72a3d1490bbb58e7bc6578',
        'format': 'audio/mpeg',
        'sampleRate': 44100,
        'channels': 2,
        'bitrate': 201518,
        'loopable': true,
        'recommendedVolume': 0.65,
        'evidenceCategory': 'Evidence Supported',
        'evidenceNotes': 'Broadband acoustic water noise significantly reduces cortical arousal.',
        'qualityScore': 9.4,
        'mood': 'Peaceful',
        'environment': 'Outdoor Rain',
        'tags': ['rain', 'water', 'gentle'],
        'useCases': ['Sleep', 'Relax'],
        'license': 'MIT / Creative Commons Zero',
        'source': 'Moodist Open Audio Library',
        'creator': 'Remvze & Community Field Recordists',
        'attribution': 'Curated by Remvze under MIT License from verified public domain/CC0 environmental field recordings.',
      };

      final track = SoundscapeTrack.fromJson(jsonMap);

      expect(track.id, 'gentle_rain');
      expect(track.title, 'Gentle Rain');
      expect(track.category, 'nature');
      expect(track.durationSeconds, 149.87);
      expect(track.loopable, isTrue);
      expect(track.tags, contains('rain'));

      final serialized = track.toJson();
      expect(serialized['id'], 'gentle_rain');
      expect(serialized['fileSizeBytes'], 3775087);
      expect(serialized['sha256'], '967eab5ddc2b84808a05fea757460d51461e9dc56e72a3d1490bbb58e7bc6578');
    });

    test('SoundCategory enums provide appropriate human-readable display names', () {
      expect(SoundCategory.nature.displayName, 'Nature');
      expect(SoundCategory.ambient.displayName, 'Ambient');
      expect(SoundCategory.sleep.displayName, 'Sleep');
      expect(SoundCategory.focus.displayName, 'Focus');
      expect(SoundCategory.relaxation.displayName, 'Relaxation');
    });

    test('Curated Playlists have valid track assignments and labels', () {
      final playlists = SoundscapePlaylist.curatedPlaylists;
      expect(playlists.length, 8);

      final resetPlaylist = playlists.firstWhere((p) => p.id == 'reset_10min');
      expect(resetPlaylist.title, '10-Minute Reset');
      expect(resetPlaylist.trackIds, contains('cyclic_sigh_ambience'));
      expect(resetPlaylist.trackIds.length, greaterThanOrEqualTo(3));
    });
  });
}
