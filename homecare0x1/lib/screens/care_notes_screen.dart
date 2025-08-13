import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/care_note.dart';
import 'package:homecare0x1/providers/care_note_provider.dart';
import 'package:homecare0x1/providers/medication_record_provider.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CareNotesScreen extends StatefulWidget {
  const CareNotesScreen({super.key});

  @override
  State<CareNotesScreen> createState() => _CareNotesScreenState();
}

class _CareNotesScreenState extends State<CareNotesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final _formKey = GlobalKey<FormState>();
  String? _selectedShiftId;
  final _healthStatusController = TextEditingController();
  final _activitiesController = TextEditingController();
  final _observationsController = TextEditingController();
  final _medicationAdherenceController = TextEditingController();
  final _moodController = TextEditingController();
  final _noteController = TextEditingController();

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
    _healthStatusController.dispose();
    _activitiesController.dispose();
    _observationsController.dispose();
    _medicationAdherenceController.dispose();
    _moodController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitNote(BuildContext context) async {
    if (_formKey.currentState!.validate() && _selectedShiftId != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final shiftProvider =
          Provider.of<ShiftAssignmentProvider>(context, listen: false);
      final shift =
          shiftProvider.shifts.firstWhere((s) => s.id == _selectedShiftId);
      await Provider.of<CareNoteProvider>(context, listen: false).addNote(
        context: context,
        clientId: shift.clientId,
        caregiverId: userProvider.user!.id,
        shiftId: _selectedShiftId!,
        healthStatus: _healthStatusController.text,
        activities: _activitiesController.text,
        observations: _observationsController.text,
        medicationAdherence: _medicationAdherenceController.text,
        mood: _moodController.text,
        note: _noteController.text,
      );
      _formKey.currentState!.reset();
      _selectedShiftId = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Note added successfully'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
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
            Text('Shift ID: ${note.shiftId}',
                style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final shiftProvider = Provider.of<ShiftAssignmentProvider>(context);
    final careNoteProvider = Provider.of<CareNoteProvider>(context);
    final medicationProvider = Provider.of<MedicationRecordProvider>(context);
    final caregiverShifts = shiftProvider.shifts
        .where((shift) => shift.caregiverId == userProvider.user!.id)
        .toList();
    final notes = careNoteProvider.getNotesForCaregiver(userProvider.user!.id);

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
              'Daily Notes',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Notes for ${userProvider.user!.name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add or view notes for your assigned shifts',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Add New Note',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedShiftId,
                        decoration: const InputDecoration(
                          labelText: 'Select Shift',
                          border: OutlineInputBorder(),
                        ),
                        items: caregiverShifts.map((shift) {
                          return DropdownMenuItem<String>(
                            value: shift.id,
                            child: Text(
                              '${shift.clientName} - ${DateFormat('MMM dd, yyyy • hh:mm a').format(shift.startTime)}',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedShiftId = value),
                        validator: (value) =>
                            value == null ? 'Please select a shift' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _healthStatusController,
                        decoration: const InputDecoration(
                          labelText: 'Health Status',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter health status'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _activitiesController,
                        decoration: const InputDecoration(
                          labelText: 'Activities',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter activities' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _observationsController,
                        decoration: const InputDecoration(
                          labelText: 'Observations',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter observations' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Medication Adherence',
                          border: OutlineInputBorder(),
                        ),
                        items: medicationProvider.records.map((record) {
                          return DropdownMenuItem<String>(
                            value:
                                '${record.medicationName} - ${record.dosage}',
                            child: Text(
                                '${record.medicationName} - ${record.dosage}'),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            _medicationAdherenceController.text = value ?? '',
                        validator: (value) => value == null
                            ? 'Please select or enter medication adherence'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _moodController,
                        decoration: const InputDecoration(
                          labelText: 'Mood',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter mood' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          labelText: 'Additional Notes',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      ModernButton(
                        text: 'Submit Note',
                        icon: Icons.send,
                        onPressed: () => _submitNote(context),
                        color: AppTheme.primaryBlue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Past Notes',
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
