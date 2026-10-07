import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../../../shared/widgets/firefly_card.dart';
import '../../domain/models/journal_entry.dart';
import '../controllers/journal_list_controller.dart';

/// Screen displaying the list of double-encrypted journal entries and unsent letters,
/// with reactive countdown chips, search filtering, and compassionate empty states.
class JournalListScreen extends ConsumerStatefulWidget {
  const JournalListScreen({super.key});

  @override
  ConsumerState<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends ConsumerState<JournalListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _ttlTicker;

  @override
  void initState() {
    super.initState();
    _ttlTicker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ttlTicker?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final listState = ref.watch(journalListControllerProvider);
    final controller = ref.read(journalListControllerProvider.notifier);

    final filteredEntries = listState.entries.where((entry) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final titleToMatch = entry.title.trim().isNotEmpty ? entry.title : 'Untitled reflection';
      return titleToMatch.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Journal & Letters',
          style: AppTypography.headingLg.copyWith(color: colors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(AppIcons.purge, color: colors.textSecondary, size: IconSizeTokens.appAction),
            tooltip: 'Purge expired letters',
            onPressed: () async {
              HapticFeedback.lightImpact();
              final count = await controller.purgeExpired();
              if (context.mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          count > 0 ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
                          color: colors.actionSage,
                          size: 20,
                        ),
                        const SizedBox(width: SpacingTokens.spaceSm),
                        Expanded(
                          child: Text(
                            count > 0
                                ? 'Purged $count expired reflection${count == 1 ? '' : 's'}'
                                : 'No expired entries to purge',
                            style: AppTypography.bodySm.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: colors.bgSurfaceElevated,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.md),
                      side: BorderSide(color: colors.borderSubtle),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header description and quick creation action buttons
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.spaceXl,
                vertical: SpacingTokens.spaceXs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Private, double-encrypted reflections. Never synced, never leaves this device.',
                    style: AppTypography.bodySm.copyWith(color: colors.textTertiary),
                  ),
                  const SizedBox(height: SpacingTokens.spaceMd),
                  // Unified cohesive entry point
                  FireflyButton(
                    text: 'New Reflection',
                    variant: FireflyButtonVariant.primary,
                    icon: AppIcons.edit,
                    onPressed: () {
                      context.push('${AppRoutes.journal}/new');
                    },
                  ),
                  const SizedBox(height: SpacingTokens.spaceMd),
                  // Search / Filter text field
                  TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                    style: AppTypography.bodyMd.copyWith(color: colors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search entries by title...',
                      hintStyle: AppTypography.bodyMd.copyWith(color: colors.textTertiary),
                      prefixIcon: Icon(AppIcons.search, color: colors.textSecondary, size: IconSizeTokens.appAction),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(AppIcons.clear, color: colors.textSecondary, size: IconSizeTokens.md),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: colors.surfaceCard,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.spaceMd,
                        vertical: SpacingTokens.spaceSm,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(RadiusTokens.input),
                        borderSide: BorderSide(color: colors.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(RadiusTokens.input),
                        borderSide: BorderSide(color: colors.borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(RadiusTokens.input),
                        borderSide: BorderSide(color: colors.actionSage),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            if (listState.errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.spaceXl,
                  vertical: SpacingTokens.spaceSm,
                ),
                padding: const EdgeInsets.all(SpacingTokens.spaceSm),
                decoration: BoxDecoration(
                  color: colors.crisisRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.crisisRed.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 18, color: colors.crisisRed),
                    const SizedBox(width: SpacingTokens.spaceSm),
                    Expanded(
                      child: Text(
                        listState.errorMessage!,
                        style: AppTypography.bodySm.copyWith(color: colors.crisisRed),
                      ),
                    ),
                  ],
                ),
              ),
            // Entries List or Empty State
            Expanded(
              child: listState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredEntries.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.separated(
                          padding: const EdgeInsets.all(SpacingTokens.spaceXl),
                          itemCount: filteredEntries.length,
                          separatorBuilder: (_, __) => const SizedBox(height: SpacingTokens.spaceMd),
                          itemBuilder: (context, index) {
                            final entry = filteredEntries[index];
                            return _buildEntryCard(context, entry, controller);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.colors;
    final isSearching = _searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space2xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                shape: BoxShape.circle,
                border: Border.all(color: colors.borderSubtle),
              ),
              child: Icon(
                isSearching ? AppIcons.search : AppIcons.vaultLock,
                size: IconSizeTokens.lg,
                color: colors.actionSage,
              ),
            ),
            const SizedBox(height: SpacingTokens.spaceLg),
            Text(
              isSearching ? 'No matching entries found' : 'A Quiet, Judgment-Free Space',
              style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.spaceXs),
            Text(
              isSearching
                  ? 'Try clearing the search query to see all journal entries.'
                  : 'A quiet space to let thoughts exist without being judged. Double-encrypted with zero-network tracking.',
              style: AppTypography.bodyMd.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(
    BuildContext context,
    JournalEntry entry,
    JournalListController controller,
  ) {
    final colors = context.colors;
    final dateStr = _formatDate(entry.createdAtUnix);
    final titleText = entry.title.trim().isNotEmpty ? entry.title : 'Untitled reflection';

    return FireflyCard(
      onTap: () {
        context.push('${AppRoutes.journal}/${entry.id}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  titleText,
                  style: AppTypography.headingMd.copyWith(
                    color: colors.textPrimary,
                    fontSize: 17,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: SpacingTokens.spaceXs),
              IconButton(
                icon: Icon(AppIcons.delete, color: colors.textTertiary, size: IconSizeTokens.appAction),
                tooltip: 'Delete reflection',
                onPressed: () => _confirmDelete(context, entry, controller),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.spaceXs),
          Row(
            children: [
              Text(
                dateStr,
                style: AppTypography.bodySm.copyWith(color: colors.textTertiary),
              ),
              Text(
                ' • ${entry.wordCount} words',
                style: AppTypography.bodySm.copyWith(color: colors.textTertiary),
              ),
              if (entry.contentType == 'voice') ...[
                const SizedBox(width: 4),
                Icon(AppIcons.audio, size: IconSizeTokens.xs, color: colors.actionSage),
              ],
              const Spacer(),
              _buildTtlChip(context, entry),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTtlChip(BuildContext context, JournalEntry entry) {
    final colors = context.colors;

    if (!entry.isAutoDeleteEnabled || entry.ttlDeleteAtUnix == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: colors.surfaceSubtle,
          borderRadius: BorderRadius.circular(RadiusTokens.chip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.shield, size: IconSizeTokens.xs, color: colors.textTertiary),
            const SizedBox(width: 4),
            Text(
              'Encrypted',
              style: AppTypography.caption.copyWith(color: colors.textTertiary),
            ),
          ],
        ),
      );
    }

    final remainingSecs = entry.remainingTtlSeconds ?? 0;
    final hours = (remainingSecs / 3600).ceil();

    final isExpired = entry.isExpired;
    final chipColor = isExpired ? colors.crisisRed : colors.accentAmber;

    final label = isExpired
        ? 'Expired'
        : hours <= 1
            ? 'Auto-deletes <1h'
            : hours < 24
                ? 'Auto-deletes in ${hours}h'
                : 'Auto-deletes in ${(hours / 24).ceil()}d';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(RadiusTokens.chip),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.burnFlame, size: IconSizeTokens.xs, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    JournalEntry entry,
    JournalListController controller,
  ) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceCard,
        title: Text(
          'Delete Reflection?',
          style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
        ),
        content: Text(
          'This entry will be cryptographically overwritten with zeroes and permanently removed.',
          style: AppTypography.bodyMd.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              HapticFeedback.mediumImpact();
              controller.deleteEntry(entry.id);
            },
            child: Text('Delete Permanently', style: TextStyle(color: colors.crisisRed)),
          ),
        ],
      ),
    );
  }

  String _formatDate(int unixSeconds) {
    final dt = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
