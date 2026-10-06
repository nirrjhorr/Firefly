import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/safety/crisis_phrase_detector.dart';
import '../../../../core/safety/local_safety_banner.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/icon_tokens.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../shared/widgets/firefly_button.dart';
import '../../../../shared/widgets/sos_overlay_button.dart';
import '../../../activities/presentation/widgets/effectiveness_feedback_dialog.dart';
import '../controllers/journal_editor_controller.dart';

/// Serene, distraction-free writing canvas in dark `#111518` with offline Vosk dictation,
/// Atkinson Hyperlegible typography, TTL presets, and instant cryptographic burn action.
class JournalEntryScreen extends ConsumerStatefulWidget {
  const JournalEntryScreen({
    required this.entryId,
    this.initialTtl,
    this.initialMode,
    this.showSosOverlay = false,
    super.key,
  });

  final String entryId;
  final JournalTtlOption? initialTtl;
  final String? initialMode;
  final bool showSosOverlay;

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScaleAnimation;

  double _canvasOpacity = 1.0;
  String _savedTitle = '';
  String _savedContent = '';
  bool _isExiting = false;

  static const CrisisPhraseDetector _phraseDetector = CrisisPhraseDetector();
  Timer? _debounceTimer;
  bool _showSafetyBanner = false;
  bool _bannerDismissedManually = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.initialTtl != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(journalEditorControllerProvider(widget.entryId).notifier)
              .setTtlOption(widget.initialTtl!);
        }
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final combined = '${_titleController.text} ${_contentController.text}';
      final result = _phraseDetector.checkText(combined);
      if (result.hasMatch != _showSafetyBanner) {
        setState(() {
          _showSafetyBanner = result.hasMatch;
          if (!result.hasMatch) {
            _bannerDismissedManually = false;
          }
        });
      }
    });
  }

  void _updatePulseAnimation(bool isListening) {
    if (isListening && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!isListening && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  bool _isDirty(JournalEditorState state) {
    if (state.isBurned) return false;
    return _titleController.text != _savedTitle ||
        _contentController.text != _savedContent;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final editorState = ref.watch(journalEditorControllerProvider(widget.entryId));
    final controller = ref.read(journalEditorControllerProvider(widget.entryId).notifier);

    // Battery-efficient pulse management: only run ticker when listening
    _updatePulseAnimation(editorState.isListening);

    // Sync external updates (e.g. initial DB load or voice dictation streaming)
    ref.listen<JournalEditorState>(
      journalEditorControllerProvider(widget.entryId),
      (previous, next) {
        // When entry finishes loading from DB:
        if ((previous?.title.isEmpty ?? true) &&
            next.title.isNotEmpty &&
            _titleController.text.isEmpty) {
          _titleController.text = next.title;
          _savedTitle = next.title;
        }
        if ((previous?.content.isEmpty ?? true) &&
            next.content.isNotEmpty &&
            _contentController.text.isEmpty) {
          _contentController.text = next.content;
          _savedContent = next.content;
        }
        // When voice dictation streams text:
        if (next.isListening && next.content != _contentController.text) {
          _contentController.value = TextEditingValue(
            text: next.content,
            selection: TextSelection.collapsed(offset: next.content.length),
          );
          _onTextChanged();
        }
      },
    );

    final dirty = _isDirty(editorState);

    return PopScope(
      canPop: _isExiting || !dirty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _isExiting) return;
        _handleBackNavigation(context, editorState, controller);
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: colors.bgCanvasDeep,
            appBar: AppBar(
              backgroundColor: colors.bgCanvasDeep,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: Icon(AppIcons.back, color: colors.textSecondary, size: IconSizeTokens.appAction),
                tooltip: 'Back to reflections',
                onPressed: () => _handleBackNavigation(context, editorState, controller),
              ),
              title: Text(
                '${editorState.wordCount} words',
                style: AppTypography.bodySm.copyWith(color: colors.textTertiary),
              ),
              centerTitle: true,
              actions: [
                if (widget.initialMode != null)
                  TextButton(
                    onPressed: () => _handleEarlyExit(context, editorState, controller),
                    child: Text(
                      "That's enough",
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: editorState.isSaving
                      ? null
                      : () async {
                          HapticFeedback.lightImpact();
                          FocusScope.of(context).unfocus();
                          final success = await controller.saveEntry();
                          if (context.mounted) {
                            if (success) {
                              setState(() {
                                _savedTitle = _titleController.text;
                                _savedContent = _contentController.text;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Saved securely'),
                                  backgroundColor: colors.surfaceCard,
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Failed to save reflection'),
                                  backgroundColor: colors.surfaceCard,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                  child: editorState.isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Save',
                          style: TextStyle(
                            color: colors.actionSage,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
            body: SafeArea(
              child: AnimatedOpacity(
                opacity: _canvasOpacity,
                duration: const Duration(milliseconds: 350),
                child: Column(
                  children: [
                    if (widget.initialMode != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.spaceXl,
                          vertical: SpacingTokens.spaceSm,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceSubtle,
                          border: Border(bottom: BorderSide(color: colors.borderSubtle)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              widget.initialMode == 'worry'
                                  ? Icons.nightlight_round
                                  : AppIcons.burnFlame,
                              size: 16,
                              color: colors.actionSage,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.initialMode == 'worry'
                                    ? 'Worry Dump: Unload thoughts onto dark paper. Park or burn when ready.'
                                    : 'Unsent Letter: Express freely in absolute privacy. Cannot be transmitted.',
                                style: AppTypography.bodySm.copyWith(color: colors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Main writing canvas
                    Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.spaceXl,
                      vertical: SpacingTokens.spaceSm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (editorState.errorMessage != null) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: SpacingTokens.spaceMd),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: colors.crisisRed.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: colors.crisisRed.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, size: 16, color: colors.crisisRed),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    editorState.errorMessage!,
                                    style: AppTypography.bodySm.copyWith(color: colors.crisisRed),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (_showSafetyBanner && !_bannerDismissedManually) ...[
                          LocalSafetyBanner(
                            onDismiss: () {
                              setState(() {
                                _bannerDismissedManually = true;
                              });
                            },
                          ),
                        ],
                        // Expandable title field
                        TextField(
                          controller: _titleController,
                          onChanged: (val) {
                            controller.setTitle(val);
                            _onTextChanged();
                          },
                          style: AppTypography.headingLg.copyWith(
                            color: colors.textPrimary,
                            fontSize: 22,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Title or recipient (optional)...',
                            hintStyle: AppTypography.headingLg.copyWith(
                              color: colors.textTertiary.withOpacity(0.5),
                              fontSize: 22,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.spaceMd),
                        // Multi-line body editor
                        TextField(
                          controller: _contentController,
                          onChanged: (val) {
                            controller.setContent(val);
                            _onTextChanged();
                          },
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: AppTypography.bodyLg.copyWith(
                            color: colors.textPrimary,
                            height: 1.65,
                            fontSize: 17,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Write freely. Your thoughts are double-encrypted with AES-256-GCM and never leave this device...',
                            hintStyle: AppTypography.bodyLg.copyWith(
                              color: colors.textTertiary.withOpacity(0.5),
                              height: 1.65,
                              fontSize: 17,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Floating bottom controls
                _buildBottomToolbar(context, editorState, controller),
              ],
            ),
          ),
        ),
      ),
      if (widget.showSosOverlay)
        const Positioned(
          bottom: 80,
          right: 16,
          child: SosOverlayButton(),
        ),
    ],
  ),
);
  }

  Widget _buildBottomToolbar(
    BuildContext context,
    JournalEditorState state,
    JournalEditorController controller,
  ) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.spaceXl,
        vertical: SpacingTokens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row of TTL options
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: JournalTtlOption.values.map((option) {
                final isSelected = state.ttlOption == option;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(option.displayName),
                    selected: isSelected,
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      controller.setTtlOption(option);
                    },
                    selectedColor: option == JournalTtlOption.none
                        ? colors.actionSage.withOpacity(0.2)
                        : colors.accentAmber.withOpacity(0.25),
                    backgroundColor: colors.surfaceSubtle,
                    labelStyle: AppTypography.bodySm.copyWith(
                      color: isSelected
                          ? (option == JournalTtlOption.none
                              ? colors.actionSage
                              : colors.accentAmber)
                          : colors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? (option == JournalTtlOption.none
                                ? colors.actionSage
                                : colors.accentAmber)
                            : colors.borderSubtle,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: SpacingTokens.spaceSm),
          // Action Buttons: Microphone dictation & Burn button
          Row(
            children: [
              // Offline Vosk Mic Dictation Toggle with Accessibility
              Semantics(
                button: true,
                label: state.isListening
                    ? 'Stop offline voice dictation'
                    : 'Start offline voice dictation',
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.toggleVoiceDictation();
                  },
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final isListening = state.isListening;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isListening
                              ? colors.actionSage.withOpacity(0.2)
                              : colors.surfaceSubtle,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isListening ? colors.actionSage : colors.borderSubtle,
                            width: isListening ? 2 : 1,
                          ),
                          boxShadow: isListening
                              ? [
                                  BoxShadow(
                                    color: colors.actionSage.withOpacity(0.4),
                                    blurRadius: 8 * _pulseScaleAnimation.value,
                                    spreadRadius: 2 * _pulseScaleAnimation.value,
                                  )
                                ]
                              : null,
                        ),
                        child: Icon(
                          isListening ? AppIcons.audio : AppIcons.audio,
                          color: isListening ? colors.actionSage : colors.textSecondary,
                          size: IconSizeTokens.appAction,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.spaceMd),
              if (state.isListening)
                Expanded(
                  child: Text(
                    'Listening offline via Vosk...',
                    style: AppTypography.bodySm.copyWith(
                      color: colors.actionSage,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else ...[
                // Unsent Letter: Burn Now button
                Expanded(
                  child: FireflyButton(
                    text: 'Burn Now',
                    variant: FireflyButtonVariant.crisis,
                    icon: AppIcons.burnFlame,
                    onPressed: () => _confirmBurn(context, controller),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _confirmBurn(
    BuildContext context,
    JournalEditorController controller,
  ) {
    final colors = context.colors;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceCard,
        title: Row(
          children: [
            Icon(AppIcons.burnFlame, color: colors.crisisRed, size: IconSizeTokens.standard),
            const SizedBox(width: 8),
            Text(
              'Burn Unsent Letter?',
              style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
            ),
          ],
        ),
        content: Text(
          'This unsent letter will be cryptographically overwritten with zeroes and permanently erased immediately. It cannot be recovered.',
          style: AppTypography.bodyMd.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Keep Writing', style: TextStyle(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _executeBurnSequence(context, controller);
            },
            child: Text('Burn Now', style: TextStyle(color: colors.crisisRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _executeBurnSequence(
    BuildContext context,
    JournalEditorController controller,
  ) async {
    final colors = context.colors;
    FocusScope.of(context).unfocus();
    // Warm double-tap tactile feedback
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    HapticFeedback.mediumImpact();

    // Subtle dissolve animation
    setState(() {
      _canvasOpacity = 0.0;
    });

    await Future.delayed(const Duration(milliseconds: 350));
    try {
      final burned = await controller.burnEntry();
      if (burned) {
        _isExiting = true;
        if (context.mounted) {
          final activityId = widget.initialMode == 'worry'
              ? 'act_worry_dump'
              : 'act_unsent_letter';
          await EffectivenessFeedbackSheet.show(
            context,
            activityId: activityId,
            stateAtStart: widget.initialMode == 'worry' ? 'racingThoughts' : 'needExpression',
            durationSeconds: 30,
          );
          if (context.mounted) {
            context.pop();
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _canvasOpacity = 1.0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to burn entry. Please try again.'),
              backgroundColor: colors.surfaceCard,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _canvasOpacity = 1.0;
        });
      }
    }
  }

  Future<void> _handleEarlyExit(
    BuildContext context,
    JournalEditorState state,
    JournalEditorController controller,
  ) async {
    final activityId = widget.initialMode == 'worry'
        ? 'act_worry_dump'
        : 'act_unsent_letter';
    await EffectivenessFeedbackSheet.show(
      context,
      activityId: activityId,
      stateAtStart: widget.initialMode == 'worry' ? 'racingThoughts' : 'needExpression',
      durationSeconds: 30,
    );
    if (context.mounted) {
      _isExiting = true;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.checkIn);
      }
    }
  }

  void _handleBackNavigation(
    BuildContext context,
    JournalEditorState state,
    JournalEditorController controller,
  ) {
    if (_isDirty(state)) {
      final colors = context.colors;
      FocusScope.of(context).unfocus();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: colors.surfaceCard,
          title: Text(
            'Save Changes?',
            style: AppTypography.headingMd.copyWith(color: colors.textPrimary),
          ),
          content: Text(
            'Would you like to save your reflection before leaving?',
            style: AppTypography.bodyMd.copyWith(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _isExiting = true;
                Navigator.of(ctx).pop();
                if (context.mounted) {
                  context.pop();
                }
              },
              child: Text('Discard', style: TextStyle(color: colors.crisisRed)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                final success = await controller.saveEntry();
                if (context.mounted && success) {
                  _isExiting = true;
                  context.pop();
                }
              },
              child: Text('Save & Exit',
                  style: TextStyle(
                      color: colors.actionSage, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      _isExiting = true;
      context.pop();
    }
  }
}
