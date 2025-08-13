import 'package:flutter/material.dart';
import 'package:homecare0x1/models/care_note.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

class CareNoteProvider with ChangeNotifier {
  final List<CareNote> _notes = [
    CareNote(
      id: const Uuid().v4(),
      clientId: 'f1',
      caregiverId: 'cg1',
      shiftId: 's1',
      healthStatus: 'Stable, no new issues',
      activities: 'Assisted with morning walk and meal prep',
      observations: 'Client was cooperative',
      medicationAdherence: 'Aspirin 100mg taken as prescribed',
      mood: 'Cheerful',
      note: 'Daily check completed',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isVisibleToClient: true,
      isLate: false,
    ),
    CareNote(
      id: const Uuid().v4(),
      clientId: 'f1',
      caregiverId: 'cg1',
      shiftId: 's2',
      healthStatus: 'Slight fatigue reported',
      activities: 'Helped with bathing and exercises',
      observations: 'Client needed extra rest',
      medicationAdherence: 'Lisinopril 10mg taken',
      mood: 'Calm',
      note: 'Evening check',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isVisibleToClient: false,
      isLate: true,
    ),
  ];

  List<CareNote> get notes => _notes;

  List<CareNote> getNotesForClient(String clientId,
      {bool onlyVisible = false}) {
    return _notes
        .where((note) =>
            note.clientId == clientId &&
            (!onlyVisible || note.isVisibleToClient))
        .toList();
  }

  List<CareNote> getNotesForCaregiver(String caregiverId) {
    return _notes.where((note) => note.caregiverId == caregiverId).toList();
  }

  Future<void> addNote({
    required BuildContext context,
    required String clientId,
    required String caregiverId,
    required String shiftId,
    required String healthStatus,
    required String activities,
    required String observations,
    required String medicationAdherence,
    required String mood,
    required String note,
  }) async {
    final shiftProvider = Provider.of<ShiftAssignmentProvider>(context, listen: false);
    final shift = shiftProvider.shifts.firstWhere(
      (shift) => shift.id == shiftId,
      orElse: () => throw Exception('Shift not found'),
    );
    final now = DateTime.now();
    final isLate = now.isAfter(shift.endTime.add(const Duration(hours: 12)));

    if (isLate) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Late Submission'),
          content: const Text(
              'This note is being submitted more than 12 hours after the shift ended.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    final newNote = CareNote(
      clientId: clientId,
      caregiverId: caregiverId,
      shiftId: shiftId,
      healthStatus: healthStatus,
      activities: activities,
      observations: observations,
      medicationAdherence: medicationAdherence,
      mood: mood,
      note: note,
      timestamp: now,
      isLate: isLate,
    );
    _notes.insert(0, newNote);
    notifyListeners();
  }

  void toggleVisibility(String noteId) {
    final index = _notes.indexWhere((note) => note.id == noteId);
    if (index != -1) {
      _notes[index] = CareNote(
        id: _notes[index].id,
        clientId: _notes[index].clientId,
        caregiverId: _notes[index].caregiverId,
        shiftId: _notes[index].shiftId,
        healthStatus: _notes[index].healthStatus,
        activities: _notes[index].activities,
        observations: _notes[index].observations,
        medicationAdherence: _notes[index].medicationAdherence,
        mood: _notes[index].mood,
        note: _notes[index].note,
        timestamp: _notes[index].timestamp,
        isVisibleToClient: !_notes[index].isVisibleToClient,
        isLate: _notes[index].isLate,
      );
      notifyListeners();
    }
  }
}
