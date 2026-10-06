import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/radius_tokens.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../domain/models/hope_box_item.dart';

/// Modal bottom sheet for adding a new coping resource to the Hope Box.
class AddHopeBoxItemSheet extends StatefulWidget {
  final Future<void> Function({
    required HopeBoxItemType type,
    required String title,
    required String content,
    String? filePath,
    String? caption,
    String category,
  }) onSave;

  const AddHopeBoxItemSheet({
    super.key,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required Future<void> Function({
      required HopeBoxItemType type,
      required String title,
      required String content,
      String? filePath,
      String? caption,
      String category,
    }) onSave,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111518), // ink900
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusTokens.xl)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: AddHopeBoxItemSheet(onSave: onSave),
      ),
    );
  }

  @override
  State<AddHopeBoxItemSheet> createState() => _AddHopeBoxItemSheetState();
}

class _AddHopeBoxItemSheetState extends State<AddHopeBoxItemSheet> {
  HopeBoxItemType _selectedType = HopeBoxItemType.reason;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _filePathController = TextEditingController();
  String _selectedCategory = 'Comfort';
  bool _isSaving = false;

  final List<String> _categories = [
    'Comfort',
    'Loved Ones',
    'Nature',
    'Future',
    'Music',
    'General',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _captionController.dispose();
    _filePathController.dispose();
    super.dispose();
  }

  bool get _isValid {
    if (_selectedType == HopeBoxItemType.reason) {
      return _contentController.text.trim().isNotEmpty;
    } else if (_selectedType == HopeBoxItemType.text) {
      return _contentController.text.trim().isNotEmpty;
    } else {
      return _titleController.text.trim().isNotEmpty;
    }
  }

