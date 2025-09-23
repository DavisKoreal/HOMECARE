// Updated file: lib/services/firebase_shift_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/models/shift.dart';
import 'package:homecare0x1/models/location.dart';
import 'package:homecare0x1/providers/location_provider.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/models/caregiver.dart';
import 'package:homecare0x1/services/firebase_caregiver_service.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';

// FirebaseShiftService class for managing shift-related operations with Firestore
class FirebaseShiftService {
  // Singleton instance to ensure only one instance of the service exists
  static final FirebaseShiftService instance = FirebaseShiftService._constructor();

  // Firestore instance for database operations
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names for Firestore
  final String _caregiversCollection = 'caregivers';
  final String _clientsCollection = 'clients';
  final String _shiftsCollection = 'shifts';

  // Private constructor for singleton pattern
  FirebaseShiftService._constructor();

  // Fetch caregivers who worked with a specific client
  Future<List<CaregiverProfile>> getCaregiversForClient(String clientId) async {
    try {
      final shifts = await getShiftsForClient(clientId);
      // Get unique caregiver IDs from shifts
      final caregiverIds = shifts
          .where((shift) => shift.caregiverId != null)
          .map((shift) => shift.caregiverId!)
          .toSet()
          .toList();
      // Fetch profiles for each caregiver
      return await FirebaseCaregiverService.instance.getCaregiversForClient(caregiverIds);
    } catch (e) {
      print('Error fetching caregivers for client: $e');
      return [];
    }
  }

  /// Fetches all clients from Firestore
  /// Returns a list of Client objects
  Future<List<Client>> getAllClients() async {
    try {
      // Query the clients collection
      final snapshot = await _firestore.collection(_clientsCollection).get();
      // Map documents to Client objects
      return snapshot.docs.map((doc) => Client(
            id: doc.id,
            name: doc['name'],
            email: doc['email'],
            address: doc['address'],
            carePlan: doc['carePlan'],
          )).toList();
    } catch (e) {
      // Log error and return empty list on failure
      print('Error fetching clients: $e');
      return [];
    }
  }

  /// Fetches all shifts from Firestore, limited to 500 records
  /// Returns a list of Shift objects
  Future<List<Shift>> getAllShifts() async {
    try {
      // Query shifts collection with a limit of 500
      final snapshot = await _firestore
          .collection(_shiftsCollection)
          .limit(500)
          .get();
          // print that this function was called
      print('Fetched ${snapshot.docs.length} shifts from Firestore as all the shifts');
      // Map documents to Shift objects
      return snapshot.docs.map((doc) => Shift(
            id: doc.id,
            clientId: doc['clientId'],
            clientName: doc['clientName'],
            startTime: (doc['startTime'] as Timestamp).toDate(),
            endTime: (doc['endTime'] as Timestamp).toDate(),
            caregiverId: doc['caregiverId'],
            caregiverName: doc['caregiverName'],
            status: doc['status'],
            location: doc['location'] != null
                ? Location(
                    latitude: doc['location']['latitude'],
                    longitude: doc['location']['longitude'])
                : null,
          )).toList();
    } catch (e) {
      // Log error and return empty list on failure
      print('Error fetching shifts: $e');
      return [];
    }
  }

  /// Fetches unassigned shifts (shifts without a caregiver)
  /// Returns a list of Shift objects where caregiverId is null
  Future<List<Shift>> getUnassignedShifts() async {
    try {
      // Fetch all shifts and filter for unassigned ones
      final shifts = await getAllShifts();
      return shifts.where((shift) => shift.caregiverId == null).toList();
    } catch (e) {
      // Log error and return empty list on failure
      print('Error fetching unassigned shifts: $e');
      return [];
    }
  }

  /// Fetches shifts with 'request' status
  /// Returns a list of Shift objects
  Future<List<Shift>> getRequestShifts() async {
    try {
      // Fetch all shifts and filter for request status
      final shifts = await getAllShifts();
      return shifts.where((shift) => shift.status == 'request').toList();
    } catch (e) {
      // Log error and return empty list on failure
      print('Error fetching request shifts: $e');
      return [];
    }
  }

  /// Fetches shifts assigned to a specific caregiver
  /// Returns a list of Shift objects for the given caregiverId
  Future<List<Shift>> getShiftsForCaregiver(String caregiverId) async {
    try {
      // Fetch all shifts and filter by caregiverId
      final shifts = await getAllShifts();
      return shifts.where((shift) => shift.caregiverId == caregiverId).toList();
    } catch (e) {
      // Log error and return empty list on failure
      print('Error fetching caregiver shifts: $e');
      return [];
    }
  }

