import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/care_note.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:homecare0x1/providers/care_note_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CareNotesScreen extends StatelessWidget {
  const CareNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final careNoteProvider = Provider.of<CareNoteProvider>(context);
    final notes = careNoteProvider.notes;

    return ModernScreenLayout(
      title: 'Care Notes',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Care Notes',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'View notes about client care',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            notes.isEmpty
                ? const Center(child: Text('No notes found'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(note.note),
                          subtitle: Text(
                            'Time: ${DateFormat('MMM d, h:mm a').format(note.timestamp)}',
                          ),
                          leading: Icon(Icons.note, color: AppTheme.primaryBlue),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
