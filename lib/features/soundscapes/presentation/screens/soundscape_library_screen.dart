import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../data/repositories/soundscape_repository.dart';
import '../../domain/models/soundscape_playlist.dart';
import '../../domain/models/soundscape_track.dart';
import '../controllers/soundscape_player_controller.dart';

/// Full-featured, evidence-informed relaxation audio library screen.
/// Follows Apple HIG principles with clean typography, calm contrast, and low sensory load.
class SoundscapeLibraryScreen extends ConsumerStatefulWidget {
  const SoundscapeLibraryScreen({super.key});

  @override
  ConsumerState<SoundscapeLibraryScreen> createState() =>
      _SoundscapeLibraryScreenState();
}

class _SoundscapeLibraryScreenState
    extends ConsumerState<SoundscapeLibraryScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';

  final List<String> _categories = [
    'all',
    'nature',
    'sleep',
    'focus',
    'relaxation',
    'ambient',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final catalogueAsync = ref.watch(soundscapeCatalogueProvider);
    final playerState = ref.watch(soundscapePlayerProvider);
    final playlists = ref.watch(soundscapeRepositoryProvider).getCuratedPlaylists();

    return Scaffold(
      backgroundColor: colors.canvasBackdrop,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Sound Sanctuary',
          style: AppTypography.headlineSm.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Audio Attributions & Licences',
            icon: Icon(AppIcons.license, color: colors.textSecondary),
            iconSize: IconSizeTokens.appAction,
            onPressed: () => _showLicenseDialog(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          catalogueAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Text(
                'Unable to load audio library: $err',
                style: AppTypography.bodyMd.copyWith(color: colors.textSecondary),
              ),
            ),
            data: (allTracks) {
              final filteredTracks = allTracks.where((t) {
                final matchesCategory = _selectedCategory == 'all' ||
                    t.category.toLowerCase() == _selectedCategory.toLowerCase();
                final matchesSearch = _searchQuery.isEmpty ||
                    t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    t.tags.any((tag) =>
                        tag.toLowerCase().contains(_searchQuery.toLowerCase()));
                return matchesCategory && matchesSearch;
              }).toList();

              return CustomScrollView(
                slivers: [
                  // Evidence Header Banner
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.spaceMd,
                        vertical: SpacingTokens.spaceSm,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(SpacingTokens.spaceMd),
                        decoration: BoxDecoration(
                          color: colors.surfaceCard,
                          borderRadius: BorderRadius.circular(RadiusTokens.card),
                          border: Border.all(color: colors.borderSubtle),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(AppIcons.scientificEvidence,
                                color: colors.actionSage, size: IconSizeTokens.standard),
                            const SizedBox(width: SpacingTokens.spaceSm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '100% Offline • Evidence Informed',
                                    style: AppTypography.labelMd.copyWith(
                                      color: colors.actionSage,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Scientifically curated natural acoustics, non-intrusive sound masking, and respiration drones for nervous system de-escalation.',
                                    style: AppTypography.bodySm.copyWith(
                                      color: colors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Curated Playlists Carousel
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            SpacingTokens.spaceMd,
                            SpacingTokens.spaceMd,
                            SpacingTokens.spaceMd,
                            SpacingTokens.spaceXs,
                          ),
                          child: Text(
                            'Curated Playlists',
                            style: AppTypography.headlineSm.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: SpacingTokens.spaceMd,
                            ),
                            itemCount: playlists.length,
                            itemBuilder: (context, index) {
                              final p = playlists[index];
                              return _buildPlaylistCard(context, p, allTracks);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category Filter Tabs
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: SpacingTokens.spaceMd,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.spaceMd,
                        ),
                        child: Row(
                          children: _categories.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(
                                  cat[0].toUpperCase() + cat.substring(1),
                                  style: AppTypography.labelMd.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : colors.textSecondary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: colors.actionSage,
                                backgroundColor: colors.surfaceCard,
                                side: BorderSide(
                                  color: isSelected
                                      ? colors.actionSage
                                      : colors.borderSubtle,
                                ),
                                onSelected: (val) {
                                  if (val) {
                                    setState(() => _selectedCategory = cat);
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),

                  // Track Count Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.spaceMd,
                        vertical: SpacingTokens.space2xs,
                      ),
                      child: Text(
                        '${filteredTracks.length} Available Soundscapes',
                        style: AppTypography.bodySm.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Track List
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final track = filteredTracks[index];
                        final isPlayingThis =
                            playerState.activeTrack?.id == track.id &&
                                playerState.isPlaying;

                        return _buildTrackTile(context, track, isPlayingThis);
                      },
                      childCount: filteredTracks.length,
                    ),
                  ),

                  // Bottom padding for sticky player bar
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 120),
                  ),
                ],
              );
            },
          ),

          // Floating Player Control Bar
          if (playerState.activeTrack != null)
            Positioned(
              left: SpacingTokens.spaceMd,
              right: SpacingTokens.spaceMd,
              bottom: SpacingTokens.spaceLg,
              child: _buildFloatingPlayerBar(context, playerState),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaylistCard(
    BuildContext context,
    SoundscapePlaylist playlist,
    List<SoundscapeTrack> allTracks,
  ) {
    final colors = context.colors;
    final trackCount = playlist.trackIds.length;

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: SpacingTokens.spaceSm),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(RadiusTokens.card),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(RadiusTokens.card),
        onTap: () => _playFirstInPlaylist(playlist, allTracks),
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: playlist.accentColor.withOpacity(0.15),
                    child: Icon(
                      playlist.icon,
                      color: playlist.accentColor,
                      size: IconSizeTokens.appAction,
                    ),
                  ),
                  Text(
                    '$trackCount tracks',
                    style: AppTypography.bodySm.copyWith(
                      color: colors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelLg.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    playlist.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySm.copyWith(
                      color: colors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _playFirstInPlaylist(
      SoundscapePlaylist playlist, List<SoundscapeTrack> allTracks) {
    if (playlist.trackIds.isEmpty) return;
    final firstId = playlist.trackIds.first;
    final track = allTracks.firstWhere(
      (t) => t.id == firstId,
      orElse: () => allTracks.first,
    );
    ref.read(soundscapePlayerProvider.notifier).playTrack(track);
  }

  Widget _buildTrackTile(
    BuildContext context,
    SoundscapeTrack track,
    bool isPlaying,
  ) {
    final colors = context.colors;
    final isSupported = track.evidenceCategory == 'Evidence Supported';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.spaceMd,
        vertical: SpacingTokens.space2xs,
      ),
      decoration: BoxDecoration(
        color: isPlaying
            ? colors.actionSage.withOpacity(0.12)
            : colors.surfaceCard,
        borderRadius: BorderRadius.circular(RadiusTokens.card),
        border: Border.all(
          color: isPlaying
              ? colors.actionSage.withOpacity(0.4)
              : colors.borderSubtle,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.spaceMd,
          vertical: SpacingTokens.space2xs,
        ),
        leading: CircleAvatar(
          backgroundColor: isPlaying
              ? colors.actionSage
              : colors.actionSage.withOpacity(0.15),
          child: Icon(
            isPlaying ? AppIcons.pause : AppIcons.play,
            color: isPlaying ? Colors.white : colors.actionSage,
            size: IconSizeTokens.appAction,
          ),
        ),
        title: Text(
          track.title,
          style: AppTypography.labelLg.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              track.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySm.copyWith(
                color: colors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSupported
                        ? colors.actionSage.withOpacity(0.15)
                        : colors.accentLavender.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(RadiusTokens.xs),
                  ),
                  child: Text(
                    track.evidenceCategory,
                    style: AppTypography.bodySm.copyWith(
                      color: isSupported ? colors.actionSage : colors.accentLavender,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(track.durationSeconds / 60).toStringAsFixed(1)}m loop',
                  style: AppTypography.bodySm.copyWith(
                    color: colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(AppIcons.info, color: colors.textSecondary, size: IconSizeTokens.appAction),
          onPressed: () => _showTrackEvidenceSheet(context, track),
        ),
        onTap: () {
          if (isPlaying) {
            ref.read(soundscapePlayerProvider.notifier).togglePlayPause();
          } else {
            ref.read(soundscapePlayerProvider.notifier).playTrack(track);
          }
        },
      ),
    );
  }

  Widget _buildFloatingPlayerBar(
    BuildContext context,
    SoundscapePlayerState state,
  ) {
    final colors = context.colors;
    final track = state.activeTrack!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.spaceMd,
        vertical: SpacingTokens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(RadiusTokens.dialog),
        border: Border.all(color: colors.actionSage.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors.actionSage,
            radius: 20,
            child: IconButton(
              icon: Icon(
                state.isPlaying ? AppIcons.pause : AppIcons.play,
                color: Colors.white,
                size: IconSizeTokens.appAction,
              ),
              onPressed: () =>
                  ref.read(soundscapePlayerProvider.notifier).togglePlayPause(),
            ),
          ),
          const SizedBox(width: SpacingTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLg.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  state.sleepTimerSecondsRemaining != null
                      ? 'Sleep Timer: ${state.sleepTimerSecondsRemaining! ~/ 60}m ${state.sleepTimerSecondsRemaining! % 60}s'
                      : 'Looping naturally • Offline',
                  style: AppTypography.bodySm.copyWith(
                    color: colors.actionSage,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sleep Timer',
            icon: Icon(AppIcons.timer, color: colors.textSecondary, size: IconSizeTokens.appAction),
            onPressed: () => _showSleepTimerPicker(context),
          ),
          IconButton(
            tooltip: 'Volume & Evidence',
            icon: Icon(AppIcons.filter, color: colors.textSecondary, size: IconSizeTokens.appAction),
            onPressed: () => _showVolumeSlider(context),
          ),
          IconButton(
            tooltip: 'Stop',
            icon: Icon(AppIcons.close, color: colors.textSecondary, size: IconSizeTokens.appAction),
            onPressed: () => ref.read(soundscapePlayerProvider.notifier).stop(),
          ),
        ],
      ),
    );
  }

  void _showSleepTimerPicker(BuildContext context) {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusTokens.sheet)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.spaceLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-Stop Sleep Timer',
                  style: AppTypography.headlineSm.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: SpacingTokens.spaceMd),
                ...[15, 30, 45, 60].map((mins) {
                  return ListTile(
                    title: Text('$mins Minutes',
                        style: TextStyle(color: colors.textPrimary)),
                    onTap: () {
                      ref
                          .read(soundscapePlayerProvider.notifier)
                          .setSleepTimer(mins);
                      Navigator.pop(context);
                    },
                  );
                }),
                ListTile(
                  title: Text('Turn Off Timer',
                      style: TextStyle(color: colors.actionSage)),
                  onTap: () {
                    ref
                        .read(soundscapePlayerProvider.notifier)
                        .setSleepTimer(null);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showVolumeSlider(BuildContext context) {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusTokens.sheet)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(soundscapePlayerProvider);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.spaceLg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Volume Balance',
                        style: AppTypography.headlineSm
                            .copyWith(color: colors.textPrimary)),
                    const SizedBox(height: SpacingTokens.spaceMd),
                    Row(
                      children: [
                        Icon(AppIcons.volumeDown, color: colors.textSecondary, size: IconSizeTokens.appAction),
                        Expanded(
                          child: Slider(
                            value: state.volume,
                            activeColor: colors.actionSage,
                            onChanged: (val) {
                              ref
                                  .read(soundscapePlayerProvider.notifier)
                                  .setVolume(val);
                            },
                          ),
                        ),
                        Icon(AppIcons.volumeUp, color: colors.textSecondary, size: IconSizeTokens.appAction),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showTrackEvidenceSheet(BuildContext context, SoundscapeTrack track) {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollCtrl) {
            return SingleChildScrollView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(SpacingTokens.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.borderSubtle,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.spaceMd),
                  Text(
                    track.title,
                    style: AppTypography.headlineSm.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${track.category.toUpperCase()} • ${track.subcategory.toUpperCase()}',
                    style: AppTypography.labelMd.copyWith(
                      color: colors.actionSage,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.spaceMd),
                  Text(
                    track.description,
                    style: AppTypography.bodyMd
                        .copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: SpacingTokens.spaceLg),

                  Text(
                    'Scientific Evidence Base',
                    style: AppTypography.labelLg.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(SpacingTokens.spaceMd),
                    decoration: BoxDecoration(
                      color: colors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      track.evidenceNotes,
                      style: AppTypography.bodySm.copyWith(
                        color: colors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.spaceLg),

                  Text(
                    'Technical & Acoustic Integrity',
                    style: AppTypography.labelLg.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _specRow('Duration', '${track.durationSeconds}s gapless loop'),
                  _specRow('Sample Rate', '${track.sampleRate} Hz'),
                  _specRow('Bitrate', '${track.bitrate ~/ 1000} kbps stereo'),
                  _specRow('Integrity Hash (SHA-256)', track.sha256.substring(0, 16) + '...'),
                  const SizedBox(height: SpacingTokens.spaceLg),

                  Text(
                    'Licence & Legal Attribution',
                    style: AppTypography.labelLg.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _specRow('Licence', track.license),
                  _specRow('Creator', track.creator),
                  _specRow('Attribution', track.attribution),
                  const SizedBox(height: SpacingTokens.spaceLg),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showLicenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Open Source Audio Licences'),
          content: const SingleChildScrollView(
            child: Text(
              'Firefly uses 100% verified royalty-free open-source, Creative Commons Zero (CC0), and MIT licensed audio recordings for ambient soundscapes.\n\n'
              'All assets are bundled locally inside the package with zero remote data transfer or external tracking.\n\n'
              'Source repositories include the Moodist open audio archive, Wikimedia Commons public domain recordings, and verified community field recordists.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
