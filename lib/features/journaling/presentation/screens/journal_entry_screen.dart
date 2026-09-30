import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class JournalEntryScreen extends StatelessWidget {
  const JournalEntryScreen({required this.entryId, super.key});

  final String entryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entry'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Write freely...',
              border: InputBorder.none,
            ),
            style: TextStyle(color: context.colors.textPrimary),
          ),
        ),
      ),
    );
  }
}