  /// Fetches shifts for a specific client
  /// Returns a list of Shift objects for the given clientId
  Future<List<Shift>> getShiftsForClient(String clientId) async {
    try {
      // Fetch all shifts and filter by clientId
      final shifts = await getAllShifts();
      final clientShifts = shifts.where((shift) => shift.clientId == clientId).toList();
      // sort having the most recent shift first
      clientShifts.sort((a, b) => b.startTime.compareTo(a.startTime));
      return clientShifts;
    } catch (e) {
      // Log error and return empty list on failure
      print('Error fetching client shifts: $e');
      return [];
    }
  }

  /// Checks if a new shift overlaps with existing shifts for a caregiver or client
  /// Returns true if there is an overlap, false otherwise
  Future<bool> _isShiftOverlap(DateTime startTime, DateTime endTime, String? caregiverId, String clientId) async {
    // final shifts = await getAllShifts();
    // get all shifts associated with supplied caregiver ID
    final shifts = await getShiftsForCaregiver(caregiverId ?? '');
    for (var shift in shifts) {
      // Check for overlap with caregiver or client shifts
      if (!(endTime.isBefore(shift.startTime) || startTime.isAfter(shift.endTime))) {
        return true; // Overlap detected
      }
    }
    return false; // No overlap
  }

  /// Requests a new shift for a client
  /// Returns "success" on successful creation, "error" on failure
  Future<String> requestShift({
    required String clientId,
    required String clientName,
    required DateTime startTime,
    required DateTime endTime,
    required BuildContext context,
  }) async {
    try {
      // Validate start and end times
      if (startTime.isAfter(endTime)) {
        throw Exception('Start time must be before end time');
      }
      if (startTime.isBefore(DateTime.now())) {
        throw Exception('Start time must be in the future');
      }
      // Check for shift overlaps
      if (await _isShiftOverlap(startTime, endTime, null, clientId)) {
        throw Exception('Shift overlaps with existing shift for client');
      }

      // Generate unique shift ID
      final shiftId = 's${DateTime.now().millisecondsSinceEpoch}';
      final shift = Shift(
        id: shiftId,
        clientId: clientId,
        clientName: clientName,
        startTime: startTime,
        endTime: endTime,
        status: 'request',
        location: LocationProvider().getRandomLocation(),
        caregiverId: null,
        caregiverName: null,
      );

      // Save shift to Firestore
      await _firestore.collection(_shiftsCollection).doc(shiftId).set({
        'clientId': clientId,
        'clientName': clientName,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'status': 'request',
        'location': {
          'latitude': shift.location!.latitude,
          'longitude': shift.location!.longitude,
        },
        'caregiverId': null,
        'caregiverName': null,
      });
      return "success";
    } catch (e) {
      // Log error and return error status
      print('Error requesting shift: $e');
      return "error";
    }
  }

