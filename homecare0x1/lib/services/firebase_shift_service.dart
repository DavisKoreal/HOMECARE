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

class FirebaseShiftService {
  static final FirebaseShiftService instance = FirebaseShiftService._constructor();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _caregiversCollection = 'caregivers';
  final String _clientsCollection = 'clients';
  final String _shiftsCollection = 'shifts';

  FirebaseShiftService._constructor();

  Future<List<Shift>> getBroadcastedShifts() async {
    try {
      final snapshot = await _firestore
          .collection(_shiftsCollection)
          .where('broadcast', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) => Shift.fromMap({
            'id': doc.id,
            ...doc.data(),
          })).toList();
    } catch (e) {
      print('Error fetching broadcasted shifts: $e');
      return [];
    }
  }

  Future<List<CaregiverProfile>> getCaregiversForClient(String clientId) async {
    try {
      final shifts = await getShiftsForClient(clientId);
      final caregiverIds = shifts
          .where((shift) => shift.caregiverId != null)
          .map((shift) => shift.caregiverId!)
          .toSet()
          .toList();
      return await FirebaseCaregiverService.instance.getCaregiversForClient(caregiverIds);
    } catch (e) {
      print('Error fetching caregivers for client: $e');
      return [];
    }
  }

  Future<List<Client>> getAllClients() async {
    try {
      final snapshot = await _firestore.collection(_clientsCollection).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Client.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error fetching clients: $e');
      return [];
    }
  }

  Future<List<Shift>> getAllShifts() async {
    try {
      final snapshot = await _firestore
          .collection(_shiftsCollection)
          .limit(500)
          .get();
      print('Fetched ${snapshot.docs.length} shifts from Firestore');
      return snapshot.docs.map((doc) => Shift.fromMap({
            'id': doc.id,
            ...doc.data(),
          })).toList();
    } catch (e) {
      print('Error fetching shifts: $e');
      return [];
    }
  }

  Future<List<Shift>> getUnassignedShifts() async {
    try {
      final shifts = await getAllShifts();
      return shifts.where((shift) => shift.caregiverId == null).toList();
    } catch (e) {
      print('Error fetching unassigned shifts: $e');
      return [];
    }
  }

  Future<List<Shift>> getRequestShifts() async {
    try {
      final shifts = await getAllShifts();
      return shifts.where((shift) => shift.status == 'request').toList();
    } catch (e) {
      print('Error fetching request shifts: $e');
      return [];
    }
  }

  Future<List<Shift>> getShiftsForCaregiver(String caregiverId) async {
    try {
      final shifts = await getAllShifts();
      return shifts.where((shift) => shift.caregiverId == caregiverId).toList();
    } catch (e) {
      print('Error fetching caregiver shifts: $e');
      return [];
    }
  }

  Future<List<Shift>> getShiftsForClient(String clientId) async {
    try {
      final shifts = await getAllShifts();
      return shifts.where((shift) => shift.clientId == clientId).toList();
    } catch (e) {
      print('Error fetching client shifts: $e');
      return [];
    }
  }

  Future<bool> _isShiftOverlap(
      DateTime startTime, DateTime endTime, String? caregiverId, String clientId) async {
    final shifts = await getAllShifts();
    for (var shift in shifts) {
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
    bool broadcast = false,
  }) async {
    try {
      if (startTime.isAfter(endTime)) {
        throw Exception('Start time must be before end time');
      }
      if (startTime.isBefore(DateTime.now())) {
        throw Exception('Start time must be in the future');
      }
      if (await _isShiftOverlap(startTime, endTime, null, clientId)) {
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
        broadcast: broadcast,
      );
      await _firestore.collection(_shiftsCollection).doc(shiftId).set(shift.toMap());
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
    bool broadcast = false,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user?.role != 'admin') {
        throw Exception('Only admins can add shifts');
      }

      final clients = await getAllClients();
      final client = clients.firstWhere(
        (c) => c.id == clientId && c.name == clientName,
        orElse: () => throw Exception('Invalid client ID or name'),
      );

      if (startTime.isAfter(endTime)) {
        throw Exception('Start time must be before end time');
      }
      if (startTime.isBefore(DateTime.now())) {
        throw Exception('Start time must be in the future');
      }
      if (await _isShiftOverlap(startTime, endTime, caregiverId, clientId)) {
        throw Exception('Shift overlaps with existing shift for client or caregiver');
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
        broadcast: broadcast,
      );

      await _firestore.collection(_shiftsCollection).doc(shiftId).set(shift.toMap());
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
    bool? broadcast,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user?.role != 'admin') {
        throw Exception('Only admins can update shifts');
      }

      final shifts = await getAllShifts();
      final shift = shifts.firstWhere(
        (s) => s.id == shiftId,
        orElse: () => throw Exception('Shift not found'),
      );

      if (startTime.isAfter(endTime)) {
        throw Exception('Start time must be before end time');
      }
      if (await _isShiftOverlap(
          startTime, endTime, caregiverId ?? shift.caregiverId, shift.clientId)) {
        throw Exception('Shift overlaps with existing shift');
      }

      await _firestore.collection(_shiftsCollection).doc(shiftId).update({
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        if (caregiverId != null) 'caregiverId': caregiverId,
        if (caregiverName != null) 'caregiverName': caregiverName,
        if (broadcast != null) 'broadcast': broadcast,
      });
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
    bool? broadcast,
  }) async {
    try {
      final shifts = await getAllShifts();
      final shift = shifts.firstWhere(
        (s) => s.id == shiftId,
        orElse: () => throw Exception('Shift not found'),
      );

      if (status == 'in_session' && location == null) {
        throw Exception('Location is required for check-in');
      }

      await _firestore.collection(_shiftsCollection).doc(shiftId).update({
        'status': status,
        if (location != null)
          'location': {
            'latitude': location.latitude,
            'longitude': location.longitude,
          },
        if (broadcast != null) 'broadcast': broadcast,
      });
      return "success";
    } catch (e) {
      print('Error updating shift status: $e');
      return "error";
    }
  }

  Future<String> assignShift(String shiftId, String caregiverId, String caregiverName) async {
    try {
      final doc = await _firestore.collection(_shiftsCollection).doc(shiftId).get();
      if (!doc.exists) {
        throw Exception('Shift not found');
      }
      final shift = Shift.fromMap({
        'id': doc.id,
        ...doc.data()!,
      });

      if (await _isShiftOverlap(shift.startTime, shift.endTime, caregiverId, shift.clientId)) {
        throw Exception('Caregiver is already assigned to another shift at this time');
      }

      await _firestore.collection(_shiftsCollection).doc(shiftId).update({
        'caregiverId': caregiverId,
        'caregiverName': caregiverName,
        'status': shift.status == 'request' ? 'pending' : shift.status,
        'broadcast': false,
      });
      return "success";
    } catch (e) {
      print('Error assigning shift: $e');
      return "error";
    }
  }
}