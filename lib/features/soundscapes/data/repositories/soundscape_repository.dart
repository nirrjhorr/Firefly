import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/soundscape_playlist.dart';
import '../../domain/models/soundscape_track.dart';

/// Repository interface for catalogued offline relaxation audio soundscapes.
abstract class SoundscapeRepository {
  Future<List<SoundscapeTrack>> getAllTracks();
  Future<List<SoundscapeTrack>> getTracksByCategory(String category);
  Future<List<SoundscapeTrack>> getTracksByUseCase(String useCase);
  Future<List<SoundscapeTrack>> getTracksForPlaylist(String playlistId);
  Future<SoundscapeTrack?> getTrackById(String id);
  List<SoundscapePlaylist> getCuratedPlaylists();
}

/// Offline asset-backed implementation of [SoundscapeRepository]
class AssetSoundscapeRepository implements SoundscapeRepository {
  final AssetBundle _bundle;
  List<SoundscapeTrack>? _cachedTracks;

  AssetSoundscapeRepository({AssetBundle? bundle})
      : _bundle = bundle ?? rootBundle;

  @override
  Future<List<SoundscapeTrack>> getAllTracks() async {
    if (_cachedTracks != null) return _cachedTracks!;

    try {
      final jsonString =
          await _bundle.loadString('assets/audio/audio_catalogue.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> trackList = data['tracks'] ?? [];
      _cachedTracks = trackList
          .map((item) => SoundscapeTrack.fromJson(item as Map<String, dynamic>))
          .toList();
      return _cachedTracks!;
    } catch (_) {
      // Fallback: return default core soundscapes if catalogue load fails
      return _fallbackTracks;
    }
  }

  @override
  Future<List<SoundscapeTrack>> getTracksByCategory(String category) async {
    final all = await getAllTracks();
    if (category.toLowerCase() == 'all') return all;
    return all
        .where((t) => t.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  @override
  Future<List<SoundscapeTrack>> getTracksByUseCase(String useCase) async {
    final all = await getAllTracks();
    return all.where((t) {
      return t.useCases.any((u) => u.toLowerCase().contains(useCase.toLowerCase()));
    }).toList();
  }

  @override
  Future<List<SoundscapeTrack>> getTracksForPlaylist(String playlistId) async {
    final all = await getAllTracks();
    final playlist = kCuratedPlaylists.firstWhere(
      (p) => p.id == playlistId,
      orElse: () => kCuratedPlaylists.first,
    );
    final trackMap = {for (final t in all) t.id: t};
    return playlist.trackIds
        .map((id) => trackMap[id])
        .whereType<SoundscapeTrack>()
        .toList();
  }

  @override
  Future<SoundscapeTrack?> getTrackById(String id) async {
    final all = await getAllTracks();
    try {
      return all.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<SoundscapePlaylist> getCuratedPlaylists() => kCuratedPlaylists;
}

final soundscapeRepositoryProvider = Provider<SoundscapeRepository>((ref) {
  return AssetSoundscapeRepository();
});

final soundscapeCatalogueProvider =
    FutureProvider<List<SoundscapeTrack>>((ref) async {
  final repo = ref.watch(soundscapeRepositoryProvider);
  return repo.getAllTracks();
});

const List<SoundscapeTrack> _fallbackTracks = [
  SoundscapeTrack(
    id: 'gentle_rain',
    title: 'Gentle Rain',
    category: 'nature',
    subcategory: 'rain',
    description: 'Continuous soft rainfall providing steady acoustic masking.',
    durationSeconds: 150.0,
    assetPath: 'assets/audio/gentle_rain.mp3',
    fileSizeBytes: 3775087,
    sha256: '967eab5ddc2b84808a05fea757460d51461e9dc56e72a3d1490bbb58e7bc6578',
    evidenceCategory: 'Evidence Supported',
    evidenceNotes: 'Broadband acoustic water noise significantly reduces cortical arousal.',
    mood: 'Peaceful',
    environment: 'Outdoor Rain',
    license: 'MIT / CC0',
    source: 'Moodist Open Audio Library',
    creator: 'Remvze & Community Field Recordists',
    attribution: 'Curated under MIT License.',
  ),
  SoundscapeTrack(
    id: 'cyclic_sigh_ambience',
    title: 'Cyclic Sighing Breeze',
    category: 'relaxation',
    subcategory: 'breathing',
    description: 'Breath-like gentle atmospheric wind.',
    durationSeconds: 73.0,
    assetPath: 'assets/audio/cyclic_sigh_ambience.mp3',
    fileSizeBytes: 1606823,
    sha256: 'e8c205735f448c9df385800d9a6c116c968f94e9f9fc7c13daff43149ca71a4f',
    evidenceCategory: 'Evidence Supported',
    evidenceNotes: 'Structured breath-paced acoustic accompaniment optimizes vagal brake recruitment.',
    mood: 'Restorative',
    environment: 'Open Mountain Vista',
    license: 'MIT / CC0',
    source: 'Moodist Open Audio Library',
    creator: 'Remvze & Community Field Recordists',
    attribution: 'Curated under MIT License.',
  ),
  SoundscapeTrack(
    id: 'grounding_chime',
    title: 'Tibetan Singing Bowl',
    category: 'relaxation',
    subcategory: 'meditation',
    description: 'Warm, resonant bronze Tibetan singing bowl tone.',
    durationSeconds: 49.0,
    assetPath: 'assets/audio/grounding_chime.mp3',
    fileSizeBytes: 431808,
    sha256: '72566ecaa002a24564c740fa12da6cb0eebf1f337ef40e4f208c5c7d24771485',
    evidenceCategory: 'Evidence Supported',
    evidenceNotes: 'Singing bowl sound meditation reduces tension, anger, and fatigue.',
    mood: 'Sacred',
    environment: 'Meditation Space',
    license: 'MIT / CC0',
    source: 'Moodist Open Audio Library',
    creator: 'Remvze & Sound Designers',
    attribution: 'Curated under MIT License.',
  ),
];
