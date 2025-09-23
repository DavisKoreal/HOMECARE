// Import necessary packages for Firebase Firestore, Flutter, and provider state management
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/providers/location_provider.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/models/shift.dart';
import 'package:homecare0x1/models/location.dart';

// Caregiver class to represent caregiver data
class Caregiver {
  final String id; // Unique identifier for the caregiver
  final String name; // Name of the caregiver
  final bool isAvailable; // Availability status of the caregiver

  Caregiver({
    required this.id,
    required this.name,
    required this.isAvailable,
  });
}

// ShiftAssignmentProvider manages shift-related operations and state
class ShiftAssignmentProvider with ChangeNotifier {
  // Firestore instance for database operations
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Lists to store caregivers, clients, and shifts
  final List<Caregiver> _caregivers = [];
  final List<Client> _clients = [];
  final List<Shift> _shifts = [];

  // Getter for available caregivers (filtered by isAvailable)
  List<Caregiver> get availableCaregivers =>
      _caregivers.where((cg) => cg.isAvailable).toList();

  // Getter for all clients
  List<Client> get clients => _clients;

  // Getter for unassigned shifts (shifts without a caregiver)
  List<Shift> get unassignedShifts =>
      _shifts.where((shift) => shift.caregiverId == null).toList();

  // Getter for shifts with 'request' status
  List<Shift> get requestShifts =>
      _shifts.where((shift) => shift.status == 'request').toList();

  // Getter for all shifts
  List<Shift> get allShifts => _shifts;

  // Getter for shifts (alias for allShifts)
  List<Shift> get shifts => _shifts;

  // Fetches caregivers from Firestore and updates the local list
  Future<String> fetchCaregivers() async {
    try {
      // Query the 'caregivers' collection
      final snapshot = await _firestore.collection('caregivers').get();
      // Clear existing caregivers to avoid duplicates
      _caregivers.clear();
      // Map Firestore documents to Caregiver objects
      _caregivers.addAll(snapshot.docs.map((doc) => Caregiver(
            id: doc.id,
            name: doc['name'],
            isAvailable: doc['isAvailable'],
          )).toList());
      // Notify listeners of state change
      notifyListeners();
      // Log success and number of caregivers fetched
      print('Caregivers fetched: ${_caregivers.length}');
      return "success";
    } catch (e) {
      // Log error and return failure status
      print('Error fetching caregivers: $e');
      return "error";
    }
  }

  // Retrieves available caregivers, fetching from Firestore if necessary
  Future<List<Caregiver>> getAvailableCaregivers() async {
    // Fetch caregivers if the list is empty
    if (_caregivers.isEmpty) {
      await fetchCaregivers();
    }
    return availableCaregivers;
  }

  // Fetches clients from Firestore and updates the local list
  Future<String> fetchClients() async {
    try {
      // Query the 'clients' collection
      final snapshot = await _firestore.collection('clients').get();
      // Clear existing clients to avoid duplicates
      _clients.clear();
      // Map Firestore documents to Client objects
      _clients.addAll(snapshot.docs.map((doc) => Client(
            id: doc.id,
            name: doc['name'],
            email: doc['email'],
            address: doc['address'],
            carePlan: doc['carePlan'],
          )).toList());
      // Log success and number of clients fetched
      print('Clients fetched: ${_clients.length}');
      // Notify listeners of state change
      notifyListeners();
      return "success";
    } catch (e) {
      // Log error and return failure status
      print('Error fetching clients: $e');
      return "error";
    }
  }

  // Fetches shifts from Firestore, ordered by creation date, limited to 500
  Future<String> fetchShifts() async {
    try {
      // Query the 'shifts' collection with a limit of 500
      final snapshot =
          await _firestore.collection('shifts').limit(500).get();
      // Clear existing shifts to avoid duplicates
      _shifts.clear();
      // Map Firestore documents to Shift objects
      _shifts.addAll(snapshot.docs.map((doc) => Shift(
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
          )).toList());
      // Log success and number of shifts fetched
      print('Shifts fetched: ${_shifts.length}');
      // Notify listeners of state change
      notifyListeners();
      return "success";
    } catch (e) {
      // Log error and return failure status
      print('Error fetching shifts: $e');
      return "error";
    }
  }

