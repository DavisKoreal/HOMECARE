import 'package:flutter/material.dart';
import 'package:homecare0x1/models/care_note.dart';
import 'package:homecare0x1/providers/care_note_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminNotesManagementScreen extends StatefulWidget {
  const AdminNotesManagementScreen({super.key});

  @override
  State<AdminNotesManagementScreen> createState() =>
      _AdminNotesManagementScreenState();
}

class _AdminNotesManagementScreenState extends State<AdminNotesManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildNoteCard(CareNote note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    note.isLate ? Icons.warning : Icons.note,
                    color:
                        note.isLate ? AppTheme.errorRed : AppTheme.successGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(note.timestamp),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                if (note.isLate)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Late',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Client ID: ${note.clientId}',
                style: const TextStyle(fontSize: 14)),
            Text('Caregiver ID: ${note.caregiverId}',
                style: const TextStyle(fontSize: 14)),
            Text('Shift ID: ${note.shiftId}',
                style: const TextStyle(fontSize: 14)),
            Text('Health Status: ${note.healthStatus}',
                style: const TextStyle(fontSize: 14)),
            Text('Activities: ${note.activities}',
                style: const TextStyle(fontSize: 14)),
            Text('Observations: ${note.observations}',
                style: const TextStyle(fontSize: 14)),
            Text('Medication Adherence: ${note.medicationAdherence}',
                style: const TextStyle(fontSize: 14)),
            Text('Mood: ${note.mood}', style: const TextStyle(fontSize: 14)),
            Text('Note: ${note.note}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            ModernButton(
              text: note.isVisibleToClient
                  ? 'Hide from Client'
                  : 'Show to Client',
              icon: note.isVisibleToClient
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: AppTheme.primaryBlue,
              onPressed: () {
                Provider.of<CareNoteProvider>(context, listen: false)
                    .toggleVisibility(note.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final careNoteProvider = Provider.of<CareNoteProvider>(context);
    final notes = careNoteProvider.notes;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.note,
                color: AppTheme.successGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Manage Notes',
              style: TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF00A86B),
                        Color(0xFF00C975),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.successGreen.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage Daily Notes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'View and control visibility of all care notes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'All Notes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 16),
                notes.isEmpty
                    ? const Center(child: Text('No notes available'))
                    : Column(
                        children:
                            notes.map((note) => _buildNoteCard(note)).toList()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
