import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/sos_overlay_button.dart';
import '../../../activities/presentation/widgets/effectiveness_feedback_dialog.dart';
import '../../domain/models/hope_box_item.dart';
import '../../domain/models/hope_box_state.dart';
import '../controllers/hope_box_controller.dart';
import '../widgets/add_hope_box_item_sheet.dart';
import '../widgets/hope_box_detail_dialog.dart';
import '../widgets/hope_box_item_card.dart';

/// Hope Box Screen (FR-07): Offline Multi-Media Coping Vault.
///
/// Principles:
/// - Low-stimulation dark canvas (`#111518`), warm amber/sage comforting accents.
/// - Privacy-preserving cards (icon + label, avoiding leaking private raw text/media on list view).
/// - Touch targets ≥ 56dp (64dp FAB for addition).
/// - Non-judgmental early exit and persistent SOS panic overlay.
class HopeBoxScreen extends ConsumerStatefulWidget {
  final bool showSosOverlay;

  const HopeBoxScreen({
    super.key,
    this.showSosOverlay = true,
  });

  @override
  ConsumerState<HopeBoxScreen> createState() => _HopeBoxScreenState();
}

class _HopeBoxScreenState extends ConsumerState<HopeBoxScreen> {
  final Stopwatch _sessionStopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _sessionStopwatch.start();
  }

  @override
  void dispose() {
    _sessionStopwatch.stop();
    super.dispose();
  }

  Future<void> _handleExit() async {
    final elapsedSec = _sessionStopwatch.elapsed.inSeconds;

    // If user spent time in the vault, gently offer effectiveness reflection
    if (elapsedSec >= 30) {
      await EffectivenessFeedbackSheet.show(
        context,
        activityId: 'act_hope_box_glance',
        stateAtStart: 'lonely',
        durationSeconds: elapsedSec > 0 ? elapsedSec : 30,
      );
    }

    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.home);
      }
    }
  }

  void _openItemDetail(HopeBoxItem item) async {
    final notifier = ref.read(hopeBoxControllerProvider.notifier);
    final decrypted = await notifier.decryptContent(item);

    if (mounted) {
      HopeBoxDetailDialog.show(
        context: context,
        item: item,
        decryptedContent: decrypted,
        onDelete: () => notifier.deleteItem(item.id),
        onTogglePin: () => notifier.togglePin(item.id),
      );
    }
  }

  void _openAddItemSheet() {
    final notifier = ref.read(hopeBoxControllerProvider.notifier);

    AddHopeBoxItemSheet.show(
      context: context,
      onSave: ({
        required HopeBoxItemType type,
        required String title,
        required String content,
        String? filePath,
        String? caption,
        required String category,
      }) async {
        switch (type) {
          case HopeBoxItemType.reason:
            await notifier.addReason(content, category: category);
            break;
          case HopeBoxItemType.text:
            await notifier.addTextNote(title, content, category: category);
            break;
          case HopeBoxItemType.photo:
            await notifier.addPhoto(
              title: title,
              filePath: filePath ?? '',
              caption: caption,
              category: category,
            );
            break;
          case HopeBoxItemType.voice:
            await notifier.addVoiceNote(
              title: title,
              filePath: filePath ?? '',
              category: category,
            );
            break;
          case HopeBoxItemType.audio:
            await notifier.addAudio(
              title: title,
              filePath: filePath ?? '',
              category: category,
            );
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hopeBoxControllerProvider);
    final notifier = ref.read(hopeBoxControllerProvider.notifier);

    const canvasBg = Color(0xFF111518); // ink900
    const warmAmber = Color(0xFFE5B870); // amber300
    const sage300 = Color(0xFF84B09A); // sage300
    const neutral100 = Color(0xFFE8ECF0);
    const neutral300 = Color(0xFF9AAAB6);
    const cardBg = Color(0xFF191E23);

    final filteredItems = state.filteredItems;

    return Scaffold(
      backgroundColor: canvasBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.lg,
                    vertical: SpacingTokens.sm,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: neutral300,
                          size: 20,
                        ),
                        tooltip: 'Back',
                        onPressed: _handleExit,
                      ),
                      const SizedBox(width: SpacingTokens.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hope Box',
                              style: AppTypography.headingSmall.copyWith(
                                color: neutral100,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Things worth holding onto',
                              style: AppTypography.caption.copyWith(
                                color: sage300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _handleExit,
                        child: Text(
                          "That's enough for now",
                          style: AppTypography.caption.copyWith(
                            color: neutral300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Category Filter Chips
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.lg,
                    vertical: SpacingTokens.xs,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: HopeBoxFilter.values.map((filter) {
                        final isSelected = filter == state.filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: SpacingTokens.sm),
                          child: FilterChip(
                            label: Text(filter.label),
                            selected: isSelected,
                            selectedColor: sage300.withOpacity(0.2),
                            backgroundColor: cardBg,
                            checkmarkColor: sage300,
                            labelStyle: AppTypography.caption.copyWith(
                              color: isSelected ? sage300 : neutral300,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(RadiusTokens.full),
                              side: BorderSide(
                                color: isSelected ? sage300 : const Color(0xFF2E3840),
                              ),
                            ),
                            onSelected: (_) => notifier.setFilter(filter),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),

                // Main Content View
                Expanded(
                  child: state.isEmpty
                      ? _buildEmptyState(context)
                      : filteredItems.isEmpty
                          ? _buildFilteredEmptyState()
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                SpacingTokens.lg,
                                SpacingTokens.sm,
                                SpacingTokens.lg,
                                96.0, // Space for 64dp FAB
                              ),
                              itemCount: filteredItems.length,
                              separatorBuilder: (c, i) =>
                                  const SizedBox(height: SpacingTokens.md),
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return HopeBoxItemCard(
                                  item: item,
                                  onTap: () => _openItemDetail(item),
                                  onTogglePin: () => notifier.togglePin(item.id),
                                );
                              },
                            ),
                ),
              ],
            ),

            // 64dp "Add item" FAB (bottom-right, sage fill #84B09A)
            Positioned(
              bottom: SpacingTokens.xl,
              right: SpacingTokens.lg,
              child: Semantics(
                button: true,
                label: 'Add item to Hope Box',
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: FloatingActionButton(
                    heroTag: 'hope_box_add_fab',
                    elevation: 3,
                    backgroundColor: sage300,
                    foregroundColor: const Color(0xFF0A0D0F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.full),
                    ),
                    onPressed: _openAddItemSheet,
                    child: const Icon(Icons.add_rounded, size: 32),
                  ),
                ),
              ),
            ),

            // Persistent SOS Floating Panic Overlay (Bottom Left to avoid FAB)
            if (widget.showSosOverlay)
              const Positioned(
                bottom: SpacingTokens.xl,
                left: SpacingTokens.lg,
                child: SosOverlayButton(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    const warmAmber = Color(0xFFE5B870);
    const neutral100 = Color(0xFFE8ECF0);
    const neutral300 = Color(0xFF9AAAB6);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: warmAmber.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: warmAmber,
                size: 36,
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            Text(
              'This space is just for you.',
              style: AppTypography.headingSmall.copyWith(
                color: neutral100,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Add something worth holding onto — a reason to stay, a warm photo, a song, or a note from someone who cares.',
              style: AppTypography.bodyMedium.copyWith(
                color: neutral300,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.xl),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: warmAmber,
                  foregroundColor: const Color(0xFF0A0D0F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RadiusTokens.lg),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl),
                ),
                icon: const Icon(Icons.add_rounded, size: 22),
                label: Text(
                  'Add a reason to stay',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0A0D0F),
                  ),
                ),
                onPressed: _openAddItemSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredEmptyState() {
    const neutral300 = Color(0xFF9AAAB6);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.filter_list_rounded,
            color: Color(0xFF6B7E8C),
            size: 40,
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            'No items in this category yet.',
            style: AppTypography.bodyMedium.copyWith(
              color: neutral300,
            ),
          ),
        ],
      ),
    );
  }
}
