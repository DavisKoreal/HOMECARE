import 'package:flutter/material.dart';
import 'package:homecare0x1/models/medication_record.dart';

class MedicationRecordProvider with ChangeNotifier {
  List<MedicationRecord> _records = [
    MedicationRecord(
      id: '1',
      clientId: '1',
      medicationName: 'Aspirin',
      dosage: '100mg',
      administrationTime: DateTime.now().subtract(const Duration(hours: 2)),
      notes: 'Taken with water',
    ),
    MedicationRecord(
      id: '2',
      clientId: '1',
      medicationName: 'Lisinopril',
      dosage: '10mg',
      administrationTime: DateTime.now().subtract(const Duration(hours: 4)),
      notes: 'No side effects',
    ),
  ];

  List<MedicationRecord> get records => _records;

  void addRecord(MedicationRecord record) {
    _records.insert(0, record);
    notifyListeners();
  }
}
