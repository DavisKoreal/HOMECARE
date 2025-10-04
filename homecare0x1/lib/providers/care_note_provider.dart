import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/care_note.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CareNoteProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<CareNote> _notes = [];

  List<CareNote> get notes => _notes;

  Future<void> fetchNotes() async {
    try {
      final snapshot = await _firestore.collection('care_notes').get();
      _notes.clear();
      _notes.addAll(snapshot.docs.map((doc) => CareNote(
        id: doc.id,
        clientId: doc['clientId'],
        caregiverId: doc['caregiverId'],
        shiftId: doc['shiftId'],
        healthStatus: doc['healthStatus'],
        activities: doc['activities'],
        observations: doc['observations'],
        medicationAdherence: doc['medicationAdherence'],
        mood: doc['mood'],
        note: doc['note'],
        timestamp: (doc['timestamp'] as Timestamp).toDate(),
        isVisibleToClient: doc['isVisibleToClient'],
        isLate: doc['isLate'],
        foodAndDrinks: doc['foodAndDrinks'] ?? '',
        mealQuantityPercentage: doc['mealQuantityPercentage'] ?? 0,
        hydrationMl: doc['hydrationMl'] ?? 0,
        hasBowelMovement: doc['hasBowelMovement'] ?? false,
        mobilityAndShower: doc['mobilityAndShower'] ?? '',
      )).toList());
      notifyListeners();
    } catch (e) {
      print('Error fetching notes: $e');
    }
  }

  List<CareNote> getNotesForClient(String clientId, {bool onlyVisible = false}) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
      id: const Uuid().v4(),
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
      foodAndDrinks: '', // Provide appropriate value or parameter
      mealQuantityPercentage: 0, // Provide appropriate value or parameter
      hydrationMl: 0, // Provide appropriate value or parameter
      hasBowelMovement: false, // Provide appropriate value or parameter
      mobilityAndShower: '', // Provide appropriate value or parameter
    );

    try {
      await _firestore.collection('care_notes').doc(newNote.id).set({
        'clientId': clientId,
        'caregiverId': caregiverId,
        'shiftId': shiftId,
        'healthStatus': healthStatus,
        'activities': activities,
        'observations': observations,
        'medicationAdherence': medicationAdherence,
        'mood': mood,
        'note': note,
        'timestamp': Timestamp.fromDate(now),
        'isVisibleToClient': false,
        'isLate': isLate,
      });
      _notes.insert(0, newNote);
      notifyListeners();
    } catch (e) {
      print('Error adding note: $e');
    }
  }

  Future<void> toggleVisibility(String noteId) async {
    final index = _notes.indexWhere((note) => note.id == noteId);
    if (index != -1) {
      final newVisibility = !_notes[index].isVisibleToClient;
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
        isVisibleToClient: newVisibility,
        isLate: _notes[index].isLate,
        foodAndDrinks: _notes[index].foodAndDrinks,
        mealQuantityPercentage: _notes[index].mealQuantityPercentage,
        hydrationMl: _notes[index].hydrationMl,
        hasBowelMovement: _notes[index].hasBowelMovement,
        mobilityAndShower: _notes[index].mobilityAndShower,
      );
      try {
        await _firestore.collection('care_notes').doc(noteId).update({
          'isVisibleToClient': newVisibility,
        });
        notifyListeners();
      } catch (e) {
        print('Error toggling visibility: $e');
      }
    }
  }
}
