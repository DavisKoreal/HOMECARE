import 'package:flutter/material.dart';
import 'package:homecare0x1/models/care_note.dart';

class CareNoteProvider with ChangeNotifier {
  List<CareNote> _notes = [
    CareNote(
      id: '1',
      clientId: '1',
      caregiverId: 'caregiver1',
      note: 'Client was in good spirits, assisted with mobility.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    CareNote(
      id: '2',
      clientId: '1',
      caregiverId: 'caregiver1',
      note: 'Noticed slight fatigue, recommended rest.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<CareNote> get notes => _notes;

  void addNote(CareNote note) {
    _notes.insert(0, note);
    notifyListeners();
  }
}
