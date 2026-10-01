import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/contracts/audio_player_port.dart';
import '../../../../core/contracts/haptics_port.dart';
import '../../data/adapters/flutter_haptics_adapter.dart';
import '../../data/adapters/just_audio_player_adapter.dart';

/// Provider for audio playback port in respiration and grounding experiences.
final audioPlayerPortProvider = Provider.autoDispose<AudioPlayerPort>((ref) {
  final adapter = JustAudioPlayerAdapter();
  ref.onDispose(() => adapter.dispose());
  return adapter;
});

/// Provider for haptics feedback port in respiration and grounding experiences.
final hapticsPortProvider = Provider<HapticsPort>((ref) {
  return FlutterHapticsAdapter();
});
