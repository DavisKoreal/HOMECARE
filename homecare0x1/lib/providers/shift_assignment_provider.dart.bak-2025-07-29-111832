import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

class Shift {
  final String id;
  final String clientId;
  final String clientName;
  final DateTime dateTime;
  String? caregiverId;
  String? caregiverName;

  Shift({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.dateTime,
    this.caregiverId,
    this.caregiverName,
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

  final List<Shift> _shifts = [
    Shift(
      id: 's1',
      clientId: '1',
      clientName: 'John Doe',
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 9)),
    ),
    Shift(
      id: 's2',
      clientId: '2',
      clientName: 'Jane Smith',
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 14)),
    ),
    Shift(
      id: 's3',
      clientId: '3',
      clientName: 'Alice Johnson',
      dateTime: DateTime.now().add(const Duration(days: 2, hours: 10)),
    ),
  ];

  List<Caregiver> get availableCaregivers =>
      _caregivers.where((cg) => cg.isAvailable).toList();

  List<Shift> get unassignedShifts =>
      _shifts.where((shift) => shift.caregiverId == null).toList();

  void assignShift(String shiftId, String caregiverId, String caregiverName) {
    final shift = _shifts.firstWhere((shift) => shift.id == shiftId);
    shift.caregiverId = caregiverId;
    shift.caregiverName = caregiverName;
    notifyListeners();
  }
}
