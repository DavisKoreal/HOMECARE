import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/providers/location_provider.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/models/shift.dart';
import 'package:homecare0x1/models/location.dart';

class Caregiver {
  final String id;
  final String name;
  final bool isAvailable;

  Caregiver({
    required this.id,
    required this.name,
    required this.isAvailable,
  });
}

class ShiftAssignmentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Caregiver> _caregivers = [];
  final List<Client> _clients = [];
  final List<Shift> _shifts = [];

  List<Caregiver> get availableCaregivers =>
      _caregivers.where((cg) => cg.isAvailable).toList();

  List<Client> get clients => _clients;

  List<Shift> get unassignedShifts =>
      _shifts.where((shift) => shift.caregiverId == null).toList();

  List<Shift> get requestShifts =>
      _shifts.where((shift) => shift.status == 'request').toList();

  List<Shift> get allShifts => _shifts;

  List<Shift> get shifts => _shifts;

  Future<void> fetchCaregivers() async {
    try {
      final snapshot = await _firestore.collection('caregivers').get();
      _caregivers.clear();
      _caregivers.addAll(snapshot.docs.map((doc) => Caregiver(
        id: doc.id,
        name: doc['name'],
        isAvailable: doc['isAvailable'],
      )).toList());
      notifyListeners();
    } catch (e) {
      print('Error fetching caregivers: $e');
    }
  }
 
  Future<List<Caregiver>> getAvailableCaregivers() async {
    if (_caregivers.isEmpty) {
      await fetchCaregivers();
    }
    return availableCaregivers;
  }

  Future<void> fetchClients() async {
    try {
      final snapshot = await _firestore.collection('clients').get();
      _clients.clear();
      _clients.addAll(snapshot.docs.map((doc) => Client(
        id: doc.id,
        name: doc['name'],
        email: doc['email'],
        address: doc['address'],
        carePlan: doc['carePlan'],
      )).toList());
      notifyListeners();
    } catch (e) {
      print('Error fetching clients: $e');
    }
  }

  Future<void> fetchShifts() async {
    try {
      // final snapshot = await _firestore.collection('shifts').get();
      // this will fetch the shifts ordered by creation date and limit to 500
      final snapshot = await _firestore
        .collection('shifts')
        .orderBy('createdAt', descending: true)
        .limit(500)
        .get();
      _shifts.clear();
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
            ? Location(latitude: doc['location']['latitude'], longitude: doc['location']['longitude'])
            : null,
      )).toList());
      notifyListeners();
    } catch (e) {
      print('Error fetching shifts: $e');
    }
  }

  List<Shift> getShiftsForCaregiver(String caregiverId) {
    return _shifts.where((shift) => shift.caregiverId == caregiverId).toList();
  }

  List<Shift> getShiftsForClient(String clientId) {
    return _shifts.where((shift) => shift.clientId == clientId).toList();
  }

  bool _isShiftOverlap(DateTime startTime, DateTime endTime, String? caregiverId, String clientId) {
    for (var shift in _shifts) {
      if ((caregiverId != null && shift.caregiverId == caregiverId) ||  shift.clientId == clientId) {
        if (!(endTime.isBefore(shift.startTime) || startTime.isAfter(shift.endTime))) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> requestShift({
    required String clientId,
    required String clientName,
    required DateTime startTime,
    required DateTime endTime,
    required BuildContext context,
  }) async {
    if (startTime.isAfter(endTime)) {
      throw Exception('Start time must be before end time');
    }
    if (startTime.isBefore(DateTime.now())) {
      throw Exception('Start time must be in the future');
    }
    if (_isShiftOverlap(startTime, endTime, null, clientId)) {
      throw Exception('Shift overlaps with existing shift for client');
    }
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
    try {
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
      _shifts.add(shift);
      notifyListeners();
    } catch (e) {
      print('Error requesting shift: $e');
    }
  }

  Future<void> addShift({
    required String clientId,
    required String clientName,
    required DateTime startTime,
    required DateTime endTime,
    required BuildContext context,
    String? caregiverId,
    String? caregiverName,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user?.role != 'admin') {
      throw Exception('Only admins can add shifts');
    }
    final client = _clients.firstWhere(
      (c) => c.id == clientId && c.name == clientName,
      orElse: () => throw Exception('Invalid client ID or name'),
    );
    if (startTime.isAfter(endTime)) {
      throw Exception('Start time must be before end time');
    }
    if (startTime.isBefore(DateTime.now())) {
      throw Exception('Start time must be in the future');
    }
    if (_isShiftOverlap(startTime, endTime, caregiverId, clientId)) {
      throw Exception('Shift overlaps with existing shift for client');
    }
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
    );
    try {
      await _firestore.collection('shifts').doc(shiftId).set({
        'clientId': clientId,
        'clientName': clientName,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'caregiverId': caregiverId,
        'caregiverName': caregiverName,
        'status': 'pending',
      });
      _shifts.add(shift);
      notifyListeners();
    } catch (e) {
      print('Error adding shift: $e');
    }
  }

  Future<void> updateShift({
    required String shiftId,
    required DateTime startTime,
    required DateTime endTime,
    required BuildContext context,
    String? caregiverId,
    String? caregiverName,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user?.role != 'admin') {
      throw Exception('Only admins can update shifts');
    }
    final shiftIndex = _shifts.indexWhere((s) => s.id == shiftId);
    if (shiftIndex == -1) {
      throw Exception('Shift not found');
    }
    if (startTime.isAfter(endTime)) {
      throw Exception('Start time must be before end time');
    }
    if (_isShiftOverlap(
        startTime,
        endTime,
        caregiverId ?? _shifts[shiftIndex].caregiverId,
        _shifts[shiftIndex].clientId)) {
      throw Exception('Shift overlaps with existing shift');
    }
    try {
      await _firestore.collection('shifts').doc(shiftId).update({
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        if (caregiverId != null) 'caregiverId': caregiverId,
        if (caregiverName != null) 'caregiverName': caregiverName,
      });
      _shifts[shiftIndex].startTime = startTime;
      _shifts[shiftIndex].endTime = endTime;
      if (caregiverId != null && caregiverName != null) {
        _shifts[shiftIndex].caregiverId = caregiverId;
        _shifts[shiftIndex].caregiverName = caregiverName;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating shift: $e');
    }
  }

  Future<void> updateShiftStatus({
    required String shiftId,
    required String status,
    Location? location,
  }) async {
    final shift = _shifts.firstWhere((s) => s.id == shiftId);
    if (status == 'in_session' && location == null) {
      throw Exception('Location is required for check-in');
    }
    try {
      await _firestore.collection('shifts').doc(shiftId).update({
        'status': status,
        if (location != null) 'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
      });
      shift.status = status;
      if (location != null) {
        shift.location = location;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating shift status: $e');
    }
  }

  Future<void> assignShift(String shiftId, String caregiverId, String caregiverName) async {
    final shift = _shifts.firstWhere((shift) => shift.id == shiftId);
    if (_isShiftOverlap(shift.startTime, shift.endTime, caregiverId, shift.clientId)) {
      throw Exception('Caregiver is already assigned to another shift at this time');
    }
    
    try {
      await _firestore.collection('shifts').doc(shiftId).update({
        'caregiverId': caregiverId,
        'caregiverName': caregiverName,
        'status': shift.status == 'request' ? 'pending' : shift.status,
      });
      shift.caregiverId = caregiverId;
      shift.caregiverName = caregiverName;
      if (shift.status == 'request') {
        shift.status = 'pending';
      }
      notifyListeners();
    } catch (e) {
      print('Error assigning shift: $e');
    }
  }
}
