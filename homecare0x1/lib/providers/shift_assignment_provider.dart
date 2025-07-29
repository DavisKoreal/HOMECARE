import 'package:flutter/material.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/providers/location_provider.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:provider/provider.dart';

class Shift {
  final String id;
  final String clientId;
  String clientName;
  DateTime startTime;
  DateTime endTime;
  String? caregiverId;
  String? caregiverName;
  String status;
  Location? location;

  Shift({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.startTime,
    required this.endTime,
    this.caregiverId,
    this.caregiverName,
    required this.status,
    this.location,
  });
}

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
  final List<Caregiver> _caregivers = [
    Caregiver(id: 'cg1', name: 'Emma Wilson', isAvailable: true),
    Caregiver(id: 'cg2', name: 'Liam Brown', isAvailable: true),
    Caregiver(id: 'cg3', name: 'Olivia Davis', isAvailable: false),
    Caregiver(id: 'cg4', name: 'Noah Taylor', isAvailable: true),
  ];

  final List<Client> _clients = [
    Client(
      id: 'c1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      address: '123 Elm St, Springfield',
      carePlan: 'Daily care',
    ),
    Client(
      id: 'c2',
      name: 'Jane Smith',
      email: 'jane.smith@example.com',
      address: '456 Oak Ave, Springfield',
      carePlan: 'Weekly check-in',
    ),
    Client(
      id: 'c3',
      name: 'Alice Johnson',
      email: 'alice.johnson@example.com',
      address: '789 Pine Rd, Springfield',
      carePlan: 'Post-op care',
    ),
    Client(
      id: 'c4',
      name: 'Bob Wilson',
      email: 'bob.wilson@example.com',
      address: '321 Maple Dr, Springfield',
      carePlan: 'Mobility assistance',
    ),
    Client(
      id: 'c5',
      name: 'Carol Brown',
      email: 'carol.brown@example.com',
      address: '654 Cedar Ln, Springfield',
      carePlan: 'Medication management',
    ),
  ];

  final List<Shift> _shifts = [
    Shift(
      id: 's1',
      clientId: 'c1',
      clientName: 'John Doe',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 9)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 11)),
      status: 'pending',
    ),
    Shift(
      id: 's2',
      clientId: 'c2',
      clientName: 'Jane Smith',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 14)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 16)),
      status: 'pending',
    ),
    Shift(
      id: 's3',
      clientId: 'c3',
      clientName: 'Alice Johnson',
      startTime: DateTime.now().add(const Duration(days: 2, hours: 10)),
      endTime: DateTime.now().add(const Duration(days: 2, hours: 12)),
      status: 'pending',
    ),
  ];

  List<Caregiver> get availableCaregivers =>
      _caregivers.where((cg) => cg.isAvailable).toList();

  List<Shift> get unassignedShifts =>
      _shifts.where((shift) => shift.caregiverId == null).toList();

  List<Shift> get allShifts => _shifts;

  List<Shift> getShiftsForCaregiver(String caregiverId) {
    return _shifts.where((shift) => shift.caregiverId == caregiverId).toList();
  }

  List<Shift> getShiftsForClient(String clientId) {
    return _shifts.where((shift) => shift.clientId == clientId).toList();
  }

  bool _isShiftOverlap(DateTime startTime, DateTime endTime,
      String? caregiverId, String clientId) {
    for (var shift in _shifts) {
      if ((caregiverId != null && shift.caregiverId == caregiverId) ||
          shift.clientId == clientId) {
        if (!(endTime.isBefore(shift.startTime) ||
            startTime.isAfter(shift.endTime))) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> addShift({
    required String clientId,
    required String clientName,
    required DateTime startTime,
    required DateTime endTime,
    required BuildContext context,
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
    if (_isShiftOverlap(startTime, endTime, null, clientId)) {
      throw Exception('Shift overlaps with existing shift for client');
    }
    final shift = Shift(
      id: 's${_shifts.length + 1}',
      clientId: clientId,
      clientName: clientName,
      startTime: startTime,
      endTime: endTime,
      status: 'pending',
    );
    _shifts.add(shift);
    notifyListeners();
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
    _shifts[shiftIndex].startTime = startTime;
    _shifts[shiftIndex].endTime = endTime;
    if (caregiverId != null && caregiverName != null) {
      _shifts[shiftIndex].caregiverId = caregiverId;
      _shifts[shiftIndex].caregiverName = caregiverName;
    }
    notifyListeners();
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
    shift.status = status;
    if (location != null) {
      shift.location = location;
    }
    notifyListeners();
  }

  void assignShift(String shiftId, String caregiverId, String caregiverName) {
    final shift = _shifts.firstWhere((shift) => shift.id == shiftId);
    if (_isShiftOverlap(
        shift.startTime, shift.endTime, caregiverId, shift.clientId)) {
      throw Exception(
          'Caregiver is already assigned to another shift at this time');
    }
    shift.caregiverId = caregiverId;
    shift.caregiverName = caregiverName;
    shift.status = 'pending';
    notifyListeners();
  }
}