  Future<void> _handleSave() async {
    if (!_isValid || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final String title = _selectedType == HopeBoxItemType.reason
          ? (_titleController.text.trim().isEmpty
              ? 'Reason to Stay'
              : _titleController.text.trim())
          : _titleController.text.trim();

      await widget.onSave(
        type: _selectedType,
        title: title,
        content: _contentController.text.trim(),
        filePath: _filePathController.text.trim().isNotEmpty
            ? _filePathController.text.trim()
            : null,
        caption: _captionController.text.trim().isNotEmpty
            ? _captionController.text.trim()
            : null,
        category: _selectedCategory,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const cardBg = Color(0xFF191E23);
    const neutral100 = Color(0xFFE8ECF0);
    const neutral300 = Color(0xFF9AAAB6);
    const warmAmber = Color(0xFFE5B870);
    const sage300 = Color(0xFF84B09A);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg,
        vertical: SpacingTokens.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF2E3840),
                borderRadius: BorderRadius.circular(RadiusTokens.full),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),

          // Header
          Row(
            children: [
              Text(
                'Add to Hope Box',
                style: AppTypography.headingSmall.copyWith(
                  color: neutral100,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: neutral300),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),

          // Type Selector Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: HopeBoxItemType.values.map((type) {
                final isSelected = type == _selectedType;
                return Padding(
                  padding: const EdgeInsets.only(right: SpacingTokens.sm),
                  child: FilterChip(
                    label: Text(type.label),
                    selected: isSelected,
                    selectedColor: type == HopeBoxItemType.reason
                        ? warmAmber.withOpacity(0.25)
                        : sage300.withOpacity(0.25),
                    backgroundColor: cardBg,
                    checkmarkColor: type == HopeBoxItemType.reason ? warmAmber : sage300,
                    labelStyle: AppTypography.caption.copyWith(
                      color: isSelected
                          ? (type == HopeBoxItemType.reason ? warmAmber : sage300)
                          : neutral300,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.full),
                      side: BorderSide(
                        color: isSelected
                            ? (type == HopeBoxItemType.reason ? warmAmber : sage300)
                            : const Color(0xFF2E3840),
                      ),
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedType = type;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),

          // Form fields conditional on type
          if (_selectedType == HopeBoxItemType.reason) ...[
            Text(
              'Something worth staying for:',
              style: AppTypography.bodyMedium.copyWith(
                color: warmAmber,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            TextField(
              controller: _contentController,
              autofocus: true,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
              style: AppTypography.bodyMedium.copyWith(color: neutral100),
              decoration: InputDecoration(
                hintText: 'e.g. Watching the sunrise, my cat purring on my lap, future adventures...',
                hintStyle: AppTypography.bodyMedium.copyWith(color: const Color(0xFF6B7E8C)),
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                  borderSide: const BorderSide(color: Color(0xFF2E3840)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                  borderSide: const BorderSide(color: warmAmber),
                ),
              ),
            ),
          ] else if (_selectedType == HopeBoxItemType.text) ...[
            TextField(
              controller: _titleController,
              onChanged: (_) => setState(() {}),
              style: AppTypography.bodyMedium.copyWith(color: neutral100),
              decoration: InputDecoration(
                labelText: 'Title or Source',
                labelStyle: AppTypography.caption.copyWith(color: neutral300),
                hintText: 'e.g. Reminder from Alex, Favorite Quote',
                hintStyle: AppTypography.caption.copyWith(color: const Color(0xFF6B7E8C)),
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                  borderSide: const BorderSide(color: Color(0xFF2E3840)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                  borderSide: const BorderSide(color: sage300),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            TextField(
              controller: _contentController,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
              style: AppTypography.bodyMedium.copyWith(color: neutral100),
              decoration: InputDecoration(
                labelText: 'Note or Words',
                labelStyle: AppTypography.caption.copyWith(color: neutral300),
                hintText: 'Write something gentle or grounding to read when things are hard...',
                hintStyle: AppTypography.caption.copyWith(color: const Color(0xFF6B7E8C)),
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                  borderSide: const BorderSide(color: Color(0xFF2E3840)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                  borderSide: const BorderSide(color: sage300),
                ),
              ),
            ),
          ] else if (_selectedType == HopeBoxItemType.photo) ...[
            TextField(
              controller: _titleController,
              onChanged: (_) => setState(() {}),
              style: AppTypography.bodyMedium.copyWith(color: neutral100),
              decoration: InputDecoration(
                labelText: 'Photo Title',
                labelStyle: AppTypography.caption.copyWith(color: neutral300),
                hintText: 'e.g. Summer Walk in the Forest',
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            TextField(
              controller: _captionController,
              style: AppTypography.bodyMedium.copyWith(color: neutral100),
              decoration: InputDecoration(
                labelText: 'Optional Caption or Memory',
                labelStyle: AppTypography.caption.copyWith(color: neutral300),
                hintText: 'Why this moment helps you...',
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            TextField(
              controller: _filePathController,
              style: AppTypography.caption.copyWith(color: neutral100),
              decoration: InputDecoration(
                labelText: 'File Path or Memory Note',
                labelStyle: AppTypography.caption.copyWith(color: neutral300),
                hintText: 'e.g. /storage/photos/beach.jpg',
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                ),
              ),
            ),
          ] else ...[
            // Voice / Audio
            TextField(
              controller: _titleController,
              onChanged: (_) => setState(() {}),
              style: AppTypography.bodyMedium.copyWith(color: neutral100),
              decoration: InputDecoration(
                labelText: _selectedType == HopeBoxItemType.voice
                    ? 'Voice Note Title'
                    : 'Song / Audio Title',
                labelStyle: AppTypography.caption.copyWith(color: neutral300),
                hintText: _selectedType == HopeBoxItemType.voice
                    ? 'e.g. Message from Mom'
                    : 'e.g. Gentle Piano Waves',
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            TextField(
              controller: _filePathController,
              style: AppTypography.caption.copyWith(color: neutral100),
              decoration: InputDecoration(
                labelText: 'Local File Reference',
                labelStyle: AppTypography.caption.copyWith(color: neutral300),
                hintText: 'e.g. assets/audio/ocean_waves.mp3',
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                ),
              ),
            ),
          ],
          const SizedBox(height: SpacingTokens.md),

          // Category Chips
          Text(
            'Theme:',
            style: AppTypography.caption.copyWith(color: neutral300),
          ),
          const SizedBox(height: SpacingTokens.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: SpacingTokens.xs),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: const Color(0xFF2E3840),
                    backgroundColor: cardBg,
                    labelStyle: AppTypography.caption.copyWith(
                      color: isSelected ? neutral100 : const Color(0xFF6B7E8C),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: SpacingTokens.xl),

          // Save CTA Button (min touch target 56dp)
          SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedType == HopeBoxItemType.reason
                    ? warmAmber
                    : sage300,
                foregroundColor: const Color(0xFF0A0D0F),
                disabledBackgroundColor: const Color(0xFF2E3840),
                disabledForegroundColor: const Color(0xFF6B7E8C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.lg),
                ),
              ),
              onPressed: _isValid && !_isSaving ? _handleSave : null,
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Save to Hope Box',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _isValid ? const Color(0xFF0A0D0F) : const Color(0xFF6B7E8C),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
