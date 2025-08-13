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
