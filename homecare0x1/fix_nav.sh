#!/bin/bash

# Update care_note_provider.dart
cat << 'EOF' > lib/providers/care_note_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/care_note.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CareNoteProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<CareNote> _notes = [];

  List<CareNote> get notes => _notes;

  Future<void> fetchNotes() async {
    try {
      final snapshot = await _firestore.collection('care_notes').get();
      _notes.clear();
      _notes.addAll(snapshot.docs.map((doc) => CareNote(
        id: doc.id,
        clientId: doc['clientId'],
        caregiverId: doc['caregiverId'],
        shiftId: doc['shiftId'],
        healthStatus: doc['healthStatus'],
        activities: doc['activities'],
        observations: doc['observations'],
        medicationAdherence: doc['medicationAdherence'],
        mood: doc['mood'],
        note: doc['note'],
        timestamp: (doc['timestamp'] as Timestamp).toDate(),
        isVisibleToClient: doc['isVisibleToClient'],
        isLate: doc['isLate'],
      )).toList());
      notifyListeners();
    } catch (e) {
      print('Error fetching notes: $e');
    }
  }

  List<CareNote> getNotesForClient(String clientId, {bool onlyVisible = false}) {
    return _notes
        .where((note) =>
            note.clientId == clientId &&
            (!onlyVisible || note.isVisibleToClient))
        .toList();
  }

  List<CareNote> getNotesForCaregiver(String caregiverId) {
    return _notes.where((note) => note.caregiverId == caregiverId).toList();
  }

  Future<void> addNote({
    required BuildContext context,
    required String clientId,
    required String caregiverId,
    required String shiftId,
    required String healthStatus,
    required String activities,
    required String observations,
    required String medicationAdherence,
    required String mood,
    required String note,
  }) async {
    final shiftProvider = Provider.of<ShiftAssignmentProvider>(context, listen: false);
    final shift = shiftProvider.shifts.firstWhere(
      (shift) => shift.id == shiftId,
      orElse: () => throw Exception('Shift not found'),
    );
    final now = DateTime.now();
    final isLate = now.isAfter(shift.endTime.add(const Duration(hours: 12)));

    if (isLate) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Late Submission'),
          content: const Text(
              'This note is being submitted more than 12 hours after the shift ended.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    final newNote = CareNote(
      id: const Uuid().v4(),
      clientId: clientId,
      caregiverId: caregiverId,
      shiftId: shiftId,
      healthStatus: healthStatus,
      activities: activities,
      observations: observations,
      medicationAdherence: medicationAdherence,
      mood: mood,
      note: note,
      timestamp: now,
      isLate: isLate,
    );

    try {
      await _firestore.collection('care_notes').doc(newNote.id).set({
        'clientId': clientId,
        'caregiverId': caregiverId,
        'shiftId': shiftId,
        'healthStatus': healthStatus,
        'activities': activities,
        'observations': observations,
        'medicationAdherence': medicationAdherence,
        'mood': mood,
        'note': note,
        'timestamp': Timestamp.fromDate(now),
        'isVisibleToClient': false,
        'isLate': isLate,
      });
      _notes.insert(0, newNote);
      notifyListeners();
    } catch (e) {
      print('Error adding note: $e');
    }
  }

  Future<void> toggleVisibility(String noteId) async {
    final index = _notes.indexWhere((note) => note.id == noteId);
    if (index != -1) {
      final newVisibility = !_notes[index].isVisibleToClient;
      _notes[index] = CareNote(
        id: _notes[index].id,
        clientId: _notes[index].clientId,
        caregiverId: _notes[index].caregiverId,
        shiftId: _notes[index].shiftId,
        healthStatus: _notes[index].healthStatus,
        activities: _notes[index].activities,
        observations: _notes[index].observations,
        medicationAdherence: _notes[index].medicationAdherence,
        mood: _notes[index].mood,
        note: _notes[index].note,
        timestamp: _notes[index].timestamp,
        isVisibleToClient: newVisibility,
        isLate: _notes[index].isLate,
      );
      try {
        await _firestore.collection('care_notes').doc(noteId).update({
          'isVisibleToClient': newVisibility,
        });
        notifyListeners();
      } catch (e) {
        print('Error toggling visibility: $e');
      }
    }
  }
}
EOF

# Update medication_record_provider.dart
cat << 'EOF' > lib/providers/medication_record_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/medication_record.dart';

class MedicationRecordProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<MedicationRecord> _records = [];

  List<MedicationRecord> get records => _records;

  Future<void> fetchRecords() async {
    try {
      final snapshot = await _firestore.collection('medication_records').get();
      _records.clear();
      _records.addAll(snapshot.docs.map((doc) => MedicationRecord(
        id: doc.id,
        clientId: doc['clientId'],
        medicationName: doc['medicationName'],
        dosage: doc['dosage'],
        administrationTime: (doc['administrationTime'] as Timestamp).toDate(),
        notes: doc['notes'],
      )).toList());
      notifyListeners();
    } catch (e) {
      print('Error fetching medication records: $e');
    }
  }

  Future<void> addRecord(MedicationRecord record) async {
    try {
      await _firestore.collection('medication_records').doc(record.id).set({
        'clientId': record.clientId,
        'medicationName': record.medicationName,
        'dosage': record.dosage,
        'administrationTime': Timestamp.fromDate(record.administrationTime),
        'notes': record.notes,
      });
      _records.insert(0, record);
      notifyListeners();
    } catch (e) {
      print('Error adding medication record: $e');
    }
  }
}
EOF

# Update payment_provider.dart
cat << 'EOF' > lib/providers/payment_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/payment.dart';

class PaymentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Payment> _payments = [];
  final List<Map<String, dynamic>> _paymentMethods = [];

  List<Payment> get payments => _payments;

  List<Map<String, dynamic>> get paymentMethods => _paymentMethods;

  Future<void> fetchPayments() async {
    try {
      final snapshot = await _firestore.collection('payments').get();
      _payments.clear();
      _payments.addAll(snapshot.docs.map((doc) => Payment(
        id: doc.id,
        invoiceNumber: doc['invoiceNumber'],
        amount: doc['amount'].toDouble(),
        dueDate: (doc['dueDate'] as Timestamp).toDate(),
        status: doc['status'],
        description: doc['description'],
        servicePeriod: doc['servicePeriod'],
        hoursBilled: doc['hoursBilled'].toDouble(),
        rate: doc['rate'].toDouble(),
      )).toList());
      notifyListeners();
    } catch (e) {
      print('Error fetching payments: $e');
    }
  }

  Future<void> fetchPaymentMethods() async {
    try {
      final snapshot = await _firestore.collection('payment_methods').get();
      _paymentMethods.clear();
      _paymentMethods.addAll(snapshot.docs.map((doc) => {
        'id': doc.id,
        'title': doc['title'],
        'subtitle': doc['subtitle'],
        'icon': Icons.credit_card, // Note: Icons can't be stored in Firestore, handle accordingly
        'color': Color(doc['color']),
        'isDefault': doc['isDefault'],
      }).toList());
      notifyListeners();
    } catch (e) {
      print('Error fetching payment methods: $e');
    }
  }

  double get totalBilledThisMonth =>
      _payments.where((p) => p.dueDate.month == DateTime.now().month).fold(0.0,
          (sum, payment) => sum + payment.amount);

  double get totalPaidYTD => _payments
      .where((p) =>
          p.status.toLowerCase() == 'paid' &&
          p.dueDate.year == DateTime.now().year)
      .fold(0.0, (sum, payment) => sum + payment.amount);

  int get pendingInvoices =>
      _payments.where((p) => p.status.toLowerCase() == 'pending').length;

  double get outstandingBalance =>
      _payments.where((p) => p.status.toLowerCase() != 'paid').fold(
          0.0, (sum, payment) => sum + payment.amount);

  int get overduePayments =>
      _payments.where((p) => p.status.toLowerCase() == 'overdue').length;

  Future<void> addPayment(Payment payment) async {
    try {
      await _firestore.collection('payments').doc(payment.id).set({
        'invoiceNumber': payment.invoiceNumber,
        'amount': payment.amount,
        'dueDate': Timestamp.fromDate(payment.dueDate),
        'status': payment.status,
        'description': payment.description,
        'servicePeriod': payment.servicePeriod,
        'hoursBilled': payment.hoursBilled,
        'rate': payment.rate,
      });
      _payments.add(payment);
      notifyListeners();
    } catch (e) {
      print('Error adding payment: $e');
    }
  }

  Future<void> addPaymentMethod(Map<String, dynamic> method) async {
    try {
      await _firestore.collection('payment_methods').doc(method['id']).set({
        'title': method['title'],
        'subtitle': method['subtitle'],
        'color': method['color'].value,
        'isDefault': method['isDefault'],
      });
      _paymentMethods.add(method);
      notifyListeners();
    } catch (e) {
      print('Error adding payment method: $e');
    }
  }
}
EOF

# Update shift_assignment_provider.dart
cat << 'EOF' > lib/providers/shift_assignment_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
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
      final snapshot = await _firestore.collection('shifts').get();
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

  Future<void> requestShift({
    required String clientId,
    required String clientName,
    required DateTime startTime,
    required DateTime endTime,
    required BuildContext context,
  }) async {
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
    );
    try {
      await _firestore.collection('shifts').doc(shiftId).set({
        'clientId': clientId,
        'clientName': clientName,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'status': 'request',
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
    if (_isShiftOverlap(
        shift.startTime, shift.endTime, caregiverId, shift.clientId)) {
      throw Exception(
          'Caregiver is already assigned to another shift at this time');
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
EOF

# Update task_provider.dart
cat << 'EOF' > lib/providers/task_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/task.dart';

class TaskProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  Future<void> fetchTasks() async {
    try {
      final snapshot = await _firestore.collection('tasks').get();
      _tasks.clear();
      _tasks.addAll(snapshot.docs.map((doc) => Task(
        id: doc.id,
        title: doc['title'],
        dueDate: (doc['dueDate'] as Timestamp).toDate(),
        isCompleted: doc['isCompleted'],
        clientId: doc['clientId'],
        clientName: doc['clientName'],
        description: doc['description'],
      )).toList());
      notifyListeners();
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'isCompleted': !task.isCompleted,
      });
      task.isCompleted = !task.isCompleted;
      notifyListeners();
    } catch (e) {
      print('Error toggling task completion: $e');
    }
  }
}
EOF

# Update user_provider.dart
cat << 'EOF' > lib/providers/user_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/user.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  User? get user => _user;

  Future<void> fetchUser(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        final userData = docSnapshot.data()!;
        _user = User(
          id: userData['id'],
          role: userData['role'],
          name: userData['name'],
          email: userData['email'],
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  String getInitialRoute() {
    switch (_user?.role) {
      case 'admin':
        return '/admin_dashboard';
      case 'caregiver':
        return '/caregiver_dashboard';
      case 'family':
        return '/family_portal';
      default:
        return '/login';
    }
  }
}
EOF

# Perform Git operations
git add .
git commit -m "migration to firebase from simple mock data"