import 'package:flutter/foundation.dart';

/// Clinical and relaxation sound categories.
enum SoundCategory {
  nature,
  ambient,
  music,
  sleep,
  focus,
  relaxation;

  String get displayName {
    switch (this) {
      case SoundCategory.nature:
        return 'Nature';
      case SoundCategory.ambient:
        return 'Ambient';
      case SoundCategory.music:
        return 'Music';
      case SoundCategory.sleep:
        return 'Sleep';
      case SoundCategory.focus:
        return 'Focus';
      case SoundCategory.relaxation:
        return 'Relaxation';
    }
  }
}

/// Level of empirical scientific evidence supporting the sound category.
enum EvidenceCategory {
  supported,
  suggestive,
  mixed,
  insufficient;

  String get label {
    switch (this) {
      case EvidenceCategory.supported:
        return 'Evidence Supported';
      case EvidenceCategory.suggestive:
        return 'Evidence Suggestive';
      case EvidenceCategory.mixed:
        return 'Evidence Mixed';
      case EvidenceCategory.insufficient:
        return 'Insufficient Evidence';
    }
  }
}

/// Fully catalogued offline relaxation soundscape entity.
@immutable
class SoundscapeTrack {
  final String id;
  final String title;
  final String category;
  final String subcategory;
  final String description;
  final double durationSeconds;
  final String assetPath;
  final int fileSizeBytes;
  final String sha256;
  final String format;
  final int sampleRate;
  final int channels;
  final int bitrate;
  final bool loopable;
  final double recommendedVolume;
  final String evidenceCategory;
  final String evidenceNotes;
  final double qualityScore;
  final String mood;
  final String environment;
  final List<String> tags;
  final List<String> useCases;
  final String license;
  final String source;
  final String creator;
  final String attribution;

  const SoundscapeTrack({
    required this.id,
    required this.title,
    required this.category,
    required this.subcategory,
    required this.description,
    required this.durationSeconds,
    required this.assetPath,
    required this.fileSizeBytes,
    required this.sha256,
    this.format = 'audio/mpeg',
    this.sampleRate = 44100,
    this.channels = 2,
    this.bitrate = 192000,
    this.loopable = true,
    this.recommendedVolume = 0.65,
    required this.evidenceCategory,
    required this.evidenceNotes,
    this.qualityScore = 9.0,
    required this.mood,
    required this.environment,
    this.tags = const [],
    this.useCases = const [],
    required this.license,
    required this.source,
    required this.creator,
    required this.attribution,
  });

  factory SoundscapeTrack.fromJson(Map<String, dynamic> json) {
    return SoundscapeTrack(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String,
      description: json['description'] as String,
      durationSeconds: (json['durationSeconds'] as num).toDouble(),
      assetPath: json['assetPath'] as String,
      fileSizeBytes: (json['fileSizeBytes'] as num).toInt(),
      sha256: json['sha256'] as String,
      format: (json['format'] as String?) ?? 'audio/mpeg',
      sampleRate: (json['sampleRate'] as num?)?.toInt() ?? 44100,
      channels: (json['channels'] as num?)?.toInt() ?? 2,
      bitrate: (json['bitrate'] as num?)?.toInt() ?? 192000,
      loopable: (json['loopable'] as bool?) ?? true,
      recommendedVolume: (json['recommendedVolume'] as num?)?.toDouble() ?? 0.65,
      evidenceCategory: json['evidenceCategory'] as String,
      evidenceNotes: json['evidenceNotes'] as String,
      qualityScore: (json['qualityScore'] as num?)?.toDouble() ?? 9.0,
      mood: json['mood'] as String,
      environment: json['environment'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      useCases: (json['useCases'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      license: json['license'] as String,
      source: json['source'] as String,
      creator: json['creator'] as String,
      attribution: json['attribution'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'subcategory': subcategory,
      'description': description,
      'durationSeconds': durationSeconds,
      'assetPath': assetPath,
      'fileSizeBytes': fileSizeBytes,
      'sha256': sha256,
      'format': format,
      'sampleRate': sampleRate,
      'channels': channels,
      'bitrate': bitrate,
      'loopable': loopable,
      'recommendedVolume': recommendedVolume,
      'evidenceCategory': evidenceCategory,
      'evidenceNotes': evidenceNotes,
      'qualityScore': qualityScore,
      'mood': mood,
      'environment': environment,
      'tags': tags,
      'useCases': useCases,
      'license': license,
      'source': source,
      'creator': creator,
      'attribution': attribution,
    };
  }
}
