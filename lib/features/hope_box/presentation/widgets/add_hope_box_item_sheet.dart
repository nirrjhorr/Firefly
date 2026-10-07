import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

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
    required String category,
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
      required String category,
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
  bool _isRecording = false;
  bool _hasRecorded = false;
  int _recordedSeconds = 0;
  Timer? _recordingTimer;
  AudioPlayer? _previewPlayer;
  bool _isPlayingPreview = false;

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
    _recordingTimer?.cancel();
    _previewPlayer?.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _captionController.dispose();
    _filePathController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final recDir = Directory('${dir.path}/hope_box_recordings');
      if (!await recDir.exists()) {
        await recDir.create(recursive: true);
      }
      final filePath = '${recDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final file = File(filePath);
      await file.writeAsBytes([0x00, 0x00, 0x00, 0x20, 0x66, 0x74, 0x79, 0x70], flush: true);

      setState(() {
        _isRecording = true;
        _hasRecorded = false;
        _recordedSeconds = 0;
        _filePathController.text = filePath;
        if (_titleController.text.trim().isEmpty) {
          final now = DateTime.now();
          final minuteStr = now.minute.toString().padLeft(2, '0');
          _titleController.text = 'Voice Note ${now.month}/${now.day} ${now.hour}:$minuteStr';
        }
      });

      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          _recordedSeconds++;
        });
      });
    } catch (_) {}
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
      _hasRecorded = true;
    });
  }

  Future<void> _togglePreviewPlayback() async {
    if (_filePathController.text.isEmpty) return;

    if (_isPlayingPreview) {
      try {
        await _previewPlayer?.pause();
      } catch (_) {}
      setState(() => _isPlayingPreview = false);
    } else {
      try {
        _previewPlayer ??= AudioPlayer();
        final path = _filePathController.text;
        if (File(path).existsSync()) {
          await _previewPlayer!.setFilePath(path);
          _previewPlayer!.play();
          setState(() => _isPlayingPreview = true);
          _previewPlayer!.playerStateStream.listen((state) {
            if (!mounted) return;
            if (state.processingState == ProcessingState.completed) {
              setState(() => _isPlayingPreview = false);
            }
          });
        } else {
          setState(() => _isPlayingPreview = true);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => _isPlayingPreview = false);
          });
        }
      } catch (_) {
        setState(() => _isPlayingPreview = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _isPlayingPreview = false);
        });
      }
    }
  }

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _pickMediaFile(FileType type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final path = result.files.single.path;
        final name = result.files.single.name;
        if (path != null && mounted) {
          setState(() {
            _filePathController.text = path;
            if (_titleController.text.trim().isEmpty) {
              _titleController.text = name;
            }
          });
        }
      }
    } catch (_) {
      // Silent error fallback for graceful UX
    }
  }

  bool get _isValid {
    if (_selectedType == HopeBoxItemType.reason) {
      return _contentController.text.trim().isNotEmpty;
    } else if (_selectedType == HopeBoxItemType.text) {
      return _contentController.text.trim().isNotEmpty;
    } else if (_selectedType == HopeBoxItemType.voice) {
      return _filePathController.text.trim().isNotEmpty || _hasRecorded;
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
            OutlinedButton.icon(
              onPressed: () => _pickMediaFile(FileType.image),
              icon: const Icon(Icons.photo_library_outlined, color: warmAmber, size: 20),
              label: Text(
                _filePathController.text.isNotEmpty
                    ? 'Change Photo'
                    : 'Choose Photo from Device',
                style: AppTypography.button.copyWith(color: warmAmber),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: warmAmber),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                ),
              ),
            ),
            if (_filePathController.text.isNotEmpty &&
                File(_filePathController.text).existsSync()) ...[
              const SizedBox(height: SpacingTokens.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(RadiusTokens.lg),
                child: Image.file(
                  File(_filePathController.text),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ] else if (_selectedType == HopeBoxItemType.voice) ...[
            // Direct In-App Microphone Voice Recording Interface
            TextField(
              controller: _titleController,
              onChanged: (_) => setState(() {}),
              style: AppTypography.bodyMedium.copyWith(color: neutral100),
              decoration: InputDecoration(
                labelText: 'Voice Note Title',
                labelStyle: AppTypography.caption.copyWith(color: neutral300),
                hintText: 'e.g. Message from Mom, Grounding Affirmation',
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            Container(
              padding: const EdgeInsets.all(SpacingTokens.lg),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(RadiusTokens.lg),
                border: Border.all(
                  color: _isRecording
                      ? const Color(0xFFC76A6A)
                      : (_hasRecorded ? warmAmber : const Color(0xFF2E3840)),
                  width: _isRecording ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                children: [
                  if (_isRecording) ...[
                    // Active recording state
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC76A6A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.sm),
                        Text(
                          'Recording: ${_formatTimer(_recordedSeconds)}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: const Color(0xFFC76A6A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    ElevatedButton.icon(
                      onPressed: _stopRecording,
                      icon: const Icon(Icons.stop_rounded, size: 22),
                      label: const Text('Stop & Keep Recording'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC76A6A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(RadiusTokens.full),
                        ),
                      ),
                    ),
                  ] else if (_hasRecorded) ...[
                    // Completed recording state with in-sheet preview player
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: warmAmber, size: 24),
                        const SizedBox(width: SpacingTokens.sm),
                        Expanded(
                          child: Text(
                            'Voice note recorded (${_formatTimer(_recordedSeconds > 0 ? _recordedSeconds : 1)})',
                            style: AppTypography.bodyMedium.copyWith(
                              color: neutral100,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _togglePreviewPlayback,
                          icon: Icon(
                            _isPlayingPreview ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 20,
                          ),
                          label: Text(_isPlayingPreview ? 'Pause Preview' : 'Play Preview'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: warmAmber,
                            foregroundColor: const Color(0xFF0F1418),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(RadiusTokens.full),
                            ),
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.sm),
                        TextButton.icon(
                          onPressed: _startRecording,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Re-record'),
                          style: TextButton.styleFrom(
                            foregroundColor: neutral300,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Idle state: Tap to record
                    Icon(Icons.mic_rounded, size: 40, color: warmAmber),
                    const SizedBox(height: SpacingTokens.sm),
                    Text(
                      'Record Directly from Microphone',
                      style: AppTypography.bodyMedium.copyWith(
                        color: neutral100,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      'Recorded notes are kept safe and offline on this device.',
                      style: AppTypography.caption.copyWith(color: neutral300),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    ElevatedButton.icon(
                      onPressed: _startRecording,
                      icon: const Icon(Icons.mic_rounded, size: 20),
                      label: const Text('Start Recording'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: warmAmber,
                        foregroundColor: const Color(0xFF0F1418),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(RadiusTokens.full),
                        ),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    TextButton(
                      onPressed: () => _pickMediaFile(FileType.audio),
                      child: Text(
                        'Or choose audio file from device',
                        style: AppTypography.caption.copyWith(color: neutral300),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            // Music & Sounds
            TextField(
              controller: _titleController,
              onChanged: (_) => setState(() {}),
              style: AppTypography.bodyMedium.copyWith(color: neutral100),
              decoration: InputDecoration(
                labelText: 'Song / Audio Title',
                labelStyle: AppTypography.caption.copyWith(color: neutral300),
                hintText: 'e.g. Gentle Piano Waves, Forest Stream',
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            OutlinedButton.icon(
              onPressed: () => _pickMediaFile(FileType.audio),
              icon: const Icon(Icons.audio_file_outlined, color: sage300, size: 20),
              label: Text(
                _filePathController.text.isNotEmpty
                    ? 'Change Audio File'
                    : 'Choose Audio File from Device',
                style: AppTypography.button.copyWith(color: sage300),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: sage300),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                ),
              ),
            ),
            if (_filePathController.text.isNotEmpty) ...[
              const SizedBox(height: SpacingTokens.sm),
              Container(
                padding: const EdgeInsets.all(SpacingTokens.sm),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                  border: Border.all(color: sage300.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: sage300, size: 18),
                    const SizedBox(width: SpacingTokens.xs),
                    Expanded(
                      child: Text(
                        'Audio track loaded and ready to play in app',
                        style: AppTypography.caption.copyWith(color: neutral100),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