  // Returns shifts assigned to a specific caregiver
  List<Shift> getShiftsForCaregiver(String caregiverId) {
    return _shifts.where((shift) => shift.caregiverId == caregiverId).toList();
  }

  // Returns shifts assigned to a specific client
  List<Shift> getShiftsForClient(String clientId) {
    return _shifts.where((shift) => shift.clientId == clientId).toList();
  }

  // Checks if a new shift overlaps with existing shifts for a caregiver or client
  bool _isShiftOverlap(
      DateTime startTime, DateTime endTime, String? caregiverId, String clientId) {
    for (var shift in _shifts) {
      // Check if shift conflicts with caregiver or client
      if ((caregiverId != null && shift.caregiverId == caregiverId) ||
          shift.clientId == clientId) {
        // Check for time overlap
        if (!(endTime.isBefore(shift.startTime) || startTime.isAfter(shift.endTime))) {
          print("Overlap has been detected for caregiverId: $caregiverId and clientId: $clientId in the shift from ${shift.startTime} to ${shift.endTime}");
          return true; // Overlap detected
        }
      }
    }
    return false; // No overlap
  }

  // Requests a new shift for a client
  Future<String> requestShift({
    required String clientId,
    required String clientName,
    required DateTime startTime,
    required DateTime endTime,
    required BuildContext context,
  }) async {
    // Validate start and end times
    if (startTime.isAfter(endTime)) {
      throw Exception('Start time must be before end time');
    }
    if (startTime.isBefore(DateTime.now())) {
      throw Exception('Start time must be in the future');
    }
    // Check for overlapping shifts
    if (_isShiftOverlap(startTime, endTime, null, clientId)) {
      throw Exception('Shift overlaps with existing shift for client');
    }
    // Generate unique shift ID
    final shiftId = 's${DateTime.now().millisecondsSinceEpoch}';
    // Create new Shift object
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
    try {
      // Save shift to Firestore
      await _firestore.collection('shifts').doc(shiftId).set({
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
      // Add shift to local list
      _shifts.add(shift);
      // Notify listeners of state change
      notifyListeners();
      return "success";
    } catch (e) {
      // Log error and return failure status
      print('Error requesting shift: $e');
      return "error";
    }
  }

  // Adds a new shift (admin-only)
  Future<String> addShift({
    required String clientId,
    required String clientName,
    required DateTime startTime,
    required DateTime endTime,
    required BuildContext context,
    String? caregiverId,
    String? caregiverName,
  }) async {
    // Verify admin privileges
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user?.role != 'admin') {
      throw Exception('Only admins can add shifts');
    }
    // Validate client
    final client = _clients.firstWhere(
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
    // Check for overlapping shifts
    if (_isShiftOverlap(startTime, endTime, caregiverId, clientId)) {
      throw Exception('Shift overlaps with existing shift for client');
    }
    // Generate unique shift ID
    final shiftId = 's${DateTime.now().millisecondsSinceEpoch}';
    // Create new Shift object
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
    try {
      // Save shift to Firestore
      await _firestore.collection('shifts').doc(shiftId).set({
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
      // Add shift to local list
      _shifts.add(shift);
      // Notify listeners of state change
      notifyListeners();
      return "success";
    } catch (e) {
      // Log error and return failure status
      print('Error adding shift: $e');
      return "error";
    }
  }

  // Updates an existing shift (admin-only)
  Future<String> updateShift({
    required String shiftId,
    required DateTime startTime,
    required DateTime endTime,
    required BuildContext context,
    String? caregiverId,
    String? caregiverName,
  }) async {
    // Verify admin privileges
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user?.role != 'admin') {
      throw Exception('Only admins can update shifts');
    }
    // Find the shift to update
    final shiftIndex = _shifts.indexWhere((s) => s.id == shiftId);
    if (shiftIndex == -1) {
      throw Exception('Shift not found');
    }
    // Validate start and end times
    if (startTime.isAfter(endTime)) {
      throw Exception('Start time must be before end time');
    }
    // Check for overlapping shifts
    if (_isShiftOverlap(
        startTime, endTime, caregiverId ?? _shifts[shiftIndex].caregiverId, _shifts[shiftIndex].clientId)) {
      throw Exception('Shift overlaps with existing shift');
    }
    try {
      // Update shift in Firestore
      await _firestore.collection('shifts').doc(shiftId).update({
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        if (caregiverId != null) 'caregiverId': caregiverId,
        if (caregiverName != null) 'caregiverName': caregiverName,
      });
      // Update local shift data
      _shifts[shiftIndex].startTime = startTime;
      _shifts[shiftIndex].endTime = endTime;
      if (caregiverId != null && caregiverName != null) {
        _shifts[shiftIndex].caregiverId = caregiverId;
        _shifts[shiftIndex].caregiverName = caregiverName;
      }
      // Notify listeners of state change
      notifyListeners();
      return "success";
    } catch (e) {
      // Log error and return failure status
      print('Error updating shift: $e');
      return "error";
    }
  }

  // Updates the status of a shift
  Future<String> updateShiftStatus({
    required String shiftId,
    required String status,
    Location? location,
  }) async {
    // Find the shift to update
    final shift = _shifts.firstWhere((s) => s.id == shiftId);
    // Validate location for in-session status
    if (status == 'in_session' && location == null) {
      throw Exception('Location is required for check-in');
    }
    try {
      // Update shift status in Firestore
      await _firestore.collection('shifts').doc(shiftId).update({
        'status': status,
        if (location != null)
          'location': {
            'latitude': location.latitude,
            'longitude': location.longitude,
          },
      });
      // Update local shift data
      shift.status = status;
      if (location != null) {
        shift.location = location;
      }
      // Notify listeners of state change
      notifyListeners();
      return "success";
    } catch (e) {
      // Log error and return failure status
      print('Error updating shift status: $e');
      return "error";
    }
  }

  // Assigns a caregiver to a shift
  Future<String> assignShift(String shiftId, String caregiverId, String caregiverName) async {
    // Find the shift to assign
    final shift = _shifts.firstWhere((shift) => shift.id == shiftId);
    // Check for overlapping shifts
    if (_isShiftOverlap(shift.startTime, shift.endTime, caregiverId, shift.clientId)) {
      throw Exception('Caregiver is already assigned to another shift at this time');
    }
    try {
      // Update shift in Firestore with caregiver details
      await _firestore.collection('shifts').doc(shiftId).update({
        'caregiverId': caregiverId,
        'caregiverName': caregiverName,
        'status': shift.status == 'request' ? 'pending' : shift.status,
      });
      // Update local shift data
      shift.caregiverId = caregiverId;
      shift.caregiverName = caregiverName;
      if (shift.status == 'request') {
        shift.status = 'pending';
      }
      // Notify listeners of state change
      notifyListeners();
      return "success";
    } catch (e) {
      // Log error and return failure status
      print('Error assigning shift: $e');
      return "error";
    }
  }

  // Fetches all clients from Firestore
  Future<String> getAllClients() async {
    try {
      // Query the 'clients' collection
      final snapshot = await _firestore.collection('clients').get();
      // Clear existing clients to avoid duplicates
      _clients.clear();
      // Map Firestore documents to Client objects
      _clients.addAll(snapshot.docs.map((doc) => Client(
            id: doc.id,
            name: doc['name'],
            email: doc['email'],
            address: doc['address'],
            carePlan: doc['carePlan'],
          )).toList());
      // Log success and number of clients fetched
      print('Clients fetched: ${_clients.length}');
      // Notify listeners of state change
      notifyListeners();
      return "success";
    } catch (e) {
      // Log error and return failure status
      print('Error fetching clients: $e');
      return "error";
    }
  }
}