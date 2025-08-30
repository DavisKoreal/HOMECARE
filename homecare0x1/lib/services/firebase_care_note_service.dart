import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homecare0x1/models/care_note.dart';

// Firebase Care Note Service
// Handles CRUD operations for CareNotes in Firestore.
// Stores data in a 'care_notes' collection with each document using the CareNote's ID.
class FirebaseCareNoteService {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference to the care_notes collection
  CollectionReference get _careNotesCollection => _firestore.collection('care_notes');

  // Adds a new CareNote to Firestore
  Future<void> addCareNote(CareNote careNote) async {
    try {
      await _careNotesCollection.doc(careNote.id).set(_careNoteToMap(careNote));
    } catch (e) {
      throw Exception('Failed to add care note: $e');
    }
  }

  // Retrieves all CareNotes for a specific client, ordered by timestamp
  Future<List<CareNote>> getCareNotesForClient(String clientId) async {
    try {
      final querySnapshot = await _careNotesCollection
          .where('clientId', isEqualTo: clientId)
          .orderBy('timestamp', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => _careNoteFromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch care notes: $e');
    }
  }

  // Retrieves a single CareNote by ID
  Future<CareNote?> getCareNoteById(String id) async {
    try {
      final docSnapshot = await _careNotesCollection.doc(id).get();
      if (docSnapshot.exists) {
        return _careNoteFromMap(docSnapshot.data() as Map<String, dynamic>, id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch care note: $e');
    }
  }

  // Converts a CareNote object to a Firestore-compatible map
  Map<String, dynamic> _careNoteToMap(CareNote careNote) {
    return {
      'id': careNote.id,
      'clientId': careNote.clientId,
      'caregiverId': careNote.caregiverId,
      'shiftId': careNote.shiftId,
      'healthStatus': careNote.healthStatus,
      'activities': careNote.activities,
      'observations': careNote.observations,
      'medicationAdherence': careNote.medicationAdherence,
      'mood': careNote.mood,
      'note': careNote.note,
      'timestamp': Timestamp.fromDate(careNote.timestamp),
      'isVisibleToClient': careNote.isVisibleToClient,
      'isLate': careNote.isLate,
    };
  }

  // Converts a Firestore document map to a CareNote object
  CareNote _careNoteFromMap(Map<String, dynamic> map, String id) {
    return CareNote(
      id: map['id'] ?? id,
      clientId: map['clientId'],
      caregiverId: map['caregiverId'],
      shiftId: map['shiftId'],
      healthStatus: map['healthStatus'],
      activities: map['activities'],
      observations: map['observations'],
      medicationAdherence: map['medicationAdherence'],
      mood: map['mood'],
      note: map['note'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isVisibleToClient: map['isVisibleToClient'] ?? false,
      isLate: map['isLate'] ?? false,
    );
  }
}