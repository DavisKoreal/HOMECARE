import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homecare0x1/models/care_note.dart';

// Service class for handling Firebase Firestore operations related to care notes
class FirebaseCareNotesService {
  // Firestore collection references
  final CollectionReference _careNotesCollection =
      FirebaseFirestore.instance.collection('care_notes');
  final CollectionReference _clientsCollection =
      FirebaseFirestore.instance.collection('clients');

  // Constant for the maximum number of care notes to retrieve
  static const int _careNotesLimit = 500;

  /// Fetches up to 500 care notes for a specific client from Firestore
  /// [clientId] - The ID of the client whose notes are to be retrieved
  /// Returns a list of CareNote objects, limited to 500 entries
  /// Throws an exception if the fetch operation fails (e.g., missing index)
  Future<List<CareNote>> getCareNotes(String clientId) async {
    try {
      print('Fetching care notes for clientId: $clientId');
      print('Using care notes limit: $_careNotesLimit');
      QuerySnapshot querySnapshot = await _careNotesCollection
          .where('clientId', isEqualTo: clientId)
          .limit(_careNotesLimit)
          .orderBy('timestamp', descending: true)
          .get();

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
          foodAndDrinks: data['foodAndDrinks'] as String,
          mealQuantityPercentage: data['mealQuantityPercentage'] as int,
          hydrationMl: data['hydrationMl'] as int,
          hasBowelMovement: data['hasBowelMovement'] as bool,
          bowelMovementDescription: data['bowelMovementDescription'] as String?,
          bowelMovementFrequency: data['bowelMovementFrequency'] as int? ?? 0,
          mobilityAndShower: data['mobilityAndShower'] as String,
        );
      }).toList();
      print('Fetched ${carenotesList.length} care notes from Firestore.');
      return carenotesList.where((note) => note.isVisibleToClient).toList();
    } catch (e) {
      print('Error fetching care notes: $e');
      if (e.toString().contains('requires an index')) {
        throw Exception(
            'Unable to load care notes due to a missing Firestore index. Please contact support or try again later.');
      }
      throw Exception('Failed to fetch care notes: $e');
    }
  }

  /// Fetches all care notes from Firestore (for admin use)
  /// Returns a list of all CareNote objects, limited to 500 entries
  /// Throws an exception if the fetch operation fails
  Future<List<CareNote>> getAllCareNotes() async {
    try {
      print('Fetching all care notes');
      print('Using care notes limit: $_careNotesLimit');
      QuerySnapshot querySnapshot = await _careNotesCollection
          .orderBy('timestamp', descending: true)
          .limit(_careNotesLimit)
          .get();

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
          foodAndDrinks: data['foodAndDrinks'] as String,
          mealQuantityPercentage: data['mealQuantityPercentage'] as int,
          hydrationMl: data['hydrationMl'] as int,
          hasBowelMovement: data['hasBowelMovement'] as bool,
          bowelMovementDescription: data['bowelMovementDescription'] as String?,
          bowelMovementFrequency: data['bowelMovementFrequency'] as int? ?? 0,
          mobilityAndShower: data['mobilityAndShower'] as String,
        );
      }).toList();
      print('Fetched ${carenotesList.length} care notes from Firestore.');
      return carenotesList;
    } catch (e) {
      print('Error fetching all care notes: $e');
      if (e.toString().contains('requires an index')) {
        throw Exception(
            'Unable to load care notes due to a missing Firestore index. Please contact support or try again later.');
      }
      throw Exception('Failed to fetch all care notes: $e');
    }
  }

  /// Fetches filtered care notes from Firestore
  /// [clientId] - Optional filter by client ID
  /// [caregiverId] - Optional filter by caregiver ID
  /// [date] - Optional filter by date (notes from that day)
  /// Returns a list of CareNote objects matching the filters
  Future<List<CareNote>> getFilteredCareNotes({
    String? clientId,
    String? caregiverId,
    DateTime? date,
  }) async {
    try {
      print('Fetching filtered care notes: clientId=$clientId, caregiverId=$caregiverId, date=$date');
      Query query = _careNotesCollection
          .orderBy('timestamp', descending: true)
          .limit(_careNotesLimit);

      if (clientId != null && clientId.isNotEmpty) {
        query = query.where('clientId', isEqualTo: clientId);
      }
      if (caregiverId != null && caregiverId.isNotEmpty) {
        query = query.where('caregiverId', isEqualTo: caregiverId);
      }
      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        query = query
            .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay));
      }

      QuerySnapshot querySnapshot = await query.get();

      List<CareNote> careNotesList = querySnapshot.docs.map((doc) {
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
          foodAndDrinks: data['foodAndDrinks'] as String,
          mealQuantityPercentage: data['mealQuantityPercentage'] as int,
          hydrationMl: data['hydrationMl'] as int,
          hasBowelMovement: data['hasBowelMovement'] as bool,
          bowelMovementDescription: data['bowelMovementDescription'] as String?,
          bowelMovementFrequency: data['bowelMovementFrequency'] as int? ?? 0,
          mobilityAndShower: data['mobilityAndShower'] as String,
        );
      }).toList();
      print('Fetched ${careNotesList.length} filtered care notes from Firestore.');
      return careNotesList;
    } catch (e) {
      print('Error fetching filtered care notes: $e');
      if (e.toString().contains('requires an index')) {
        throw Exception(
            'Unable to load care notes due to a missing Firestore index. Please contact support or try again later.');
      }
      throw Exception('Failed to fetch filtered care notes: $e');
    }
  }

  /// Fetches client names mapped to client IDs
  /// Returns a map of clientId to client name, skipping invalid documents
  Future<Map<String, String>> getClientNames() async {
    try {
      QuerySnapshot querySnapshot = await _clientsCollection.get();
      Map<String, String> clientNames = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        // Safely check for clientId and name, skip if either is null or not a string
        final clientId = data['clientId'];
        final name = data['name'];
        if (clientId is String && name is String && clientId.isNotEmpty && name.isNotEmpty) {
          clientNames[clientId] = name;
        } else {
          print('Skipping invalid client document: ${doc.id} (clientId: $clientId, name: $name)');
        }
      }
      print('Fetched ${clientNames.length} valid client names from Firestore.');
      return clientNames;
    } catch (e) {
      print('Error fetching client names: $e');
      throw Exception('Failed to fetch client names: $e');
    }
  }

  /// Adds a new care note to Firestore
  Future<void> addCareNote(CareNote note) async {
    try {
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
        'foodAndDrinks': note.foodAndDrinks,
        'mealQuantityPercentage': note.mealQuantityPercentage,
        'hydrationMl': note.hydrationMl,
        'hasBowelMovement': note.hasBowelMovement,
        'bowelMovementDescription': note.bowelMovementDescription,
        'bowelMovementFrequency': note.bowelMovementFrequency,
        'mobilityAndShower': note.mobilityAndShower,
      });
    } catch (e) {
      print('Error adding care note: $e');
      throw Exception('Failed to add care note: $e');
    }
  }

  /// Toggles the visibility of a care note in Firestore
  Future<void> toggleNoteVisibility(String noteId, bool isVisible) async {
    try {
      await _careNotesCollection.doc(noteId).update({
        'isVisibleToClient': isVisible,
      });
      print('Toggled visibility for note $noteId to $isVisible');
    } catch (e) {
      print('Error toggling note visibility: $e');
      throw Exception('Failed to toggle note visibility: $e');
    }
  }
}