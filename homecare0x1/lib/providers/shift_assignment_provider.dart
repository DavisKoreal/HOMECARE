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

  factory Caregiver.fromMap(Map<String, dynamic> map) {
    return Caregiver(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      isAvailable: map['isAvailable'] ?? false,
    );
  }
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

  Future<String> fetchCaregivers() async {
    try {
      final snapshot = await _firestore.collection('caregivers').get();
      _caregivers.clear();
      _caregivers.addAll(snapshot.docs.map((doc) => Caregiver.fromMap({
            'id': doc.id,
            'name': doc['name'] ?? '',
            'isAvailable': doc['isAvailable'] ?? false,
          })).toList());
      notifyListeners();
      print('Caregivers fetched: ${_caregivers.length}');
      return "success";
    } catch (e) {
      print('Error fetching caregivers: $e');
      return "error";
    }
  }

  Future<List<Caregiver>> getAvailableCaregivers() async {
    if (_caregivers.isEmpty) {
      await fetchCaregivers();
    }
    return availableCaregivers;
  }

  Future<String> fetchClients() async {
    try {
      final snapshot = await _firestore.collection('clients').get();
      _clients.clear();
      _clients.addAll(snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Ensure ID is included
        return Client.fromMap(data);
      }).toList());
      print('Clients fetched: ${_clients.length}');
      notifyListeners();
      return "success";
    } catch (e) {
      print('Error fetching clients: $e');
      return "error";
    }
  }

  Future<String> fetchShifts() async {
    try {
      final snapshot = await _firestore.collection('shifts').limit(500).get();
      _shifts.clear();
      _shifts.addAll(snapshot.docs.map((doc) {
        final data = doc.data();
        return Shift(
          id: doc.id,
          clientId: data['clientId'] ?? '',
          clientName: data['clientName'] ?? '',
          startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
          endTime: (data['endTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
          caregiverId: data['caregiverId'],
          caregiverName: data['caregiverName'],
          status: data['status'] ?? 'pending',
          location: data['location'] != null
              ? Location(
                  latitude: (data['location']['latitude'] as num?)?.toDouble() ?? 0.0,
                  longitude: (data['location']['longitude'] as num?)?.toDouble() ?? 0.0,
                )
              : null,
        );
      }).toList());
      print('Shifts fetched: ${_shifts.length}');
      notifyListeners();
      return "success";
    } catch (e) {
      print('Error fetching shifts: $e');
      return "error";
    }
  }

  List<Shift> getShiftsForCaregiver(String caregiverId) {
    return _shifts.where((shift) => shift.caregiverId == caregiverId).toList();
  }

  List<Shift> getShiftsForClient(String clientId) {
    return _shifts.where((shift) => shift.clientId == clientId).toList();
  }

  bool _isShiftOverlap(
      DateTime startTime, DateTime endTime, String? caregiverId, String clientId) {
    for (var shift in _shifts) {
      if ((caregiverId != null && shift.caregiverId == caregiverId) ||
          shift.clientId == clientId) {
        if (!(endTime.isBefore(shift.startTime) || startTime.isAfter(shift.endTime))) {
          print("Overlap detected for caregiverId: $caregiverId and clientId: $clientId in shift from ${shift.startTime} to ${shift.endTime}");
          return true;
        }
      }
    }
    return false;
  }

  Future<String> requestShift({
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
      return "success";
    } catch (e) {
      print('Error requesting shift: $e');
      return "error";
    }
  }

  Future<String> addShift({
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
      location: LocationProvider().getRandomLocation(),
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
        'location': {
          'latitude': shift.location!.latitude,
          'longitude': shift.location!.longitude,
        },
      });
      _shifts.add(shift);
      notifyListeners();
      return "success";
    } catch (e) {
      print('Error adding shift: $e');
      return "error";
    }
  }

  Future<String> updateShift({
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
        startTime, endTime, caregiverId ?? _shifts[shiftIndex].caregiverId, _shifts[shiftIndex].clientId)) {
      throw Exception('Shift overlaps with existing shift');
    }
    try {
      await _firestore.collection('shifts').doc(shiftId).update({
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        if (caregiverId != null) 'caregiverId': caregiverId,
        if (caregiverName != null) 'caregiverName': caregiverName,
      });
      _shifts[shiftIndex] = _shifts[shiftIndex].copyWith(
        startTime: startTime,
        endTime: endTime,
        caregiverId: caregiverId ?? _shifts[shiftIndex].caregiverId,
        caregiverName: caregiverName ?? _shifts[shiftIndex].caregiverName,
      );
      notifyListeners();
      return "success";
    } catch (e) {
      print('Error updating shift: $e');
      return "error";
    }
  }

  Future<String> updateShiftStatus({
    required String shiftId,
    required String status,
    Location? location,
  }) async {
    final shiftIndex = _shifts.indexWhere((s) => s.id == shiftId);
    if (shiftIndex == -1) {
      throw Exception('Shift not found');
    }
    if (status == 'in_session' && location == null) {
      throw Exception('Location is required for check-in');
    }
    try {
      await _firestore.collection('shifts').doc(shiftId).update({
        'status': status,
        if (location != null)
          'location': {
            'latitude': location.latitude,
            'longitude': location.longitude,
          },
      });
      _shifts[shiftIndex] = _shifts[shiftIndex].copyWith(
        status: status,
        location: location ?? _shifts[shiftIndex].location,
      );
      notifyListeners();
      return "success";
    } catch (e) {
      print('Error updating shift status: $e');
      return "error";
    }
  }

  Future<String> assignShift(String shiftId, String caregiverId, String caregiverName) async {
    final shiftIndex = _shifts.indexWhere((shift) => shift.id == shiftId);
    if (shiftIndex == -1) {
      throw Exception('Shift not found');
    }
    final shift = _shifts[shiftIndex];
    if (_isShiftOverlap(shift.startTime, shift.endTime, caregiverId, shift.clientId)) {
      throw Exception('Caregiver is already assigned to another shift at this time');
    }
    try {
      await _firestore.collection('shifts').doc(shiftId).update({
        'caregiverId': caregiverId,
        'caregiverName': caregiverName,
        'status': shift.status == 'request' ? 'pending' : shift.status,
      });
      _shifts[shiftIndex] = _shifts[shiftIndex].copyWith(
        caregiverId: caregiverId,
        caregiverName: caregiverName,
        status: shift.status == 'request' ? 'pending' : shift.status,
      );
      notifyListeners();
      return "success";
    } catch (e) {
      print('Error assigning shift: $e');
      return "error";
    }
  }
}