  /// Adds a new shift (admin only)
  /// Returns "success" on successful creation, "error" on failure
  Future<String> addShift({
    required String clientId,
    required String clientName,
    required DateTime startTime,
    required DateTime endTime,
    required BuildContext context,
    String? caregiverId,
    String? caregiverName,
  }) async {
    try {
      // Check if user is admin
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user?.role != 'admin') {
        throw Exception('Only admins can add shifts');
      }

      // Validate client
      final clients = await getAllClients();
      final client = clients.firstWhere(
        (c) => c.id == clientId && c.name == clientName,
        orElse: () => throw Exception('Invalid client ID or name'),
      );

      // Validate start and end times
      if (startTime.isAfter(endTime)) {
        throw Exception('Start time must be before end time');
      }
      if (startTime.isBefore(DateTime.now())) {
        throw Exception('Start time must be in the future');
      }
      // Check for shift overlaps
      if (await _isShiftOverlap(startTime, endTime, caregiverId, clientId)) {
        throw Exception('Shift overlaps with existing shift for client');
      }

      // Generate unique shift ID
      final shiftId = 's${DateTime.now().millisecondsSinceEpoch}';
      final shift = Shift(
        id: shiftId,
        clientId: clientId,
        clientName: clientName,
        startTime: startTime,
        endTime: endTime,
        caregiverId: caregiverId,
        caregiverName: caregiverName,
        status: 'pending',
        location: LocationProvider().getRandomLocation(),
      );

      // Save shift to Firestore
      await _firestore.collection(_shiftsCollection).doc(shiftId).set({
        'clientId': clientId,
        'clientName': clientName,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'caregiverId': caregiverId,
        'caregiverName': caregiverName,
        'status': 'pending',
        'location': {
          'latitude': shift.location!.latitude,
          'longitude': shift.location!.longitude,
        },
      });
      return "success";
    } catch (e) {
      // Log error and return error status
      print('Error adding shift: $e');
      return "error";
    }
  }

  /// Updates an existing shift (admin only)
  /// Returns "success" on successful update, "error" on failure
  Future<String> updateShift({
    required String shiftId,
    required DateTime startTime,
    required DateTime endTime,
    required BuildContext context,
    String? caregiverId,
    String? caregiverName,
  }) async {
    try {
      // Check if user is admin
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user?.role != 'admin') {
        throw Exception('Only admins can update shifts');
      }

      // Find the shift to update
      final shifts = await getAllShifts();
      final shift = shifts.firstWhere(
        (s) => s.id == shiftId,
        orElse: () => throw Exception('Shift not found'),
      );

      // Validate start and end times
      if (startTime.isAfter(endTime)) {
        throw Exception('Start time must be before end time');
      }
      // Check for shift overlaps
      if (await _isShiftOverlap(
          startTime, endTime, caregiverId ?? shift.caregiverId, shift.clientId)) {
        throw Exception('Shift overlaps with existing shift');
      }

      // Update shift in Firestore
      await _firestore.collection(_shiftsCollection).doc(shiftId).update({
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        if (caregiverId != null) 'caregiverId': caregiverId,
        if (caregiverName != null) 'caregiverName': caregiverName,
      });
      return "success";
    } catch (e) {
      // Log error and return error status
      print('Error updating shift: $e');
      return "error";
    }
  }

  /// Updates the status of an existing shift
  /// Returns "success" on successful update, "error" on failure
  Future<String> updateShiftStatus({
    required String shiftId,
    required String status,
    Location? location,
  }) async {
    try {
      // Find the shift to update
      final shifts = await getAllShifts();
      final shift = shifts.firstWhere(
        (s) => s.id == shiftId,
        orElse: () => throw Exception('Shift not found'),
      );

      // Validate location for in_session status
      if (status == 'in_session' && location == null) {
        throw Exception('Location is required for check-in');
      }

      // Update shift status in Firestore
      await _firestore.collection(_shiftsCollection).doc(shiftId).update({
        'status': status,
        if (location != null)
          'location': {
            'latitude': location.latitude,
            'longitude': location.longitude,
          },
      });
      return "success";
    } catch (e) {
      // Log error and return error status
      print('Error updating shift status: $e');
      return "error";
    }
  }

  /// Assigns a caregiver to a shift
  /// Returns "success" on successful assignment, "error" on failure
  Future<String> assignShift( String shiftId, String caregiverId, String caregiverName) async {
    try {
      final doc = await _firestore.collection(_shiftsCollection).doc(shiftId).get();
      if (!doc.exists) {
        throw Exception('Shift not found');
      }
      final shift = Shift(
        id: doc.id,
        clientId: doc['clientId'],
        clientName: doc['clientName'],
        startTime: (doc['startTime'] as Timestamp).toDate(),
        endTime: (doc['endTime'] as Timestamp).toDate(),
        caregiverId: doc['caregiverId'],
        caregiverName: doc['caregiverName'],
        status: doc['status'],
        location: doc['location'] != null
            ? Location(
                latitude: doc['location']['latitude'],
                longitude: doc['location']['longitude'])
            : null,
      );

      // Check for shift overlaps
      if (await _isShiftOverlap(shift.startTime, shift.endTime, caregiverId, shift.clientId)) {
        throw Exception('Caregiver is already assigned to another shift at this time');
      }

      // Update shift with caregiver details
      await _firestore.collection(_shiftsCollection).doc(shiftId).update({
        'caregiverId': caregiverId,
        'caregiverName': caregiverName,
        'status': shift.status == 'request' ? 'pending' : shift.status,
      });
      return "success";
    } catch (e) {
      // Log error and return error status
      print('Error assigning shift: $e');
      return "error";
    }
  }
}