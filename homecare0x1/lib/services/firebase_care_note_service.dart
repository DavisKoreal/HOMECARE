import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homecare0x1/models/care_note.dart';
import 'package:homecare0x1/models/caregiver.dart';

// Service class for handling Firebase Firestore operations related to care notes
class FirebaseCareNotesService {
  // Firestore collection reference for care notes
  final CollectionReference _careNotesCollection =
      FirebaseFirestore.instance.collection('care_notes');

  // Constant for the maximum number of care notes to retrieve
  static const int _careNotesLimit = 500;

  /// Fetches up to 500 care notes for a specific client from Firestore
  /// [clientId] - The ID of the client whose notes are to be retrieved
  /// Returns a list of CareNote objects, limited to 500 entries
  /// Throws an exception if the fetch operation fails (e.g., missing index)
  Future<List<CareNote>> getCareNotes(String clientId) async {
    try {
      print(  'Fetching care notes for clientId: $clientId');
      print('Using care notes limit: $_careNotesLimit');
      // Query Firestore for care notes matching the clientId, visible to client,
      // ordered by timestamp, and limited to 500 entries
      QuerySnapshot querySnapshot = await _careNotesCollection
          .where('clientId', isEqualTo: clientId)
          .limit(_careNotesLimit)
          .get();

      // Map Firestore documents to CareNote objects
      List<CareNote> carenotesList = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CareNote(
          id: doc.id,
          clientId: data['clientId'] as String,
          caregiverId: data['caregiverId'] as String,
          shiftId: data['shiftId'] as String,
          healthStatus: data['healthStatus'] as String,
          activities: data['activities'] as String,
          observations: data['observations'] as String,
          medicationAdherence: data['medicationAdherence'] as String,
          mood: data['mood'] as String,
          note: data['note'] as String,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          isVisibleToClient: data['isVisibleToClient'] as bool,
          isLate: data['isLate'] as bool? ?? false,
        );
      }).toList();
      print('Fetched ${carenotesList.length} care notes from Firestore.');

      // return care notes that are visible to the client
      return carenotesList.where((note) => note.isVisibleToClient).toList();

    } catch (e) {
      // Log error for debugging purposes
      print('Error fetching care notes: $e');
      // Provide specific error message for missing index
      if (e.toString().contains('requires an index')) {
        throw Exception(
            'Unable to load care notes due to a missing Firestore index. Please contact support or try again later.');
      }
      throw Exception('Failed to fetch care notes: $e');
    }
  }

  /// Adds a new care note to Firestore
  /// [note] - The CareNote object to be added
  /// Throws an exception if the add operation fails
  Future<void> addCareNote(CareNote note) async {
    try {
      // Add care note data to Firestore collection
      await _careNotesCollection.add({
        'clientId': note.clientId,
        'caregiverId': note.caregiverId,
        'shiftId': note.shiftId,
        'healthStatus': note.healthStatus,
        'activities': note.activities,
        'observations': note.observations,
        'medicationAdherence': note.medicationAdherence,
        'mood': note.mood,
        'note': note.note,
        'timestamp': Timestamp.fromDate(note.timestamp),
        'isVisibleToClient': note.isVisibleToClient,
        'isLate': note.isLate,
      });
    } catch (e) {
      // Log error for debugging purposes
      print('Error adding care note: $e');
      throw Exception('Failed to add care note: $e');
    }
  }
}